/*
 * aic880d80_interrupt.c - Interrupt handler skeleton for AIC 880d80
 */
#include "aic880d80.h"
#include <linux/interrupt.h>
#include <linux/netdevice.h>


irqreturn_t aic880d80_interrupt(int irq, void *dev_id)
{
    struct net_device *netdev = dev_id;
    struct aic880d80_private *priv = netdev_priv(netdev);
    u32 status = aic880d80_read32(priv, AIC880D80_REG_INT_STS);
    int handled = 0;

    if (status & AIC880D80_INT_RX_DONE) {
        napi_schedule(&priv->napi);
        handled = 1;
    }
    if (status & AIC880D80_INT_TX_DONE) {
        aic880d80_clean_tx_ring(priv);
        handled = 1;
    }
    aic880d80_write32(priv, AIC880D80_REG_INT_STS, status);
    return handled ? IRQ_HANDLED : IRQ_NONE;
}


int aic880d80_napi_poll(struct napi_struct *napi, int budget)
{
    struct aic880d80_private *priv = container_of(napi, struct aic880d80_private, napi);
    int work_done = 0;
    aic880d80_process_rx_ring(priv, budget);
    // Si se procesó menos que el budget, completar NAPI
    napi_complete_done(napi, work_done);
    aic880d80_alloc_rx_buffers(priv);
    return work_done;
}
