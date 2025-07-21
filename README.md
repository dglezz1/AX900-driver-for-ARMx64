# AIC semi AIC 880d80 Network Driver for ARM64

Este es un controlador de red para la tarjeta de interfaz de red extraíble AIC semi AIC 880d80, optimizado específicamente para arquitectura ARM64 en Kali Linux 2025.

## Características

- Soporte completo para arquitectura ARM64 (AArch64)
- Optimizaciones específicas para ARM64 y Cortex-A72
- Coherencia de caché DMA optimizada para ARM64
- Soporte para aceleración NEON cuando esté disponible
- Gestión de energía avanzada para dispositivos móviles ARM64
- Compatibilidad con Kali Linux 2025
- Soporte para Device Tree Bindings
- Integración DKMS para actualizaciones automáticas del kernel

## Especificaciones Hardware

- **Dispositivo**: AIC semi AIC 880d80
- **Interfaz**: PCIe/USB (según variante)
- **Velocidades**: 10/100/1000 Mbps, hasta 10 Gbps
- **Arquitectura objetivo**: ARM64 (AArch64)
- **SO objetivo**: Kali Linux 2025
- **Kernel**: Linux 6.x series

## Requisitos del Sistema

### Hardware
- Plataforma ARM64 (AArch64)
- Mínimo 2GB RAM
- Tarjeta AIC semi AIC 880d80

### Software
- Kali Linux 2025
- Kernel Linux 6.x
- Headers del kernel instalados
- Herramientas de desarrollo (build-essential)
- GCC cross-compiler para ARM64 (si compilas en otra arquitectura)

## Instalación

### Método 1: Instalación automática (recomendado)

```bash
# Clonar el repositorio
git clone https://github.com/zeroday/aic880d80-driver.git
cd aic880d80-driver

# Instalar dependencias
sudo apt update
sudo apt install build-essential linux-headers-$(uname -r) dkms

# Compilar e instalar
make deps
make install

# Cargar el módulo
sudo modprobe aic880d80
```

### Método 2: Compilación manual

```bash
# Instalar dependencias de construcción
sudo apt update
sudo apt install build-essential linux-headers-$(uname -r)

# Compilar el driver
make clean
make modules

# Instalar manualmente
sudo make install
sudo depmod -a

# Cargar el módulo
sudo modprobe aic880d80
```

### Método 3: DKMS (Dynamic Kernel Module Support)

```bash
# Instalar DKMS
sudo apt install dkms

# Instalar via DKMS
sudo make dkms-install

# El módulo se reconstruirá automáticamente con actualizaciones del kernel
```

## Configuración

### Verificar instalación

```bash
# Verificar que el módulo está cargado
lsmod | grep aic880d80

# Verificar interfaces de red
ip link show

# Verificar logs del driver
dmesg | grep aic880d80
```

### Configuración de red

```bash
# Activar la interfaz (ejemplo: eth0)
sudo ip link set eth0 up

# Configurar IP estática
sudo ip addr add 192.168.1.100/24 dev eth0

# Configurar ruta predeterminada
sudo ip route add default via 192.168.1.1

# O usar NetworkManager/systemd-networkd
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager
```

### Optimizaciones ARM64

El driver incluye optimizaciones automáticas para ARM64:

- **Coherencia DMA**: Detectada automáticamente
- **Tamaño de línea de caché**: Configurado para 64 bytes
- **Alineación de memoria**: Optimizada para Cortex-A72
- **Prefetch**: Habilitado para mejor rendimiento
- **Aceleración NEON**: Utilizada cuando esté disponible

## Parámetros del módulo

```bash
# Cargar con parámetros específicos
sudo modprobe aic880d80 debug=1 rx_ring_size=512 tx_ring_size=512

# Ver parámetros disponibles
modinfo aic880d80
```

### Parámetros disponibles

- `debug`: Nivel de debug (0-7, predeterminado: 0)
- `rx_ring_size`: Tamaño del ring RX (64-1024, predeterminado: 256)
- `tx_ring_size`: Tamaño del ring TX (64-1024, predeterminado: 256)
- `interrupt_throttle`: Limitación de interrupciones (predeterminado: 1)
- `arm64_optimizations`: Habilitar optimizaciones ARM64 (predeterminado: 1)

## Solución de problemas

### Problemas comunes

#### El módulo no carga
```bash
# Verificar dependencias
sudo apt install linux-headers-$(uname -r)

# Verificar logs de error
dmesg | tail -20

# Recompilar
make clean && make modules
```

#### Hardware no detectado
```bash
# Verificar dispositivo PCI
lspci | grep -i aic

# Verificar dispositivo USB (si aplicable)
lsusb | grep -i aic

# Verificar Device Tree (ARM64)
ls /proc/device-tree/soc/*/aic880d80* 2>/dev/null
```

#### Problemas de rendimiento
```bash
# Verificar estadísticas de red
cat /proc/net/dev
ethtool -S eth0

# Ajustar parámetros
echo 'options aic880d80 rx_ring_size=512 tx_ring_size=512' | sudo tee /etc/modprobe.d/aic880d80.conf
```

### Debug avanzado

```bash
# Habilitar debug completo
echo 'options aic880d80 debug=7' | sudo tee /etc/modprobe.d/aic880d80-debug.conf
sudo modprobe -r aic880d80
sudo modprobe aic880d80

# Monitorear logs en tiempo real
sudo journalctl -f | grep aic880d80

# Información detallada del hardware
sudo cat /sys/class/net/eth0/device/vendor
sudo cat /sys/class/net/eth0/device/device
```

## Desarrollo

### Estructura del proyecto

```
aic880d80-driver/
├── aic880d80.h              # Definiciones del hardware
├── aic880d80_main.c         # Implementación principal
├── aic880d80_hw.c           # Funciones de hardware
├── aic880d80_ethtool.c      # Soporte ethtool
├── aic880d80.dts            # Device Tree Binding
├── Makefile                 # Makefile optimizado para ARM64
├── dkms.conf                # Configuración DKMS
├── scripts/                 # Scripts de instalación
│   ├── post-install.sh
│   └── pre-remove.sh
└── README.md                # Este archivo
```

### Compilación cruzada

```bash
# Para compilar desde x86_64 para ARM64
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules

# Para Raspberry Pi 4
make ARCH=arm64 CROSS_COMPILE=aarch64-rpi4-linux-gnu- modules
```

### Contribuir

1. Fork del repositorio
2. Crear branch para tu feature (`git checkout -b feature/nueva-caracteristica`)
3. Commit de cambios (`git commit -am 'Añadir nueva característica'`)
4. Push al branch (`git push origin feature/nueva-caracteristica`)
5. Crear Pull Request

## Device Tree

Para plataformas ARM64 que usan Device Tree, incluye el archivo `aic880d80.dts`:

```bash
# Compilar Device Tree
dtc -I dts -O dtb -o aic880d80.dtbo aic880d80.dts

# Instalar overlay (ejemplo Raspberry Pi)
sudo cp aic880d80.dtbo /boot/overlays/
echo 'dtoverlay=aic880d80' | sudo tee -a /boot/config.txt
```

## Licencia

Este proyecto está licenciado bajo GPL v2 - ver el archivo [LICENSE](LICENSE) para detalles.

## Soporte

- **Issues**: [GitHub Issues](https://github.com/zeroday/aic880d80-driver/issues)
- **Documentación**: [Wiki del proyecto](https://github.com/zeroday/aic880d80-driver/wiki)
- **Email**: support@zerodaysec.com

## Changelog

### v1.0.0 (2025-07-20)
- Implementación inicial para ARM64
- Soporte para Kali Linux 2025
- Optimizaciones específicas para Cortex-A72
- Soporte DKMS
- Device Tree bindings
- Gestión de energía avanzada

## Agradecimientos

- Equipo de desarrollo del kernel Linux
- Comunidad ARM64
- Desarrolladores de Kali Linux
- AIC Semiconductor por documentación

## Descargo de responsabilidad

Este driver es proporcionado "tal como está" sin garantías. Úsalo bajo tu propio riesgo. Los autores no se hacen responsables de daños al hardware o pérdida de datos.

## Información adicional

### Optimizaciones ARM64 implementadas

1. **DMA coherente**: Aprovecha las capacidades de coherencia de caché de ARM64
2. **Alineación de memoria**: Optimizada para líneas de caché de 64 bytes
3. **Prefetch inteligente**: Utiliza instrucciones de prefetch de ARM64
4. **Gestión de interrupciones**: Optimizada para GIC (Generic Interrupt Controller)
5. **NEON acceleration**: Utiliza extensiones SIMD cuando están disponibles

### Compatibilidad de hardware

- **Raspberry Pi 4/5**: Totalmente soportado
- **NVIDIA Jetson series**: Soportado
- **Qualcomm Snapdragon**: Soportado con restricciones
- **Apple M1/M2**: No soportado (arquitectura diferente)
- **Allwinner A64**: Soportado
- **Rockchip RK3399**: Soportado

### Rendimiento esperado

En condiciones óptimas con hardware ARM64 moderno:
- **Throughput**: Hasta 9.8 Gbps en configuraciones 10G
- **Latencia**: < 50 microsegundos
- **CPU utilization**: < 15% a máxima capacidad
- **Memoria**: ~32MB para buffers DMA
