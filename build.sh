#!/bin/bash

if ! mount | grep binfmt_misc;
then
	sudo mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
fi

sudo lb build
rm -rf live-image-armhf.tar.tar rootfs.tar
pushd binary
sudo rm -rf live md5sum.txt
sudo tar -cf ../rootfs.tar .
popd

CHIP_UBOOT_BRANCH=${CHIP_UBOOT_BRANCH:-production-mlc}

git clone https://github.com/nextthingco/chip-u-boot
pushd chip-u-boot

git checkout ${CHIP_UBOOT_BRANCH}
git apply ../0001-compiler-.h-sync-include-linux-compiler-.h-with-Linu.patch

make ${UBOOT_EXTRA_OPTS} ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- CHIP_defconfig
make ${UBOOT_EXTRA_OPTS} ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-

## To create image/flash:
##
## sudo ./chip-create-nand-image.sh ../chip-pro-debian-9/chip-u-boot ../chip-pro-debian-9/rootfs.tar output
## sudo chown -R $USER:$USER output
## ./chip-update-firmware.sh -L output
