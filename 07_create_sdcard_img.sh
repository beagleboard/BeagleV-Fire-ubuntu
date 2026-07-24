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

genimage --config genimage.cfg

if [ -d ./tmp ] ; then
	rm -rf ./tmp || true
fi

if [ ! -f ./images/sdcard.img ]; then
	echo "Error: ./images/sdcard.img was not generated"
	exit 2
fi

if [[ -f .gitlab-runner ]] ; then
	if [[ -f .datestamp ]] ; then
		datestamp=$(< .datestamp)
		image_name="beaglev-fire-debian-13-iot-v6.6-riscv64-${datestamp}-4gb"
	else
		image_name="sdcard"
	fi
else
	image_name="sdcard"
fi

extract_size=$(du -b ./images/${image_name}.img | awk '{print $1}')
echo "  extract_size: ${extract_size}" > ./images/image.yml.txt

extract_sha256=$(sha256sum ./images/${image_name}.img | awk '{print $1}')
echo "  extract_sha256: ${extract_sha256}" >> ./images/image.yml.txt

if [ -f /usr/bin/bmaptool ] ; then
	if [ -f ./images/${image_name}.bmap ] ; then
		rm -rf ./images/${image_name}.bmap || true
	fi
	/usr/bin/bmaptool -d create -o ./images/${image_name}.bmap ./images/${image_name}.img
fi

xz -T0 -z ./images/${image_name}.img

if [ ! -f ./images/${image_name}.img.xz ]; then
	echo "Error: ./images/${image_name}.img.xz was not generated"
	exit 2
fi

image_download_size=$(du -b ./images/${image_name}.img.xz | awk '{print $1}')
echo "  image_download_size: ${image_download_size}" >> ./images/image.yml.txt

image_download_sha256=$(sha256sum ./images/${image_name}.img.xz | awk '{print $1}')
echo "  image_download_sha256: ${image_download_sha256}" >> ./images/image.yml.txt

TIME=$(date +%Y-%m-%d)

echo "  release_date: '${TIME}'" >> ./images/image.yml.txt
echo "  init_format: sysconf" >> ./images/image.yml.txt

#
