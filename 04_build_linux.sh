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

		git am ../patches/linux/6.12.85/b4-crypto/0001-sync-crypto-authencesn.c-with-v6.12.84.patch
		git am ../patches/linux/6.12.85/crypto/0001-crypto-scatterwalk-Backport-memcpy_sglist.patch
		git am ../patches/linux/6.12.85/crypto/0002-crypto-algif_aead-use-memcpy_sglist-instead-of-null-.patch
		git am ../patches/linux/6.12.85/crypto/0003-crypto-algif_aead-Revert-to-operating-out-of-place.patch
		git am ../patches/linux/6.12.85/crypto/0004-crypto-algif_aead-snapshot-IV-for-async-AEAD-request.patch
		git am ../patches/linux/6.12.85/crypto/0005-crypto-authenc-use-memcpy_sglist-instead-of-null-skc.patch
		git am ../patches/linux/6.12.85/crypto/0006-crypto-authencesn-Do-not-place-hiseq-at-end-of-dst-f.patch
		git am ../patches/linux/6.12.85/crypto/0007-crypto-authencesn-Fix-src-offset-when-decrypting-in-.patch
		git am ../patches/linux/6.12.85/crypto/0008-crypto-af_alg-Fix-page-reassignment-overflow-in-af_a.patch

		git am ../patches/linux/6.12.87/0001-xfrm-esp-avoid-in-place-decrypt-on-shared-skb-frags.patch

		git am ../patches/linux/6.12.89/0001-ptrace-slightly-saner-get_dumpable-logic.patch
	fi
	touch .patched
fi

echo "make ARCH=riscv CROSS_COMPILE=${CC} clean"
make ARCH=riscv CROSS_COMPILE=${CC} clean

if [ -f arch/riscv/configs/mpfs_defconfig ] ; then
	make ARCH=riscv CROSS_COMPILE=${CC} mpfs_defconfig
	make ARCH=riscv CROSS_COMPILE=${CC} olddefconfig

	### We use mpfs_defconfig as the base, keep track of Microchip config changes
	cp -v .config ../patches/linux/mpfs_defconfig

	./scripts/config --set-str CONFIG_LOCALVERSION "-$(date +%Y%m%d)"
	./scripts/config --module CONFIG_IKHEADERS

	#enable CONFIG_DYNAMIC_FTRACE
	./scripts/config --enable CONFIG_FUNCTION_TRACER
	./scripts/config --enable CONFIG_DYNAMIC_FTRACE

	./scripts/config --disable CONFIG_MODULE_COMPRESS_ZSTD
	./scripts/config --enable CONFIG_MODULE_COMPRESS_XZ

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

	#
	# Firmware loader
	#
	./scripts/config --set-str CONFIG_EXTRA_FIRMWARE "regulatory.db regulatory.db.p7s"
	./scripts/config --set-str CONFIG_EXTRA_FIRMWARE_DIR "firmware"

	./scripts/config --enable CONFIG_FW_LOADER_COMPRESS
	./scripts/config --enable CONFIG_FW_LOADER_COMPRESS_XZ
	./scripts/config --enable CONFIG_FW_LOADER_COMPRESS_ZSTD

	#
	# Serial drivers
	#
	./scripts/config --set-val CONFIG_SERIAL_8250_NR_UARTS 8
	./scripts/config --set-val CONFIG_SERIAL_8250_RUNTIME_UARTS 8

	#
	# Virtual GPIO drivers
	#
	./scripts/config --enable CONFIG_GPIO_AGGREGATOR
	./scripts/config --module CONFIG_GPIO_LATCH

	#
	# Extcon Device Drivers
	#
	./scripts/config --enable CONFIG_IIO_BUFFER
	./scripts/config --enable CONFIG_IIO_TRIGGER
	./scripts/config --module CONFIG_IIO_TRIGGERED_EVENT

	#
	# Security options
	#
	./scripts/config --enable CONFIG_ENCRYPTED_KEYS
	./scripts/config --enable CONFIG_KEY_DH_OPERATIONS
	./scripts/config --enable CONFIG_SECURITY
	./scripts/config --enable CONFIG_SECURITYFS
	./scripts/config --enable CONFIG_HARDENED_USERCOPY
	./scripts/config --enable CONFIG_FORTIFY_SOURCE

	# end of RCU Debugging
	./scripts/config --disable CONFIG_SAMPLES
	./scripts/config --disable CONFIG_STRICT_DEVMEM

	#
	# Kernel Testing and Coverage
	#
	./scripts/config --disable CONFIG_RUNTIME_TESTING_MENU
	./scripts/config --enable CONFIG_MEMTEST

	"Config: Backup our custom linux/beaglev-fire_defconfig"
	make ARCH=riscv CROSS_COMPILE=${CC} olddefconfig
	cp -v .config ../patches/linux/beaglev-fire_defconfig
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
