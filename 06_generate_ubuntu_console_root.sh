#!/bin/bash

if ! id | grep -q root; then
	echo "./06_generate_ubuntu_console_root.sh must be run as root:"
	echo "sudo ./06_generate_ubuntu_console_root.sh"
	exit
fi

wdir=`pwd`

if [ -f /tmp/latest ] ; then
	rm -rf /tmp/latest | true
fi
wget --quiet --directory-prefix=/tmp/ https://rcn-ee.net/rootfs/ubuntu-riscv64-23.04-minimal/latest || true
if [ -f /tmp/latest ] ; then
	latest_rootfs=$(cat "/tmp/latest")
	datestamp=$(cat "/tmp/latest" | awk -F 'riscv64-' '{print $2}' | awk -F '.' '{print $1}')

	if [ ! -f ./deploy/ubuntu-23.04-console-riscv64-${datestamp}/riscv64-rootfs-ubuntu-lunar.tar ] ; then
		if [ -f ./.gitlab-runner ] ; then
			wget -c --directory-prefix=./deploy http://192.168.1.98/mirror/rcn-ee.us/rootfs/ubuntu-riscv64-23.04-minimal/${datestamp}/${latest_rootfs}
		else
			wget -c --directory-prefix=./deploy https://rcn-ee.net/rootfs/ubuntu-riscv64-23.04-minimal/${datestamp}/${latest_rootfs}
		fi
		cd ./deploy/
		tar xf ${latest_rootfs}
		cd ../
	fi
else
	echo "Failure: getting image"
	exit 2
fi

if [ -d ./ignore/.root ] ; then
	rm -rf ./ignore/.root || true
fi
mkdir -p ./ignore/.root

echo "Extracting: ubuntu-23.04-console-riscv64-${datestamp}/riscv64-rootfs-ubuntu-lunar.tar"
tar xfp ./deploy/ubuntu-23.04-console-riscv64-${datestamp}/riscv64-rootfs-ubuntu-lunar.tar -C ./ignore/.root
sync

mkdir -p ./deploy/input/ || true
cp -v ./deploy/boot.scr deploy/input/

echo "label Linux eMMC" > ./deploy/input/extlinux.conf
echo "    kernel /Image" >> ./deploy/input/extlinux.conf
#echo "    append root=/dev/mmcblk0p3 ro rootfstype=ext4 rootwait console=ttyS0,115200 earlycon uio_pdrv_genirq.of_id=generic-uio net.ifnames=0" >> ./deploy/input/extlinux.conf
echo "    fdtdir /" >> ./deploy/input/extlinux.conf
echo "    fdt /mpfs-beaglev-fire.dtb" >> ./deploy/input/extlinux.conf
echo "    #fdtoverlays /overlays/<file>.dtbo" >> ./deploy/input/extlinux.conf

#echo "extlinux/extlinux.conf"
#cat ./deploy/input/extlinux.conf

mkdir -p ./ignore/.root/boot/firmware/ || true

echo '/dev/mmcblk0p2  /boot/firmware/ auto  defaults  0  2' >> ./ignore/.root/etc/fstab
echo '/dev/mmcblk0p3  /  auto  errors=remount-ro  0  1' >> ./ignore/.root/etc/fstab
echo 'debugfs  /sys/kernel/debug  debugfs  mode=755,uid=root,gid=gpio,defaults  0  0' >> ./ignore/.root/etc/fstab

#Network-Manager, ignore eth1
#cp -v ./rootfs/etc/NetworkManager/conf.d/*.conf ./ignore/.root/etc/NetworkManager/conf.d/

cp -v ./ignore/.root/etc/bbb.io/templates/eth0-DHCP.network ./ignore/.root/etc/systemd/network/eth0.network || true
cp -v ./ignore/.root/etc/bbb.io/templates/eth1-DHCP.network ./ignore/.root/etc/systemd/network/eth1.network || true

# setuid root ping+ping6
chmod u+s ./ignore/.root/usr/bin/ping ./ignore/.root/usr/bin/ping6

#Default nginx export
rm -f ./ignore/.root/etc/nginx/sites-enabled/default || true
cp -v ./ignore/.root/etc/bbb.io/templates/nginx/nginx-autoindex ./ignore/.root/etc/nginx/sites-enabled/default
cp -v ./ignore/.root/etc/bbb.io/templates/nginx/*.html ./ignore/.root/var/www/html/
rm -f ./ignore/.root/var/www/html/index.nginx-debian.html || true

if [ -f ./deploy/.modules ] ; then
	version=$(cat ./deploy/.modules || true)
	if [ -f ./deploy/${version}-modules.tar.gz ] ; then
		tar xf ./deploy/${version}-modules.tar.gz -C ./ignore/.root/usr/
	fi
fi

echo '---------------------'
echo 'File Size'
du -sh ignore/.root/ || true
echo '---------------------'

dd if=/dev/zero of=./deploy/input/root.ext4 bs=1 count=0 seek=3800M
mkfs.ext4 -F ./deploy/input/root.ext4 -d ./ignore/.root

if [ -f ./.06_generate_root.sh ] ; then
	rm -f ./.06_generate_root.sh || true
fi
