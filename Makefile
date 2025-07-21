# Makefile for AIC semi AIC 880d80 Network Driver
# Optimized for ARM64 architecture on Kali Linux 2025

# Module information
MODULE_NAME := aic880d80
MODULE_VERSION := 1.0.0

# Object files
obj-m += $(MODULE_NAME).o
$(MODULE_NAME)-objs := aic880d80_main.o aic880d80_hw.o aic880d80_ethtool.o

# Kernel build directory detection
KERNEL_VERSION := $(shell uname -r)
KERNEL_DIR := /lib/modules/$(KERNEL_VERSION)/build
PWD := $(shell pwd)

# ARM64 specific compiler flags
ARCH := arm64
CROSS_COMPILE ?= aarch64-linux-gnu-

# Compiler optimization flags for ARM64
EXTRA_CFLAGS += -O2
EXTRA_CFLAGS += -march=armv8-a
EXTRA_CFLAGS += -mtune=cortex-a72
EXTRA_CFLAGS += -mcpu=cortex-a72
EXTRA_CFLAGS += -DCONFIG_ARM64
EXTRA_CFLAGS += -DAIC880D80_ARM64_OPTIMIZED
EXTRA_CFLAGS += -fno-strict-aliasing
EXTRA_CFLAGS += -fno-common
EXTRA_CFLAGS += -pipe
EXTRA_CFLAGS += -Wall
EXTRA_CFLAGS += -Wundef
EXTRA_CFLAGS += -Wstrict-prototypes
EXTRA_CFLAGS += -Wno-trigraphs
EXTRA_CFLAGS += -Werror-implicit-function-declaration
EXTRA_CFLAGS += -Wno-format-security
EXTRA_CFLAGS += -std=gnu89

# ARM64 cache optimizations
EXTRA_CFLAGS += -DAIC880D80_CACHE_LINE_SIZE=64
EXTRA_CFLAGS += -DAIC880D80_USE_NEON_OPTIMIZATION

# Debug flags (comment out for production)
# EXTRA_CFLAGS += -DDEBUG
# EXTRA_CFLAGS += -g

# Kali Linux specific paths
KALI_KERNEL_HEADERS := /usr/src/linux-headers-$(KERNEL_VERSION)
ifeq ($(wildcard $(KALI_KERNEL_HEADERS)),)
    KERNEL_DIR := /usr/src/linux-headers-$(KERNEL_VERSION)-common
endif

# Default target
all: modules

# Build kernel modules
modules:
	@echo "Building $(MODULE_NAME) driver for ARM64..."
	@echo "Kernel version: $(KERNEL_VERSION)"
	@echo "Kernel directory: $(KERNEL_DIR)"
	@echo "Architecture: $(ARCH)"
	$(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -C $(KERNEL_DIR) M=$(PWD) modules

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) clean
	rm -f *.o *.ko *.mod.c *.symvers *.order
	rm -f .*.cmd .tmp_versions
	rm -rf .tmp_versions/

# Install module
install: modules
	@echo "Installing $(MODULE_NAME) module..."
	sudo $(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -C $(KERNEL_DIR) M=$(PWD) modules_install
	sudo depmod -a
	@echo "Module installed successfully"

# Uninstall module
uninstall:
	@echo "Uninstalling $(MODULE_NAME) module..."
	sudo modprobe -r $(MODULE_NAME) 2>/dev/null || true
	sudo rm -f /lib/modules/$(KERNEL_VERSION)/extra/$(MODULE_NAME).ko
	sudo depmod -a
	@echo "Module uninstalled successfully"

# Load module
load: install
	@echo "Loading $(MODULE_NAME) module..."
	sudo modprobe $(MODULE_NAME)
	@echo "Module loaded successfully"
	@echo "Check dmesg for driver messages"

# Unload module
unload:
	@echo "Unloading $(MODULE_NAME) module..."
	sudo modprobe -r $(MODULE_NAME) || true
	@echo "Module unloaded"

# Check module status
status:
	@echo "Module status:"
	@lsmod | grep $(MODULE_NAME) || echo "Module not loaded"
	@echo ""
	@echo "Network interfaces:"
	@ip link show | grep -A1 -B1 $(MODULE_NAME) || echo "No interfaces found"

# Create distribution package
dist: clean
	@echo "Creating distribution package..."
	mkdir -p dist/$(MODULE_NAME)-$(MODULE_VERSION)
	cp -r *.c *.h Makefile README.md LICENSE dist/$(MODULE_NAME)-$(MODULE_VERSION)/
	cd dist && tar -czf $(MODULE_NAME)-$(MODULE_VERSION)-arm64.tar.gz $(MODULE_NAME)-$(MODULE_VERSION)
	@echo "Distribution package created: dist/$(MODULE_NAME)-$(MODULE_VERSION)-arm64.tar.gz"

# Development helpers
help:
	@echo "Available targets:"
	@echo "  all        - Build kernel modules (default)"
	@echo "  modules    - Build kernel modules"
	@echo "  clean      - Clean build artifacts"
	@echo "  install    - Install module to system"
	@echo "  uninstall  - Remove module from system"
	@echo "  load       - Install and load module"
	@echo "  unload     - Unload module"
	@echo "  status     - Show module and interface status"
	@echo "  dist       - Create distribution package"
	@echo "  debug      - Build with debug symbols"
	@echo "  test       - Run basic functionality tests"
	@echo "  help       - Show this help message"

# Debug build
debug:
	$(MAKE) EXTRA_CFLAGS="$(EXTRA_CFLAGS) -DDEBUG -g" modules

# Basic functionality test
test: load
	@echo "Running basic functionality tests..."
	@echo "Checking if module is loaded..."
	@lsmod | grep $(MODULE_NAME)
	@echo "Checking for PCI device..."
	@lspci | grep -i aic || echo "AIC device not found (expected if no hardware)"
	@echo "Checking kernel messages..."
	@dmesg | tail -20 | grep -i $(MODULE_NAME) || echo "No recent driver messages"
	@echo "Test completed"

# Cross-compilation support
CROSS_COMPILE_ARM64 := aarch64-linux-gnu-
cross-arm64:
	$(MAKE) ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE_ARM64) modules

# Kernel headers check
check-headers:
	@echo "Checking kernel headers..."
	@if [ -d "$(KERNEL_DIR)" ]; then \
		echo "Kernel headers found: $(KERNEL_DIR)"; \
		ls -la $(KERNEL_DIR)/include/linux/module.h 2>/dev/null || echo "Warning: module.h not found"; \
	else \
		echo "Error: Kernel headers not found at $(KERNEL_DIR)"; \
		echo "Please install kernel headers:"; \
		echo "  sudo apt update"; \
		echo "  sudo apt install linux-headers-\$$(uname -r)"; \
		exit 1; \
	fi

# Install dependencies
deps:
	@echo "Installing build dependencies for Kali Linux..."
	sudo apt update
	sudo apt install -y \
		build-essential \
		linux-headers-$(KERNEL_VERSION) \
		gcc-aarch64-linux-gnu \
		make \
		git \
		dkms

# DKMS support
dkms-install: dist
	@echo "Installing via DKMS..."
	sudo cp -r . /usr/src/$(MODULE_NAME)-$(MODULE_VERSION)
	sudo dkms add $(MODULE_NAME)/$(MODULE_VERSION)
	sudo dkms build $(MODULE_NAME)/$(MODULE_VERSION)
	sudo dkms install $(MODULE_NAME)/$(MODULE_VERSION)

dkms-remove:
	@echo "Removing DKMS module..."
	sudo dkms remove $(MODULE_NAME)/$(MODULE_VERSION) --all || true
	sudo rm -rf /usr/src/$(MODULE_NAME)-$(MODULE_VERSION)

# Check for required tools
check-tools:
	@echo "Checking required tools..."
	@which make > /dev/null || (echo "Error: make not found" && exit 1)
	@which gcc > /dev/null || (echo "Error: gcc not found" && exit 1)
	@echo "All required tools found"

# Phony targets
.PHONY: all modules clean install uninstall load unload status dist help debug test cross-arm64 check-headers deps dkms-install dkms-remove check-tools

# Additional ARM64 specific optimizations can be controlled via environment variables
# Example: make EXTRA_CFLAGS="-march=armv8.2-a+crypto" modules
