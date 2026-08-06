#!/bin/bash

GIT_DEPTH="20"
GCC_VERSION="11.4.0"

#HSS stay in sync with gatware fpga builds...
HSS_BRANCH="v2025.07"
HSS_REPO="https://github.com/polarfire-soc/hart-software-services.git"
CI_HSS_REPO="https://forgejo.gfnd.rcn-ee.org:3000/Microchip/hart-software-services.git"

UBOOT_BRANCH="linux4microchip+fpga-2025.03"
UBOOT_REPO="https://github.com/linux4microchip/u-boot-mchp.git"
CI_UBOOT_REPO="https://forgejo.gfnd.rcn-ee.org:3000/Microchip/u-boot-mchp.git"

DT_BRANCH="v6.6.x-Beagle"
DT_REPO="https://github.com/beagleboard/BeagleBoard-DeviceTrees.git"

LINUX_BRANCH="linux4microchip+fpga-2025.03"
LINUX_REPO="https://github.com/linux4microchip/linux.git"
CI_LINUX_REPO="https://forgejo.gfnd.rcn-ee.org:3000/Microchip/linux.git"

if [[ ! -f .ci-debian-gcc ]] ; then
	if [ ! -f ./mirror/x86_64-gcc-${GCC_VERSION}-nolibc-riscv64-linux.tar.xz ] ; then
		echo "wget -c --directory-prefix=./mirror/ https://rcn-ee.net/mirror/crosstool/${GCC_VERSION}/x86_64-gcc-${GCC_VERSION}-nolibc-riscv64-linux.tar.xz"
		wget -c --directory-prefix=./mirror/ https://rcn-ee.net/mirror/crosstool/${GCC_VERSION}/x86_64-gcc-${GCC_VERSION}-nolibc-riscv64-linux.tar.xz
	fi

	if [ ! -f ./riscv-toolchain/bin/riscv64-linux-gcc-${GCC_VERSION} ] ; then
		echo "tar xf ./mirror/x86_64-gcc-${GCC_VERSION}-nolibc-riscv64-linux.tar.xz --strip-components=2 -C ./riscv-toolchain/"
		tar xf ./mirror/x86_64-gcc-${GCC_VERSION}-nolibc-riscv64-linux.tar.xz --strip-components=2 -C ./riscv-toolchain/
	fi
fi

if [ -d ./hart-software-services/ ] ; then
	rm -rf ./hart-software-services/ || true
fi

if [ -f .gitlab-runner ] ; then
	echo "git clone -b ${HSS_BRANCH} ${CI_HSS_REPO} ./hart-software-services/ --depth=5"
	git clone -b ${HSS_BRANCH} ${CI_HSS_REPO} ./hart-software-services/ --depth=5
else
	echo "git clone -b ${HSS_BRANCH} ${HSS_REPO} ./hart-software-services/ --depth=${GIT_DEPTH}"
	git clone -b ${HSS_BRANCH} ${HSS_REPO} ./hart-software-services/ --depth=${GIT_DEPTH}
fi

if [ -d ./u-boot ] ; then
	rm -rf ./u-boot || true
fi

if [ -f .gitlab-runner ] ; then
	echo "git clone -b ${UBOOT_BRANCH} ${CI_UBOOT_REPO} ./u-boot/ --depth=5"
	git clone -b ${UBOOT_BRANCH} ${CI_UBOOT_REPO} ./u-boot/ --depth=5
else
	echo "git clone -b ${UBOOT_BRANCH} ${UBOOT_REPO} ./u-boot/ --depth=${GIT_DEPTH}"
	git clone -b ${UBOOT_BRANCH} ${UBOOT_REPO} ./u-boot/ --depth=${GIT_DEPTH}
fi

if [ -d ./device-tree ] ; then
	rm -rf ./device-tree || true
fi

echo "git clone -b ${DT_BRANCH} ${DT_REPO} ./device-tree/ --depth=${GIT_DEPTH}"
git clone -b ${DT_BRANCH} ${DT_REPO} ./device-tree/ --depth=${GIT_DEPTH}

if [ -d ./linux ] ; then
	rm -rf ./linux || true
fi

if [ -f .gitlab-runner ] ; then
	echo "git clone -b ${LINUX_BRANCH} ${CI_LINUX_REPO} ./linux/ --depth=5"
	git clone --reference-if-able /opt/linux-src/ -b ${LINUX_BRANCH} ${CI_LINUX_REPO} ./linux/ --depth=5
else
	echo "git clone -b ${LINUX_BRANCH} ${LINUX_REPO} ./linux/ --depth=${GIT_DEPTH}"
	git clone --reference-if-able ~/linux-src/ -b ${LINUX_BRANCH} ${LINUX_REPO} ./linux/ --depth=${GIT_DEPTH}
fi

###
