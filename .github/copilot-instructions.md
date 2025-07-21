<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Linux Kernel Driver Development for AIC semi AIC 880d80

This is a Linux kernel driver project for the AIC semi AIC 880d80 network interface card (NIC) targeting ARM64 architecture on Kali Linux 2025.

## Project Guidelines

- Follow Linux kernel coding style and conventions
- Use proper memory management and error handling
- Implement ARM64-specific optimizations where applicable
- Include proper device tree bindings for ARM64 platforms
- Ensure compatibility with Kali Linux 2025 kernel version
- Use modern kernel APIs and avoid deprecated functions
- Include comprehensive error handling and logging
- Follow GPL-2.0 licensing for kernel modules
- Implement proper network device operations
- Include power management support for mobile ARM64 devices

## Architecture Specifics

- Target: ARM64 (aarch64)
- OS: Kali Linux 2025
- Kernel: Linux 6.x series
- Device: AIC semi AIC 880d80 network card
- Interface: PCIe/USB (depending on card variant)

## Code Quality

- Use kernel documentation style comments
- Include proper MODULE_* macros
- Implement proper probe/remove functions
- Use devm_* managed device functions where possible
- Include proper DMA handling for ARM64
- Implement interrupt handling with proper synchronization
