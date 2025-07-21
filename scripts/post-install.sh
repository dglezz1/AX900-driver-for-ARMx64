#!/bin/bash
#
# Post-installation script for AIC semi AIC 880d80 driver
# Copyright (C) 2025 Zero Day Security Research
#

set -e

DRIVER_NAME="aic880d80"
DRIVER_VERSION="1.0.0"
LOG_FILE="/var/log/aic880d80-install.log"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting post-installation for $DRIVER_NAME v$DRIVER_VERSION"

# Check if running on ARM64
if [ "$(uname -m)" != "aarch64" ]; then
    log "WARNING: This driver is optimized for ARM64 architecture"
    log "Current architecture: $(uname -m)"
fi

# Check Kali Linux version
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" == "kali" ]]; then
        log "Detected Kali Linux $VERSION_ID"
        if [[ "$VERSION_ID" != "2025"* ]]; then
            log "WARNING: This driver is optimized for Kali Linux 2025"
        fi
    else
        log "WARNING: This driver is optimized for Kali Linux"
        log "Detected: $PRETTY_NAME"
    fi
fi

# Create device configuration directory
CONFIG_DIR="/etc/aic880d80"
if [ ! -d "$CONFIG_DIR" ]; then
    mkdir -p "$CONFIG_DIR"
    log "Created configuration directory: $CONFIG_DIR"
fi

# Create default configuration file
cat > "$CONFIG_DIR/aic880d80.conf" << 'EOF'
# AIC semi AIC 880d80 Driver Configuration
# ARM64 optimizations

# Module parameters
options aic880d80 debug=0
options aic880d80 rx_ring_size=256
options aic880d80 tx_ring_size=256
options aic880d80 interrupt_throttle=1
options aic880d80 arm64_optimizations=1

# Network interface naming
# Uncomment to use predictable interface names
# options aic880d80 interface_name=aic%d

# Power management
options aic880d80 power_management=1

# ARM64 specific optimizations
options aic880d80 cache_coherent=auto
options aic880d80 neon_acceleration=auto
options aic880d80 prefetch_enabled=1

# Performance tuning for ARM64
options aic880d80 burst_length=16
options aic880d80 dma_coherency=1
options aic880d80 interrupt_coalescing=1
EOF

# Copy module configuration to modprobe.d
cp "$CONFIG_DIR/aic880d80.conf" "/etc/modprobe.d/aic880d80.conf"
log "Installed module configuration"

# Create udev rules for device management
cat > "/etc/udev/rules.d/99-aic880d80.rules" << 'EOF'
# AIC semi AIC 880d80 USB/PCIe Network Device Rules

# USB variant
SUBSYSTEM=="usb", ATTR{idVendor}=="1ae0", ATTR{idProduct}=="880d", \
    MODE="0664", GROUP="netdev", TAG+="systemd"

# PCIe variant
SUBSYSTEM=="pci", ATTR{vendor}=="0x1ae0", ATTR{device}=="0x880d", \
    MODE="0664", GROUP="netdev", TAG+="systemd"

# Network interface naming
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="aic880d80", \
    NAME="aic%n"

# Power management
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="aic880d80", \
    ATTR{power/control}="auto", ATTR{power/autosuspend_delay_ms}="5000"

# ARM64 specific optimizations
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="aic880d80", \
    RUN+="/usr/local/bin/aic880d80-optimize.sh %k"
EOF

log "Installed udev rules"

# Create optimization script for ARM64
cat > "/usr/local/bin/aic880d80-optimize.sh" << 'EOF'
#!/bin/bash
#
# ARM64 optimization script for AIC 880d80 network interface
#

INTERFACE="$1"

if [ -z "$INTERFACE" ]; then
    echo "Usage: $0 <interface>"
    exit 1
fi

# Wait for interface to be ready
sleep 2

# Check if interface exists
if [ ! -d "/sys/class/net/$INTERFACE" ]; then
    echo "Interface $INTERFACE not found"
    exit 1
fi

echo "Optimizing $INTERFACE for ARM64..."

# Set optimal ring buffer sizes for ARM64
ethtool -G "$INTERFACE" rx 512 tx 512 2>/dev/null || true

# Enable hardware offloading features
ethtool -K "$INTERFACE" gso on gro on tso on 2>/dev/null || true
ethtool -K "$INTERFACE" rx-checksum on tx-checksum-ip-generic on 2>/dev/null || true

# Set interrupt coalescing for ARM64
ethtool -C "$INTERFACE" rx-usecs 50 rx-frames 64 2>/dev/null || true
ethtool -C "$INTERFACE" tx-usecs 50 tx-frames 64 2>/dev/null || true

# Set optimal buffer sizes
echo 2097152 > /proc/sys/net/core/rmem_max 2>/dev/null || true
echo 2097152 > /proc/sys/net/core/wmem_max 2>/dev/null || true

# ARM64 specific CPU affinity (if multiple cores available)
CORES=$(nproc)
if [ "$CORES" -gt 1 ]; then
    # Distribute interrupts across available cores
    IRQ=$(cat /proc/interrupts | grep "$INTERFACE" | awk '{print $1}' | tr -d ':')
    if [ -n "$IRQ" ]; then
        echo 2 > "/proc/irq/$IRQ/smp_affinity" 2>/dev/null || true
    fi
fi

echo "ARM64 optimization completed for $INTERFACE"
EOF

chmod +x "/usr/local/bin/aic880d80-optimize.sh"
log "Created ARM64 optimization script"

# Create systemd service for advanced power management
cat > "/etc/systemd/system/aic880d80-pm.service" << 'EOF'
[Unit]
Description=AIC 880d80 Power Management Service
After=network.target
Wants=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/bin/aic880d80-pm.sh start
ExecStop=/usr/local/bin/aic880d80-pm.sh stop
User=root

[Install]
WantedBy=multi-user.target
EOF

# Create power management script
cat > "/usr/local/bin/aic880d80-pm.sh" << 'EOF'
#!/bin/bash
#
# Power management script for AIC 880d80 on ARM64
#

case "$1" in
    start)
        echo "Starting AIC 880d80 power management..."
        
        # Enable runtime PM for AIC devices
        for dev in /sys/bus/pci/devices/*/; do
            if [ -f "$dev/vendor" ] && [ "$(cat "$dev/vendor")" = "0x1ae0" ]; then
                echo auto > "$dev/power/control" 2>/dev/null || true
            fi
        done
        
        # Set conservative power policy for ARM64
        for iface in $(ls /sys/class/net/ | grep aic); do
            if [ -f "/sys/class/net/$iface/device/power/control" ]; then
                echo auto > "/sys/class/net/$iface/device/power/control"
            fi
        done
        ;;
        
    stop)
        echo "Stopping AIC 880d80 power management..."
        
        # Disable runtime PM
        for dev in /sys/bus/pci/devices/*/; do
            if [ -f "$dev/vendor" ] && [ "$(cat "$dev/vendor")" = "0x1ae0" ]; then
                echo on > "$dev/power/control" 2>/dev/null || true
            fi
        done
        ;;
        
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
EOF

chmod +x "/usr/local/bin/aic880d80-pm.sh"
log "Created power management service"

# Enable and start the power management service
systemctl daemon-reload
systemctl enable aic880d80-pm.service
systemctl start aic880d80-pm.service

# Reload udev rules
udevadm control --reload-rules
udevadm trigger

# Update initramfs if needed
if command -v update-initramfs >/dev/null 2>&1; then
    log "Updating initramfs..."
    update-initramfs -u
fi

# Create desktop integration for NetworkManager (if available)
if command -v nmcli >/dev/null 2>&1; then
    log "NetworkManager detected, creating integration..."
    
    # Create NetworkManager dispatcher script
    cat > "/etc/NetworkManager/dispatcher.d/99-aic880d80" << 'EOF'
#!/bin/bash
#
# NetworkManager dispatcher script for AIC 880d80
#

INTERFACE="$1"
ACTION="$2"

# Only act on AIC interfaces
if [[ "$INTERFACE" != aic* ]]; then
    exit 0
fi

case "$ACTION" in
    up)
        # Apply ARM64 optimizations when interface comes up
        /usr/local/bin/aic880d80-optimize.sh "$INTERFACE"
        logger "AIC 880d80: Applied ARM64 optimizations to $INTERFACE"
        ;;
    down)
        logger "AIC 880d80: Interface $INTERFACE went down"
        ;;
esac
EOF
    
    chmod +x "/etc/NetworkManager/dispatcher.d/99-aic880d80"
    log "Created NetworkManager integration"
fi

# Create logrotate configuration
cat > "/etc/logrotate.d/aic880d80" << 'EOF'
/var/log/aic880d80*.log {
    weekly
    missingok
    rotate 4
    compress
    delaycompress
    notifempty
    sharedscripts
    postrotate
        /usr/bin/systemctl reload rsyslog > /dev/null 2>&1 || true
    endscript
}
EOF

log "Created log rotation configuration"

# Show installation summary
log "Installation completed successfully!"
log "Driver: $DRIVER_NAME v$DRIVER_VERSION"
log "Architecture: $(uname -m)"
log "Kernel: $(uname -r)"
log "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '\"')"

echo ""
echo "=== AIC 880d80 Driver Installation Complete ==="
echo ""
echo "Next steps:"
echo "1. Connect your AIC 880d80 device"
echo "2. Load the driver: sudo modprobe aic880d80"
echo "3. Check status: lsmod | grep aic880d80"
echo "4. Configure network: sudo ip link set <interface> up"
echo ""
echo "For more information, see: /usr/share/doc/aic880d80/"
echo "Configuration: $CONFIG_DIR/"
echo "Logs: $LOG_FILE"
echo ""

exit 0
