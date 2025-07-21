/*
 * aic880d80_tx.c - TX skeleton for AIC 880d80
 */
#include "aic880d80.h"
#include <linux/netdevice.h>
#include <linux/skbuff.h>


netdev_tx_t aic880d80_start_xmit(struct sk_buff *skb, struct net_device *netdev)
{
    struct aic880d80_private *priv = netdev_priv(netdev);
    unsigned int entry = priv->tx_head % AIC880D80_TX_RING_SIZE;
    struct aic880d80_desc *desc = &priv->tx_ring[entry];
    dma_addr_t dma_addr;

    if (((priv->tx_head + 1) % AIC880D80_TX_RING_SIZE) == priv->tx_tail) {
        netif_stop_queue(netdev);
        return NETDEV_TX_BUSY;
    }

    dma_addr = dma_map_single(&priv->pdev->dev, skb->data, skb->len, DMA_TO_DEVICE);
    if (dma_mapping_error(&priv->pdev->dev, dma_addr)) {
        dev_kfree_skb(skb);
        return NETDEV_TX_OK;
    }

    desc->buffer = dma_addr;
    desc->length = skb->len;
    desc->status = AIC880D80_DESC_OWN;
    priv->tx_skbs[entry] = skb;
    priv->tx_head = (priv->tx_head + 1) % AIC880D80_TX_RING_SIZE;

    /* Trigger TX (write to hardware register if needed) */
    aic880d80_write32(priv, AIC880D80_REG_TX_CTRL, 1);

    return NETDEV_TX_OK;
}

void aic880d80_clean_tx_ring(struct aic880d80_private *priv)
{
    while (priv->tx_tail != priv->tx_head) {
        unsigned int entry = priv->tx_tail % AIC880D80_TX_RING_SIZE;
        struct aic880d80_desc *desc = &priv->tx_ring[entry];
        if (desc->status & AIC880D80_DESC_OWN)
            break;
        dma_unmap_single(&priv->pdev->dev, desc->buffer, desc->length, DMA_TO_DEVICE);
        dev_kfree_skb(priv->tx_skbs[entry]);
        priv->tx_tail = (priv->tx_tail + 1) % AIC880D80_TX_RING_SIZE;
    }
}
