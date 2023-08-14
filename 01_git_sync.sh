#!/bin/bash

HSS_BRANCH="v2023.02"
HSS_REPO="https://github.com/polarfire-soc/hart-software-services.git"

GIT_DEPTH="20"

if [ ! -f ./mirror/x86_64-gcc-13.2.0-nolibc-riscv64-linux.tar.xz ] ; then
	###FIXME, move to public when released...
	echo "wget -c --directory-prefix=./mirror/ https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/13.2.0/x86_64-gcc-13.2.0-nolibc-riscv64-linux.tar.xz"
	wget -c --directory-prefix=./mirror/ https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/13.2.0/x86_64-gcc-13.2.0-nolibc-riscv64-linux.tar.xz
fi

if [ ! -f ./riscv-toolchain/bin/riscv64-linux-gcc-13.2.0 ] ; then
	echo "tar xf ./mirror/x86_64-gcc-13.2.0-nolibc-riscv64-linux.tar.xz --strip-components=2 -C ./riscv-toolchain/"
	tar xf ./mirror/x86_64-gcc-13.2.0-nolibc-riscv64-linux.tar.xz --strip-components=2 -C ./riscv-toolchain/
fi

if [ -d ./hart-software-services/ ] ; then
	rm -rf ./hart-software-services/ || true
fi

echo "git clone -b ${HSS_BRANCH} ${HSS_REPO} ./hart-software-services/ --depth=${GIT_DEPTH}"
git clone -b ${HSS_BRANCH} ${HSS_REPO} ./hart-software-services/ --depth=${GIT_DEPTH}

exit 2


if [ -d ./opensbi ] ; then
	rm -rf ./opensbi || true
fi

echo "git clone -b ${OPENSBI_BRANCH} https://github.com/riscv-software-src/opensbi.git ./opensbi/ --depth=${GIT_DEPTH}"
git clone -b ${OPENSBI_BRANCH} https://github.com/riscv-software-src/opensbi.git ./opensbi/ --depth=${GIT_DEPTH}

if [ -d ./u-boot ] ; then
	rm -rf ./u-boot || true
fi

if [ -f ./.gitlab-runner ] ; then
	echo "git clone --reference-if-able /mnt/yocto-cache/git/beaglev-ahead-u-boot/ -b ${UBOOT_BRANCH} https://github.com/beagleboard/beaglev-ahead-u-boot.git ./u-boot/ --depth=1"
	git clone --reference-if-able /mnt/yocto-cache/git/beaglev-ahead-u-boot/ -b ${UBOOT_BRANCH} https://github.com/beagleboard/beaglev-ahead-u-boot.git ./u-boot/ --depth=1
else
	echo "git clone -b ${UBOOT_BRANCH} https://github.com/beagleboard/beaglev-ahead-u-boot.git ./u-boot/ --depth=${GIT_DEPTH}"
	git clone -b ${UBOOT_BRANCH} https://github.com/beagleboard/beaglev-ahead-u-boot.git ./u-boot/ --depth=${GIT_DEPTH}
fi

if [ -d ./BeagleBoard-DeviceTrees ] ; then
	rm -rf ./BeagleBoard-DeviceTrees || true
fi

echo "git clone -b ${DTB_BRANCH} https://git.beagleboard.org/beagleboard/BeagleBoard-DeviceTrees.git"
git clone -b ${DTB_BRANCH} https://git.beagleboard.org/beagleboard/BeagleBoard-DeviceTrees.git

if [ -d ./linux ] ; then
	rm -rf ./linux || true
fi

if [ -f ./.gitlab-runner ] ; then
	#echo "git clone --reference-if-able /mnt/yocto-cache/git/linux-src/ -b ${LINUX_BRANCH} https://github.com/beagleboard/linux.git ./linux/ --depth=${GIT_DEPTH}"
	#git clone --reference-if-able /mnt/yocto-cache/git/linux-src/ -b ${LINUX_BRANCH} https://github.com/beagleboard/linux.git ./linux/ --depth=${GIT_DEPTH}
	echo "git clone --reference-if-able /mnt/yocto-cache/git/linux-src/  https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git ./linux/ --depth=${GIT_DEPTH}"
	git clone --reference-if-able /mnt/yocto-cache/git/linux-src/  https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git ./linux/ --depth=${GIT_DEPTH}
else
	#echo "git clone -b ${LINUX_BRANCH} https://github.com/beagleboard/linux.git ./linux/ --depth=${GIT_DEPTH}"
	#git clone -b ${LINUX_BRANCH} https://github.com/beagleboard/linux.git ./linux/ --depth=${GIT_DEPTH}
	echo "git clone https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git ./linux/ --depth=${GIT_DEPTH}"
	git clone https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git ./linux/ --depth=${GIT_DEPTH}
fi

cd ./linux/
git pull --no-edit https://git.beagleboard.org/beaglev-ahead/linux.git v6.5-rc4-BeagleV-Ahead-dts-mmc-2 --no-rebase
cd ../

if [ -f ./.gitlab-runner ] ; then
	rm -f ./.gitlab-runner || true
fi

#
