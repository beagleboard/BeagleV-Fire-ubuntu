#!/bin/bash

tar --zstd -xf ccache.tar.zst -C / || true
df -h /dev/shm
ccache -M 2G
ccache -sv
ccache -z
