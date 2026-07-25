#!/bin/bash

if ! id | grep -q root; then
	echo "./07_create_sdcard_img.sh must be run as root:"
	echo "sudo ./07_create_sdcard_img.sh"
	exit
fi

cd ./deploy/
if [ ! -d ./root/ ] ; then
	mkdir ./root/ || true
fi

if [ -d ./tmp ] ; then
	rm -rf ./tmp || true
fi

if [ -f ./images/sdcard.img ] ; then
	rm -rf ./images/sdcard.img || true
fi

if [ -f ./images/sdcard.img.xz ] ; then
	rm -rf ./images/sdcard.img.xz || true
fi

echo "genimage --config genimage.cfg"
genimage --config genimage.cfg

if [ -d ./tmp ] ; then
	rm -rf ./tmp || true
fi

if [ ! -f ./images/sdcard.img ]; then
	echo "Error: ./images/sdcard.img was not generated"
	exit 2
fi

if [[ -f ../.gitlab-runner ]] ; then
	if [[ -f .datestamp ]] ; then
		datestamp=$(< .datestamp)
		image_name="beaglev-fire-debian-13-iot-v6.12-riscv64-${datestamp}-4gb"
		cp -v ./images/sdcard.img ./images/${image_name}.img
		TIME=${datestamp}
	else
		image_name="sdcard"
		TIME=$(date +%Y-%m-%d)
	fi
else
	image_name="sdcard"
	TIME=$(date +%Y-%m-%d)
fi

echo "- name: BeagleV-Fire Debian 13 v6.12.x" > ./images/${image_name}.img.xz.yml.txt
echo "  description: Debian 13 (Trixie) with no desktop environment for BeagleV-Fire based on Microchip Polarfire MPFS025T SoC FPGA running Microchip's linux 6.12" >> ./images/${image_name}.img.xz.yml.txt
echo "  icon: https://media.githubusercontent.com/media/beagleboard/bb-imager-rs/refs/heads/main/assets/os/debian.png" >> ./images/${image_name}.img.xz.yml.txt
echo "  url: https://files.beagle.cc/file/beagleboard-public-2021/images/${image_name}.img.xz" >> ./images/${image_name}.img.xz.yml.txt
if [ -f /usr/bin/bmaptool ] ; then
	echo "  bmap: https://raw.githubusercontent.com/beagleboard/distros/refs/heads/main/bmap-temp/${image_name}.bmap" >> ./images/${image_name}.img.xz.yml.txt
fi

extract_size=$(du -b ./images/${image_name}.img | awk '{print $1}')
echo "  extract_size: ${extract_size}" >> ./images/${image_name}.img.xz.yml.txt

extract_sha256=$(sha256sum ./images/${image_name}.img | awk '{print $1}')
echo "  extract_sha256: ${extract_sha256}" >> ./images/${image_name}.img.xz.yml.txt

if [ -f /usr/bin/bmaptool ] ; then
	if [ -f ./images/${image_name}.bmap ] ; then
		rm -rf ./images/${image_name}.bmap || true
	fi
	echo "bmaptool -d create -o ./images/${image_name}.bmap ./images/${image_name}.img"
	/usr/bin/bmaptool -d create -o ./images/${image_name}.bmap ./images/${image_name}.img
fi

echo "xz -T0 -z ./images/${image_name}.img"
xz -T0 -z ./images/${image_name}.img

if [ ! -f ./images/${image_name}.img.xz ]; then
	echo "Error: ./images/${image_name}.img.xz was not generated"
	exit 2
fi

image_download_size=$(du -b ./images/${image_name}.img.xz | awk '{print $1}')
echo "  image_download_size: ${image_download_size}" >> ./images/${image_name}.img.xz.yml.txt

image_download_sha256=$(sha256sum ./images/${image_name}.img.xz | awk '{print $1}')
echo "  image_download_sha256: ${image_download_sha256}" >> ./images/${image_name}.img.xz.yml.txt

echo "  release_date: '${TIME}'" >> ./images/${image_name}.img.xz.yml.txt
echo "  init_format: sysconf" >> ./images/${image_name}.img.xz.yml.txt
echo "  devices:" >> ./images/${image_name}.img.xz.yml.txt
echo "    - beaglev-fire" >> ./images/${image_name}.img.xz.yml.txt
echo "    - recommended" >> ./images/${image_name}.img.xz.yml.txt

#
