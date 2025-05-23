#!/bin/bash

if ! id | grep -q root; then
	echo "must be run as root"
	exit
fi

if [ -d $1 ]
then
    echo "Changing gateware."
    if [ -e $1/mpfs_bitstream.spi ]
    then
        if [ -e $1/mpfs_dtbo.spi ]
        then
            cp -v $1/mpfs_dtbo.spi /lib/firmware/mpfs_dtbo.spi
            cp -v $1/mpfs_bitstream.spi /lib/firmware/mpfs_bitstream.spi
            sync
            . /etc/microchip/update-gateware.sh
        else
            echo "No device tree overlay file found."
        fi
    else
        echo "No gateware file found."
    fi
else
    echo "No directory found for this requested gateware."
fi
