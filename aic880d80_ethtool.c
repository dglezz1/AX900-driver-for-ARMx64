/*
 * aic880d80_ethtool.c - Ethtool support skeleton for AIC 880d80
 */
#include "aic880d80.h"
#include <linux/ethtool.h>

static void aic880d80_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *info)
{
    strlcpy(info->driver, "aic880d80", sizeof(info->driver));
    strlcpy(info->version, "1.0.0", sizeof(info->version));
    strlcpy(info->bus_info, pci_name(to_pci_dev(netdev->dev.parent)), sizeof(info->bus_info));
}

static int aic880d80_get_link(struct net_device *netdev)
{
    return netif_carrier_ok(netdev);
}

static int aic880d80_get_ringparam(struct net_device *netdev, struct ethtool_ringparam *ring)
{
    struct aic880d80_private *priv = netdev_priv(netdev);
    ring->rx_max_pending = AIC880D80_RX_RING_SIZE;
    ring->tx_max_pending = AIC880D80_TX_RING_SIZE;
    ring->rx_pending = priv->rx_ring ? AIC880D80_RX_RING_SIZE : 0;
    ring->tx_pending = priv->tx_ring ? AIC880D80_TX_RING_SIZE : 0;
    return 0;
}

static const struct ethtool_ops aic880d80_ethtool_ops = {
    .get_drvinfo    = aic880d80_get_drvinfo,
    .get_link       = aic880d80_get_link,
    .get_ringparam  = aic880d80_get_ringparam,
    // .get_strings, .get_ethtool_stats, etc. pueden agregarse después
};

void aic880d80_set_ethtool_ops(struct net_device *netdev)
{
    netdev->ethtool_ops = &aic880d80_ethtool_ops;
}
