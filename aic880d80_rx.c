/*
 * aic880d80_rx.c - RX skeleton for AIC 880d80
 */
#include "aic880d80.h"
#include <linux/netdevice.h>
#include <linux/skbuff.h>


void aic880d80_alloc_rx_buffers(struct aic880d80_private *priv)
{
    while (((priv->rx_head + 1) % AIC880D80_RX_RING_SIZE) != priv->rx_tail) {
        unsigned int entry = priv->rx_head % AIC880D80_RX_RING_SIZE;
        struct aic880d80_desc *desc = &priv->rx_ring[entry];
        if (priv->rx_skbs[entry])
            break;
        struct sk_buff *skb = netdev_alloc_skb_ip_align(priv->netdev, AIC880D80_BUFFER_SIZE);
        if (!skb)
            break;
        dma_addr_t dma_addr = dma_map_single(&priv->pdev->dev, skb->data, AIC880D80_BUFFER_SIZE, DMA_FROM_DEVICE);
        if (dma_mapping_error(&priv->pdev->dev, dma_addr)) {
            dev_kfree_skb(skb);
            break;
        }
        desc->buffer = dma_addr;
        desc->length = AIC880D80_BUFFER_SIZE;
        desc->status = AIC880D80_DESC_OWN;
        priv->rx_skbs[entry] = skb;
        priv->rx_head = (priv->rx_head + 1) % AIC880D80_RX_RING_SIZE;
    }
}


void aic880d80_process_rx_ring(struct aic880d80_private *priv, int budget)
{
    int work_done = 0;
    while (work_done < budget && priv->rx_tail != priv->rx_head) {
        unsigned int entry = priv->rx_tail % AIC880D80_RX_RING_SIZE;
        struct aic880d80_desc *desc = &priv->rx_ring[entry];
        if (desc->status & AIC880D80_DESC_OWN)
            break;
        struct sk_buff *skb = priv->rx_skbs[entry];
        dma_unmap_single(&priv->pdev->dev, desc->buffer, desc->length, DMA_FROM_DEVICE);
        skb_put(skb, desc->length);
        skb->protocol = eth_type_trans(skb, priv->netdev);
        netif_receive_skb(skb);
        priv->rx_skbs[entry] = NULL;
        priv->rx_tail = (priv->rx_tail + 1) % AIC880D80_RX_RING_SIZE;
        work_done++;
    }
}
