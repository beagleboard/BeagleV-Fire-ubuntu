# Weekly BUILDS for Debian 13 (trixie) and Ubuntu 24.04 (noble)

https://gitlab.com/RobertCNelson/beaglev-fire-ubuntu/-/artifacts

# Mirrors:

Main Mirror: https://github.com/beagleboard/BeagleV-Fire-ubuntu

Builds on every commit: https://openbeagle.org/beaglev-fire/BeagleV-Fire-ubuntu

Daily CI Builds: https://gitlab.com/RobertCNelson/beaglev-fire-ubuntu

# Build Depends

```
sudo apt update ;\
sudo apt-get install -y bison bmap-tools dosfstools genimage flex libelf-dev libyaml-dev mtools
```

# Building Microchip Linux tree

```
./01_git_sync.sh
./02_build_hss.sh
./03_build_u-boot.sh
./04_build_linux.sh
./05_generate_payload.bin.sh
sudo ./06_generate_debian_console_root.sh
sudo ./07_create_sdcard_img.sh
```

# Switching to Mainline Linux tree

```
./git_linux_mainline.sh
```

and rebuild:

```
./04_build_linux.sh
./05_generate_payload.bin.sh
sudo ./06_generate_debian_console_root.sh
sudo ./07_create_sdcard_img.sh
```

# Switching to Microchip Linux tree

```
./git_linux_mpfs.sh
```

and rebuild:

```
./04_build_linux.sh
./05_generate_payload.bin.sh
sudo ./06_generate_debian_console_root.sh
sudo ./07_create_sdcard_img.sh
```

# Programming

```
>> mmc
>> usbdmsc
```

# Flashing sdcard.img:

Use Balena or:

```
sudo bmaptool copy sdcard.img /dev/sde
```

# Deploy Kernel Updates

```
wget https://beaglev-fire.beagleboard.io/BeagleV-Fire-ubuntu/get_kernel_update.sh
chmod +x ./get_kernel_update.sh
sudo ./get_kernel_update.sh
```

# Notes

```
Module                  Size  Used by    Not tainted
mcp356x                49152  0 
industrialio          122880  1 mcp356x
imx219                 28672  0 
v4l2_fwnode            28672  1 imx219
v4l2_async             28672  2 imx219,v4l2_fwnode
```
