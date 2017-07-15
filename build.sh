#!/bin/bash

#if [[ $(grep "tar \${LIVE_IMAGE_NAME}-\${LIVE_IMAGE_ARCHITECTURE}." /usr/lib/live/build/binary_tar) ]]; then
#        sudo sed -s -i 's%tar ${LIVE_IMAGE_NAME}-${LIVE_IMAGE_ARCHITECTURE}.%tar binary%' /usr/lib/live/build/binary_tar
#fi

if ! mount | grep binfmt_misc;
then
	sudo mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
fi

#sudo sed -i 's|#!/bin/sh|#!/bin/sh -x|g' /usr/lib/live/build/*

sudo lb build
rm -rf live-image-armhf.tar.tar
pushd binary
sudo tar -cf ../rootfs.tar .
popd

CHIP_UBOOT_BRANCH=${CHIP_UBOOT_BRANCH:-ww/2016.01/next}

git clone https://github.com/nextthingco/chip-u-boot
pushd chip-u-boot

git checkout ${CHIP_UBOOT_BRANCH}

make ${UBOOT_EXTRA_OPTS} ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- CHIP_defconfig
make ${UBOOT_EXTRA_OPTS} ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-

