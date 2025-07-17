#!/bin/bash

GIT_DEPTH="20"
GCC_VERSION="11.4.0"

HSS_BRANCH="v2024.09"
HSS_REPO="https://github.com/polarfire-soc/hart-software-services.git"

#UBOOT_BRANCH="v2023.02-BeagleV-Fire"
#UBOOT_REPO="https://openbeagle.org/beaglev-fire/beaglev-fire-u-boot.git"
UBOOT_BRANCH="linux4microchip+fpga-2025.03"
UBOOT_REPO="https://github.com/linux4microchip/u-boot-mchp.git"

DT_BRANCH="v6.6.x-Beagle"
DT_REPO="https://github.com/beagleboard/BeagleBoard-DeviceTrees.git"
#DT_REPO="git@openbeagle.org:beagleboard/BeagleBoard-DeviceTrees.git"

LINUX_BRANCH="linux4microchip+fpga-2025.03"
LINUX_REPO="https://github.com/linux4microchip/linux.git"
#LINUX_REPO="https://openbeagle.org/beaglev-fire/beaglev-fire-linux.git"
#LINUX_REPO="git@openbeagle.org:beaglev-fire/beaglev-fire-linux.git"

#LINUX_BRANCH="master"
#LINUX_REPO="https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git"

if [ ! -f ./mirror/x86_64-gcc-${GCC_VERSION}-nolibc-riscv64-linux.tar.xz ] ; then
	echo "wget -c --directory-prefix=./mirror/ https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/${GCC_VERSION}/x86_64-gcc-${GCC_VERSION}-nolibc-riscv64-linux.tar.xz"
	wget -c --directory-prefix=./mirror/ https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/${GCC_VERSION}/x86_64-gcc-${GCC_VERSION}-nolibc-riscv64-linux.tar.xz
fi

if [ ! -f ./riscv-toolchain/bin/riscv64-linux-gcc-${GCC_VERSION} ] ; then
	echo "tar xf ./mirror/x86_64-gcc-${GCC_VERSION}-nolibc-riscv64-linux.tar.xz --strip-components=2 -C ./riscv-toolchain/"
	tar xf ./mirror/x86_64-gcc-${GCC_VERSION}-nolibc-riscv64-linux.tar.xz --strip-components=2 -C ./riscv-toolchain/
fi

if [ -d ./hart-software-services/ ] ; then
	rm -rf ./hart-software-services/ || true
fi

echo "git clone -b ${HSS_BRANCH} ${HSS_REPO} ./hart-software-services/ --depth=${GIT_DEPTH}"
git clone -b ${HSS_BRANCH} ${HSS_REPO} ./hart-software-services/ --depth=${GIT_DEPTH}

if [ -d ./u-boot ] ; then
	rm -rf ./u-boot || true
fi

echo "git clone -b ${UBOOT_BRANCH} ${UBOOT_REPO} ./u-boot/ --depth=${GIT_DEPTH}"
git clone -b ${UBOOT_BRANCH} ${UBOOT_REPO} ./u-boot/ --depth=${GIT_DEPTH}

if [ -d ./device-tree ] ; then
	rm -rf ./device-tree || true
fi

echo "git clone -b ${DT_BRANCH} ${DT_REPO} ./device-tree/ --depth=${GIT_DEPTH}"
git clone -b ${DT_BRANCH} ${DT_REPO} ./device-tree/ --depth=${GIT_DEPTH}

if [ -d ./linux ] ; then
	rm -rf ./linux || true
fi

echo "git clone -b ${LINUX_BRANCH} ${LINUX_REPO} ./linux/ --depth=${GIT_DEPTH}"
git clone --reference-if-able ~/linux-src/ -b ${LINUX_BRANCH} ${LINUX_REPO} ./linux/ --depth=${GIT_DEPTH}

#BUILDROOT_BRANCH="bvf"
#BUILDROOT_REPO="https://openbeagle.org/beaglev-fire/buildroot-external-microchip.git"
#
#if [ -d ./buildroot ] ; then
	#rm -rf ./buildroot || true
#fi
#
#echo "git clone -b ${BUILDROOT_BRANCH} ${BUILDROOT_REPO} ./buildroot/ --depth=${GIT_DEPTH}"
#git clone -b ${BUILDROOT_BRANCH} ${BUILDROOT_REPO} ./buildroot/ --depth=${GIT_DEPTH}

#
