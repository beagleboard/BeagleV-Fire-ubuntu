#!/bin/bash

kernel_version=$(uname -r)

kernel_major_minor=$(echo "$kernel_version" | cut -d '.' -f 1,2)

if ! id | grep -q root; then
	echo "must be run as root"
	exit
fi

if [ -d $1 ]
then
	echo "Changing gateware."
	if [ -e $1/LinuxProgramming/mpfs_bitstream.spi ]
	then
		if [ "$kernel_major_minor" == "6.1" ]; then
			cp -v $1/LinuxProgramming/mpfs_dtbo.spi /lib/firmware/mpfs_dtbo.spi
			cp -v $1/LinuxProgramming/mpfs_bitstream.spi /lib/firmware/mpfs_bitstream.spi
			sync
			source /usr/share/microchip/gateware/update-gateware-6-1.sh $1/LinuxProgramming
		else
			source /usr/share/microchip/gateware/update-gateware.sh $1/LinuxProgramming
		fi
	else
		echo "No xxx gateware file found."
	fi
else
	echo "No directory found for this requested gateware."
fi
