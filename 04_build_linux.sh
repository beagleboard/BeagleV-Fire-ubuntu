#!/bin/bash

CORES=$(getconf _NPROCESSORS_ONLN)
wdir=`pwd`
CC=${CC:-"${wdir}/riscv-toolchain/bin/riscv64-linux-"}

cd ./linux/

if [ ! -f ./.patched ] ; then
	if [ -f arch/riscv/configs/mpfs_defconfig ] ; then
		git am ../patches/linux/0008-Add-wireless-regdb-regulatory-database-file.patch
		git am ../patches/linux/0011-can-mpfs_can-add-registration-string.patch
		git am ../patches/linux/0012-gpio-gpio-mpfs-add-registration-string.patch
		git am ../patches/linux/0013-riscv-dts-microchip-remove-qspi-node-specifics.patch
	fi
	touch .patched
fi

echo "make ARCH=riscv CROSS_COMPILE=${CC} clean"
make ARCH=riscv CROSS_COMPILE=${CC} clean

if [ -f arch/riscv/configs/mpfs_defconfig ] ; then
	cp -v ../patches/linux/mpfs_defconfig ./arch/riscv/configs/mpfs_defconfig

	echo "make ARCH=riscv CROSS_COMPILE=${CC} mpfs_defconfig"
	make ARCH=riscv CROSS_COMPILE=${CC} mpfs_defconfig

	./scripts/config --set-str CONFIG_LOCALVERSION "-$(date +%Y%m%d)"
	./scripts/config --module CONFIG_IKHEADERS

	#enable CONFIG_DYNAMIC_FTRACE
	./scripts/config --enable CONFIG_FUNCTION_TRACER
	./scripts/config --enable CONFIG_DYNAMIC_FTRACE

	./scripts/config --disable CONFIG_MODULE_COMPRESS_ZSTD
	./scripts/config --enable CONFIG_MODULE_COMPRESS_XZ
	./scripts/config --enable CONFIG_GPIO_AGGREGATOR

	./scripts/config --enable CONFIG_CRYPTO_USER_API_HASH
	./scripts/config --enable CONFIG_CRYPTO_USER_API_SKCIPHER
	./scripts/config --enable CONFIG_KEY_DH_OPERATIONS
	./scripts/config --enable CONFIG_CRYPTO_ECB
	./scripts/config --enable CONFIG_CRYPTO_MD4
	./scripts/config --enable CONFIG_CRYPTO_MD5
	./scripts/config --enable CONFIG_CRYPTO_CBC
	./scripts/config --enable CONFIG_CRYPTO_SHA256
	./scripts/config --enable CONFIG_CRYPTO_AES
	./scripts/config --enable CONFIG_CRYPTO_DES
	./scripts/config --enable CONFIG_CRYPTO_CMAC
	./scripts/config --enable CONFIG_CRYPTO_HMAC
	./scripts/config --enable CONFIG_CRYPTO_SHA512
	./scripts/config --enable CONFIG_CRYPTO_SHA1

	#non-workable on RevA
	./scripts/config --disable CONFIG_VIDEO_IMX219

	./scripts/config --enable CONFIG_FW_LOADER_COMPRESS
	./scripts/config --enable CONFIG_FW_LOADER_COMPRESS_XZ
	./scripts/config --enable CONFIG_FW_LOADER_COMPRESS_ZSTD

	#Bump the number of default uarts allowed
	./scripts/config --set-val CONFIG_SERIAL_8250_NR_UARTS 8
	./scripts/config --set-val CONFIG_SERIAL_8250_RUNTIME_UARTS 8

	echo "make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} olddefconfig"
	make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} olddefconfig
else
	echo "make ARCH=riscv CROSS_COMPILE=${CC} defconfig"
	make ARCH=riscv CROSS_COMPILE=${CC} defconfig

	./scripts/config --enable CONFIG_PCIE_MICROCHIP_HOST

	./scripts/config --enable CONFIG_OF_OVERLAY
	./scripts/config --enable CONFIG_MODULE_COMPRESS_ZSTD

	./scripts/config --enable CONFIG_I2C
	./scripts/config --enable CONFIG_EEPROM_AT24
	./scripts/config --enable CONFIG_I2C_MICROCHIP_CORE

	./scripts/config --enable CONFIG_SPI_MICROCHIP_CORE
	./scripts/config --enable CONFIG_SPI_MICROCHIP_CORE_QSPI
	./scripts/config --module CONFIG_SPI_SPIDEV

	./scripts/config --enable CONFIG_GPIO_SYSFS

	./scripts/config --enable CONFIG_HW_RANDOM_POLARFIRE_SOC

	./scripts/config --enable CONFIG_USB_MUSB_HDRC
	./scripts/config --enable CONFIG_NOP_USB_XCEIV
	./scripts/config --enable CONFIG_USB_MUSB_POLARFIRE_SOC
	./scripts/config --enable CONFIG_USB_MUSB_DUAL_ROLE

	./scripts/config --enable CONFIG_MAILBOX
	./scripts/config --enable CONFIG_POLARFIRE_SOC_MAILBOX
	./scripts/config --disable CONFIG_SUN6I_MSGBOX

	./scripts/config --enable CONFIG_REMOTEPROC
	./scripts/config --enable CONFIG_REMOTEPROC_CDEV

	./scripts/config --enable CONFIG_POLARFIRE_SOC_SYS_CTRL

	./scripts/config --enable CONFIG_USB_GADGET
	./scripts/config --enable CONFIG_USB_CONFIGFS
	./scripts/config --enable CONFIG_CONFIGFS_FS
	./scripts/config --enable CONFIG_USB_CONFIGFS_SERIAL
	./scripts/config --enable CONFIG_USB_CONFIGFS_ACM
	./scripts/config --enable CONFIG_USB_CONFIGFS_OBEX
	./scripts/config --enable CONFIG_USB_CONFIGFS_NCM
	./scripts/config --enable CONFIG_USB_CONFIGFS_ECM
	./scripts/config --enable CONFIG_USB_CONFIGFS_ECM_SUBSET
	./scripts/config --enable CONFIG_USB_CONFIGFS_RNDIS
	./scripts/config --enable CONFIG_USB_CONFIGFS_EEM
	./scripts/config --enable CONFIG_USB_CONFIGFS_PHONET
	./scripts/config --enable CONFIG_USB_CONFIGFS_MASS_STORAGE
	./scripts/config --enable CONFIG_USB_CONFIGFS_F_LB_SS
	./scripts/config --enable CONFIG_USB_CONFIGFS_F_FS
	./scripts/config --enable CONFIG_USB_CONFIGFS_F_UAC1
	./scripts/config --enable CONFIG_USB_CONFIGFS_F_UAC2
	./scripts/config --enable CONFIG_USB_CONFIGFS_F_MIDI
	./scripts/config --enable CONFIG_USB_CONFIGFS_F_HID
	./scripts/config --enable CONFIG_USB_CONFIGFS_F_UVC
	./scripts/config --enable CONFIG_USB_CONFIGFS_F_PRINTER

	./scripts/config --module CONFIG_MEDIA_SUPPORT
	./scripts/config --enable CONFIG_MEDIA_SUPPORT_FILTER
	./scripts/config --enable CONFIG_MEDIA_SUBDRV_AUTOSELECT
	./scripts/config --enable CONFIG_MEDIA_CAMERA_SUPPORT
	./scripts/config --module CONFIG_VIDEO_IMX219

	./scripts/config --module CONFIG_IIO

	#Cleanup large DRM...
	./scripts/config --disable CONFIG_DRM
	./scripts/config --disable CONFIG_DRM_RADEON
	./scripts/config --disable CONFIG_DRM_NOUVEAU
	./scripts/config --disable CONFIG_DRM_SUN4I

	#Optimize:
	./scripts/config --enable CONFIG_IP_NF_IPTABLES
	./scripts/config --enable CONFIG_NETFILTER_XTABLES
	./scripts/config --enable CONFIG_NLS_ISO8859_1
	./scripts/config --enable CONFIG_BLK_DEV_DM

	./scripts/config --set-str CONFIG_LOCALVERSION "-$(date +%Y%m%d)"

	echo "make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} olddefconfig"
	make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} olddefconfig
fi

#echo "make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} menuconfig"
#make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} menuconfig
#exit 2

echo "make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} DTC_FLAGS=\"-@\" Image modules dtbs"
make -j${CORES} ARCH=riscv CROSS_COMPILE="ccache ${CC}" DTC_FLAGS="-@" Image modules dtbs

if [ ! -f ./arch/riscv/boot/Image ] ; then
	echo "Build Failed"
	exit 2
fi

KERNEL_UTS=$(cat "${wdir}/linux/include/generated/utsrelease.h" | awk '{print $3}' | sed 's/\"//g' )

if [ -d "${wdir}/deploy/tmp/" ] ; then
	rm -rf "${wdir}/deploy/tmp/"
fi
mkdir -p "${wdir}/deploy/tmp/"

make -s ARCH=riscv CROSS_COMPILE=${CC} modules_install INSTALL_MOD_PATH="${wdir}/deploy/tmp"

if [ -f "${wdir}/deploy/${KERNEL_UTS}-modules.tar.gz" ] ; then
	rm -rf "${wdir}/deploy/${KERNEL_UTS}-modules.tar.gz" || true
fi
echo "Compressing ${KERNEL_UTS}-modules.tar.gz..."
echo "${KERNEL_UTS}" > "${wdir}/deploy/.modules"
cd "${wdir}/deploy/tmp" || true
tar --create --gzip --file "../${KERNEL_UTS}-modules.tar.gz" ./*
cd "${wdir}/linux/" || exit
rm -rf "${wdir}/deploy/tmp" || true

if [ ! -d ../deploy/input/ ] ; then
	mkdir -p ../deploy/input/ || true
fi
cp -v ./arch/riscv/boot/Image ../deploy/input/
cp -v ./arch/riscv/boot/dts/microchip/mpfs-beaglev-fire.dtb ../deploy/input/

cd ../

cp -v ./patches/linux/beaglev_fire.its ./deploy/input/
cd ./deploy/input/
gzip -9 Image -c > Image.gz
if [ -f ../../u-boot/tools/mkimage ] ; then
	../../u-boot/tools/mkimage -f beaglev_fire.its beaglev_fire.itb
fi
#
