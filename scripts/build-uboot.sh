#!/bin/bash
set -e
pushd $WORK
# cleanup the previous build
./cleanup-uboot.sh
# build u-boot
pushd uboot/
make -j4
# build default boot script
tools/mkimage -A arm -T script -d $WORK/acs/$TARGET/uboot/boot.cmd $WORK/boot/boot.scr
popd
# copy to boot directory
./copy-uboot.sh
cp uboot/.config boot/.config-uboot
popd
