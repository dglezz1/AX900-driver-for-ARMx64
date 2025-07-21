/*
 * aic880d80_hw.c - Hardware functions skeleton for AIC 880d80
 */
#include "aic880d80.h"


int aic880d80_read_mac_address(struct aic880d80_private *priv, u8 *mac)
{
    u32 lo = aic880d80_read32(priv, AIC880D80_REG_MAC_LO);
    u32 hi = aic880d80_read32(priv, AIC880D80_REG_MAC_HI);
    mac[0] = lo & 0xFF;
    mac[1] = (lo >> 8) & 0xFF;
    mac[2] = (lo >> 16) & 0xFF;
    mac[3] = (lo >> 24) & 0xFF;
    mac[4] = hi & 0xFF;
    mac[5] = (hi >> 8) & 0xFF;
    return 0;
}


int aic880d80_set_mac_address(struct aic880d80_private *priv, const u8 *mac)
{
    u32 lo = mac[0] | (mac[1] << 8) | (mac[2] << 16) | (mac[3] << 24);
    u32 hi = mac[4] | (mac[5] << 8);
    aic880d80_write32(priv, AIC880D80_REG_MAC_LO, lo);
    aic880d80_write32(priv, AIC880D80_REG_MAC_HI, hi);
    return 0;
}
