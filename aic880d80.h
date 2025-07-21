/*
 * AIC semi AIC 880d80 Network Driver Header
 * 
 * Copyright (C) 2025 Zero Day Security Research
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 */

#ifndef _AIC880D80_H_
#define _AIC880D80_H_

#include <linux/types.h>
#include <linux/bitops.h>

/* Hardware identification */
#define AIC880D80_VENDOR_ID     0x1AE0  /* AIC semiconductor vendor ID */
#define AIC880D80_DEVICE_ID     0x880D  /* AIC 880d80 device ID */
#define AIC880D80_SUBSYS_ID     0x0001  /* Subsystem ID */

/* PCI Configuration Space */
#define AIC880D80_PCI_BAR0      0x10    /* Base Address Register 0 */
#define AIC880D80_PCI_BAR1      0x14    /* Base Address Register 1 */

/* Register Map - 4KB MMIO space */
#define AIC880D80_REG_DEVICE_ID     0x000   /* Device identification */
#define AIC880D80_REG_REVISION      0x004   /* Hardware revision */
#define AIC880D80_REG_CTRL          0x008   /* Global control */
#define AIC880D80_REG_STATUS        0x00C   /* Global status */
#define AIC880D80_REG_INT_ENABLE    0x010   /* Interrupt enable */
#define AIC880D80_REG_INT_STATUS    0x014   /* Interrupt status */
#define AIC880D80_REG_INT_CLEAR     0x018   /* Interrupt clear */
#define AIC880D80_REG_INT_MASK      0x01C   /* Interrupt mask */

/* MAC Address Registers */
#define AIC880D80_REG_MAC_ADDR_LO   0x020   /* MAC address low 32 bits */
#define AIC880D80_REG_MAC_ADDR_HI   0x024   /* MAC address high 16 bits */
#define AIC880D80_REG_MAC_CTRL      0x028   /* MAC control */
#define AIC880D80_REG_MAC_STATUS    0x02C   /* MAC status */

/* PHY Interface */
#define AIC880D80_REG_PHY_CTRL      0x030   /* PHY control */
#define AIC880D80_REG_PHY_STATUS    0x034   /* PHY status */
#define AIC880D80_REG_PHY_ID        0x038   /* PHY identifier */
#define AIC880D80_REG_LINK_STATUS   0x03C   /* Link status */

/* DMA Engine */
#define AIC880D80_REG_DMA_CTRL      0x040   /* DMA control */
#define AIC880D80_REG_DMA_STATUS    0x044   /* DMA status */
#define AIC880D80_REG_RX_DESC_LO    0x048   /* RX descriptor base low */
#define AIC880D80_REG_RX_DESC_HI    0x04C   /* RX descriptor base high */
#define AIC880D80_REG_TX_DESC_LO    0x050   /* TX descriptor base low */
#define AIC880D80_REG_TX_DESC_HI    0x054   /* TX descriptor base high */
#define AIC880D80_REG_RX_DESC_LEN   0x058   /* RX descriptor count */
#define AIC880D80_REG_TX_DESC_LEN   0x05C   /* TX descriptor count */

/* Queue Management */
#define AIC880D80_REG_RX_HEAD       0x060   /* RX queue head pointer */
#define AIC880D80_REG_RX_TAIL       0x064   /* RX queue tail pointer */
#define AIC880D80_REG_TX_HEAD       0x068   /* TX queue head pointer */
#define AIC880D80_REG_TX_TAIL       0x06C   /* TX queue tail pointer */

/* ARM64 Specific Optimizations */
#define AIC880D80_REG_ARM64_CTRL    0x100   /* ARM64 optimization control */
#define AIC880D80_REG_CACHE_CTRL    0x104   /* Cache coherency control */
#define AIC880D80_REG_PREFETCH      0x108   /* Prefetch control */
#define AIC880D80_REG_ALIGNMENT     0x10C   /* Memory alignment control */

/* Control Register Bits */
#define AIC880D80_CTRL_RESET        BIT(0)  /* Software reset */
#define AIC880D80_CTRL_ENABLE       BIT(1)  /* Device enable */
#define AIC880D80_CTRL_RX_ENABLE    BIT(2)  /* RX enable */
#define AIC880D80_CTRL_TX_ENABLE    BIT(3)  /* TX enable */
#define AIC880D80_CTRL_INT_ENABLE   BIT(4)  /* Global interrupt enable */
#define AIC880D80_CTRL_DMA_ENABLE   BIT(5)  /* DMA enable */
#define AIC880D80_CTRL_ARM64_OPT    BIT(16) /* ARM64 optimizations */
#define AIC880D80_CTRL_CACHE_COH    BIT(17) /* Cache coherency */
#define AIC880D80_CTRL_PREFETCH_EN  BIT(18) /* Prefetch enable */

/* Status Register Bits */
#define AIC880D80_STATUS_LINK_UP    BIT(0)  /* Link is up */
#define AIC880D80_STATUS_FULL_DUP   BIT(1)  /* Full duplex */
#define AIC880D80_STATUS_SPEED_MASK (0x7 << 2)  /* Speed mask */
#define AIC880D80_STATUS_SPEED_10   (0x0 << 2)  /* 10 Mbps */
#define AIC880D80_STATUS_SPEED_100  (0x1 << 2)  /* 100 Mbps */
#define AIC880D80_STATUS_SPEED_1000 (0x2 << 2)  /* 1 Gbps */
#define AIC880D80_STATUS_SPEED_2500 (0x3 << 2)  /* 2.5 Gbps */
#define AIC880D80_STATUS_SPEED_5000 (0x4 << 2)  /* 5 Gbps */
#define AIC880D80_STATUS_SPEED_10G  (0x5 << 2)  /* 10 Gbps */
#define AIC880D80_STATUS_RX_ACTIVE  BIT(8)  /* RX active */
#define AIC880D80_STATUS_TX_ACTIVE  BIT(9)  /* TX active */
#define AIC880D80_STATUS_DMA_ACTIVE BIT(10) /* DMA active */

/* Interrupt Bits */
#define AIC880D80_INT_RX_DONE       BIT(0)  /* RX completion */
#define AIC880D80_INT_TX_DONE       BIT(1)  /* TX completion */
#define AIC880D80_INT_RX_ERROR      BIT(2)  /* RX error */
#define AIC880D80_INT_TX_ERROR      BIT(3)  /* TX error */
#define AIC880D80_INT_LINK_CHANGE   BIT(4)  /* Link status change */
#define AIC880D80_INT_DMA_ERROR     BIT(5)  /* DMA error */
#define AIC880D80_INT_FIFO_ERROR    BIT(6)  /* FIFO error */
#define AIC880D80_INT_PHY_ERROR     BIT(7)  /* PHY error */

/* DMA Control Bits */
#define AIC880D80_DMA_ENABLE        BIT(0)  /* DMA enable */
#define AIC880D80_DMA_RESET         BIT(1)  /* DMA reset */
#define AIC880D80_DMA_RX_ENABLE     BIT(2)  /* RX DMA enable */
#define AIC880D80_DMA_TX_ENABLE     BIT(3)  /* TX DMA enable */
#define AIC880D80_DMA_64BIT         BIT(4)  /* 64-bit DMA addressing */
#define AIC880D80_DMA_COHERENT      BIT(5)  /* Coherent DMA */
#define AIC880D80_DMA_BURST_MASK    (0xF << 8)  /* Burst length mask */
#define AIC880D80_DMA_BURST_4       (0x2 << 8)  /* 4-word burst */
#define AIC880D80_DMA_BURST_8       (0x3 << 8)  /* 8-word burst */
#define AIC880D80_DMA_BURST_16      (0x4 << 8)  /* 16-word burst */
#define AIC880D80_DMA_BURST_32      (0x5 << 8)  /* 32-word burst */

/* ARM64 Cache Control Bits */
#define AIC880D80_CACHE_COHERENT    BIT(0)  /* Cache coherent */
#define AIC880D80_CACHE_LINE_64     BIT(1)  /* 64-byte cache line */
#define AIC880D80_CACHE_LINE_128    BIT(2)  /* 128-byte cache line */
#define AIC880D80_CACHE_PREFETCH    BIT(3)  /* Enable prefetch */
#define AIC880D80_CACHE_WRITEBACK   BIT(4)  /* Writeback cache */

/* Descriptor Flags */
#define AIC880D80_DESC_OWN          BIT(31) /* Descriptor owned by hardware */
#define AIC880D80_DESC_EOP          BIT(30) /* End of packet */
#define AIC880D80_DESC_SOP          BIT(29) /* Start of packet */
#define AIC880D80_DESC_INT          BIT(28) /* Generate interrupt */
#define AIC880D80_DESC_ERR          BIT(27) /* Error occurred */
#define AIC880D80_DESC_LEN_MASK     0xFFFF  /* Length mask */

/* Buffer and Ring Sizes */
#define AIC880D80_MAX_FRAME_SIZE    9216    /* Maximum frame size */
#define AIC880D80_MIN_FRAME_SIZE    64      /* Minimum frame size */
#define AIC880D80_RX_BUFFER_SIZE    2048    /* RX buffer size */
#define AIC880D80_TX_BUFFER_SIZE    2048    /* TX buffer size */
#define AIC880D80_RX_RING_SIZE      256     /* RX descriptor ring size */
#define AIC880D80_TX_RING_SIZE      256     /* TX descriptor ring size */
#define AIC880D80_MAX_RX_RINGS      8       /* Maximum RX rings */
#define AIC880D80_MAX_TX_RINGS      8       /* Maximum TX rings */

/* ARM64 Cache Line Sizes */
#define AIC880D80_CACHE_LINE_SIZE   64      /* Default ARM64 cache line */
#define AIC880D80_CACHE_LINE_MASK   (AIC880D80_CACHE_LINE_SIZE - 1)

/* DMA Descriptor Structure - ARM64 optimized */
struct aic880d80_desc {
    __le32 status;      /* Status and control flags */
    __le32 length;      /* Buffer length */
    __le64 buffer_addr; /* Buffer physical address */
    __le32 vlan_tag;    /* VLAN tag */
    __le32 reserved[3]; /* Reserved for future use */
} __packed __aligned(AIC880D80_CACHE_LINE_SIZE);

/* Statistics Structure */
struct aic880d80_stats {
    u64 rx_packets;
    u64 tx_packets;
    u64 rx_bytes;
    u64 tx_bytes;
    u64 rx_errors;
    u64 tx_errors;
    u64 rx_dropped;
    u64 tx_dropped;
    u64 rx_crc_errors;
    u64 rx_length_errors;
    u64 rx_fifo_errors;
    u64 tx_fifo_errors;
    u64 rx_missed_errors;
    u64 tx_aborted_errors;
    u64 tx_carrier_errors;
    u64 tx_window_errors;
    u64 rx_compressed;
    u64 tx_compressed;
};

/* Hardware Features */
#define AIC880D80_FEATURE_CSUM      BIT(0)  /* Hardware checksum */
#define AIC880D80_FEATURE_TSO       BIT(1)  /* TCP segmentation offload */
#define AIC880D80_FEATURE_VLAN      BIT(2)  /* VLAN support */
#define AIC880D80_FEATURE_JUMBO     BIT(3)  /* Jumbo frames */
#define AIC880D80_FEATURE_RSS       BIT(4)  /* Receive side scaling */
#define AIC880D80_FEATURE_LRO       BIT(5)  /* Large receive offload */
#define AIC880D80_FEATURE_ARM64_OPT BIT(16) /* ARM64 optimizations */

/* Power Management States */
#define AIC880D80_PM_D0             0       /* Full power */
#define AIC880D80_PM_D1             1       /* Low power */
#define AIC880D80_PM_D2             2       /* Lower power */
#define AIC880D80_PM_D3             3       /* Lowest power */

/* Debug and Error Codes */
#define AIC880D80_ERR_TIMEOUT       -1
#define AIC880D80_ERR_DMA_MAP       -2
#define AIC880D80_ERR_NO_MEMORY     -3
#define AIC880D80_ERR_INVALID_PARAM -4
#define AIC880D80_ERR_HW_FAILURE    -5

/* Inline accessors for register read/write */
static inline u32 aic880d80_read32(struct aic880d80_private *priv, u32 reg)
{
    return readl(priv->iobase + reg);
}
static inline void aic880d80_write32(struct aic880d80_private *priv, u32 reg, u32 val)
{
    writel(val, priv->iobase + reg);
}

/* MAC register aliases for compatibility */
#define AIC880D80_REG_MAC_LO   AIC880D80_REG_MAC_ADDR_LO
#define AIC880D80_REG_MAC_HI   AIC880D80_REG_MAC_ADDR_HI

/* Helper Macros */
#define AIC880D80_GET_SPEED(status) \
    (((status) & AIC880D80_STATUS_SPEED_MASK) >> 2)

#define AIC880D80_IS_LINK_UP(status) \
    ((status) & AIC880D80_STATUS_LINK_UP)

#define AIC880D80_IS_FULL_DUPLEX(status) \
    ((status) & AIC880D80_STATUS_FULL_DUP)

#define AIC880D80_DESC_SET_LEN(desc, len) \
    ((desc)->length = cpu_to_le32(len))

#define AIC880D80_DESC_GET_LEN(desc) \
    (le32_to_cpu((desc)->length) & AIC880D80_DESC_LEN_MASK)

#endif /* _AIC880D80_H_ */
