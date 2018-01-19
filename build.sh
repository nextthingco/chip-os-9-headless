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

popd

git clone https://github.com/nextthingco/chip-tools
pushd chip-tools

sudo ./chip-create-nand-images.sh ../chip-u-boot ../rootfs.tar output
sudo chown -R 1000:1000 output
find output
#./chip-update-firmware.sh -L output

popd
