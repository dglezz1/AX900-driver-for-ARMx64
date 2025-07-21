#!/bin/bash
#
# Pre-removal script for AIC semi AIC 880d80 driver
# Copyright (C) 2025 Zero Day Security Research
#

set -e

DRIVER_NAME="aic880d80"
LOG_FILE="/var/log/aic880d80-remove.log"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting removal of $DRIVER_NAME driver"

# Function to safely remove files
safe_remove() {
    if [ -f "$1" ]; then
        rm -f "$1"
        log "Removed: $1"
    fi
}

# Function to safely remove directories
safe_remove_dir() {
    if [ -d "$1" ]; then
        rm -rf "$1"
        log "Removed directory: $1"
    fi
}

# Stop and disable services
if systemctl is-active --quiet aic880d80-pm.service; then
    log "Stopping AIC 880d80 power management service..."
    systemctl stop aic880d80-pm.service
fi

if systemctl is-enabled --quiet aic880d80-pm.service; then
    log "Disabling AIC 880d80 power management service..."
    systemctl disable aic880d80-pm.service
fi

# Unload the module if it's loaded
if lsmod | grep -q "^$DRIVER_NAME"; then
    log "Unloading $DRIVER_NAME module..."
    
    # Bring down all AIC interfaces first
    for iface in $(ls /sys/class/net/ 2>/dev/null | grep aic || true); do
        if [ -d "/sys/class/net/$iface" ]; then
            log "Bringing down interface: $iface"
            ip link set "$iface" down 2>/dev/null || true
        fi
    done
    
    # Wait a moment for interfaces to go down
    sleep 2
    
    # Remove the module
    modprobe -r "$DRIVER_NAME" 2>/dev/null || {
        log "WARNING: Could not unload $DRIVER_NAME module (may be in use)"
        log "Please manually unload: sudo modprobe -r $DRIVER_NAME"
    }
fi

# Remove systemd service files
safe_remove "/etc/systemd/system/aic880d80-pm.service"

# Remove scripts
safe_remove "/usr/local/bin/aic880d80-optimize.sh"
safe_remove "/usr/local/bin/aic880d80-pm.sh"

# Remove udev rules
safe_remove "/etc/udev/rules.d/99-aic880d80.rules"

# Remove NetworkManager integration
safe_remove "/etc/NetworkManager/dispatcher.d/99-aic880d80"

# Remove modprobe configuration
safe_remove "/etc/modprobe.d/aic880d80.conf"

# Remove logrotate configuration
safe_remove "/etc/logrotate.d/aic880d80"

# Remove configuration directory (but preserve user configs)
CONFIG_DIR="/etc/aic880d80"
if [ -d "$CONFIG_DIR" ]; then
    # Check if there are user-modified files
    USER_CONFIGS=$(find "$CONFIG_DIR" -name "*.conf.local" -o -name "*.conf.user" 2>/dev/null | wc -l)
    
    if [ "$USER_CONFIGS" -gt 0 ]; then
        log "Preserving user configuration files in $CONFIG_DIR"
        safe_remove "$CONFIG_DIR/aic880d80.conf"
    else
        log "Removing configuration directory: $CONFIG_DIR"
        safe_remove_dir "$CONFIG_DIR"
    fi
fi

# Reload systemd daemon
systemctl daemon-reload

# Reload udev rules
if command -v udevadm >/dev/null 2>&1; then
    log "Reloading udev rules..."
    udevadm control --reload-rules
    udevadm trigger
fi

# Update module dependencies
if command -v depmod >/dev/null 2>&1; then
    log "Updating module dependencies..."
    depmod -a
fi

# Update initramfs if the module was included
if command -v update-initramfs >/dev/null 2>&1; then
    # Check if module was in initramfs
    if lsinitramfs /boot/initrd.img-$(uname -r) 2>/dev/null | grep -q "$DRIVER_NAME.ko"; then
        log "Updating initramfs to remove driver..."
        update-initramfs -u
    fi
fi

# Clean up any remaining device files
for dev in /dev/aic*; do
    if [ -e "$dev" ]; then
        log "Removing device file: $dev"
        rm -f "$dev"
    fi
done

# Clean up sysfs entries (they should be removed automatically, but just in case)
for sysfs in /sys/class/net/aic*; do
    if [ -L "$sysfs" ]; then
        log "Found stale sysfs entry: $sysfs"
        # Don't remove directly as it's managed by kernel
    fi
done

# Remove any cached firmware files
FIRMWARE_DIRS="/lib/firmware /usr/lib/firmware"
for fw_dir in $FIRMWARE_DIRS; do
    if [ -d "$fw_dir" ]; then
        find "$fw_dir" -name "*aic880d80*" -type f -delete 2>/dev/null || true
    fi
done

# Clean up any debug/trace files
safe_remove_dir "/sys/kernel/debug/aic880d80"
safe_remove_dir "/proc/driver/aic880d80"

# Reset any modified kernel parameters
SYSCTL_BACKUP="/etc/sysctl.d/99-aic880d80-backup.conf"
if [ -f "$SYSCTL_BACKUP" ]; then
    log "Restoring original sysctl parameters..."
    while IFS= read -r line; do
        if [[ "$line" =~ ^[^#]*= ]]; then
            sysctl -w "$line" 2>/dev/null || true
        fi
    done < "$SYSCTL_BACKUP"
    safe_remove "$SYSCTL_BACKUP"
fi

# Remove performance tuning files
safe_remove "/etc/sysctl.d/99-aic880d80.conf"

# Check for and warn about any remaining processes
AIC_PROCESSES=$(ps aux | grep -i aic880d80 | grep -v grep | wc -l)
if [ "$AIC_PROCESSES" -gt 0 ]; then
    log "WARNING: Found $AIC_PROCESSES processes still referencing aic880d80"
    log "You may need to reboot to completely remove all references"
fi

# Check for any remaining network namespaces with AIC interfaces
if command -v ip >/dev/null 2>&1; then
    for ns in $(ip netns list 2>/dev/null | awk '{print $1}'); do
        AIC_IN_NS=$(ip netns exec "$ns" ip link show 2>/dev/null | grep aic || true)
        if [ -n "$AIC_IN_NS" ]; then
            log "WARNING: Found AIC interfaces in network namespace: $ns"
            log "Manual cleanup may be required: ip netns exec $ns ip link delete <interface>"
        fi
    done
fi

# Final cleanup verification
if lsmod | grep -q "^$DRIVER_NAME"; then
    log "WARNING: Module $DRIVER_NAME is still loaded"
    log "Manual removal required: sudo modprobe -r $DRIVER_NAME"
else
    log "Module $DRIVER_NAME successfully unloaded"
fi

# Show removal summary
log "Removal process completed"
log "Removed files and configurations for $DRIVER_NAME"

echo ""
echo "=== AIC 880d80 Driver Removal Complete ==="
echo ""
echo "The driver and its configurations have been removed."
echo ""
echo "If you experience any issues:"
echo "1. Reboot the system to ensure clean removal"
echo "2. Check for any remaining references: lsmod | grep aic"
echo "3. Check logs: $LOG_FILE"
echo ""
echo "To reinstall the driver, run the installation process again."
echo ""

log "Pre-removal script completed successfully"

exit 0
