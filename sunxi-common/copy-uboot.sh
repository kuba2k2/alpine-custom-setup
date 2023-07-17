#!/bin/bash
pushd $WORK
cp uboot/spl/sunxi-spl.bin boot/
cp uboot/u-boot-dtb.img boot/
cp uboot/u-boot.cfg boot/
popd
