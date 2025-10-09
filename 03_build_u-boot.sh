#!/bin/bash

CORES=$(getconf _NPROCESSORS_ONLN)
wdir=`pwd`
CC=${CC:-"${wdir}/riscv-toolchain/bin/riscv64-linux-"}

cd ./u-boot/

if [ ! -f ./.patched ] ; then
	if [ -f configs/beaglev_fire_defconfig ] ; then
		git am ../patches/u-boot/0003-board-beagle-beaglev_fire-add-recovery-option.patch
	fi
	touch .patched
fi

make ARCH=riscv CROSS_COMPILE=${CC} distclean

make ARCH=riscv CROSS_COMPILE=${CC} beaglev_fire_defconfig
#make ARCH=riscv CROSS_COMPILE=${CC} menuconfig

./scripts/config --disable CONFIG_TOOLS_MKEFICAPSULE

make ARCH=riscv CROSS_COMPILE=${CC} olddefconfig

echo "make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} all"
make ARCH=riscv CROSS_COMPILE=${CC} all

cd ../

cp -v ./u-boot/u-boot.bin ./deploy/
cp -v ./u-boot/u-boot.bin ./deploy/src.bin

#
