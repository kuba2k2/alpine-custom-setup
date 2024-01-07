#!/bin/bash
pushd $WORK/uboot
cp $WORK/acs/$TARGET/uboot/.config .config
make menuconfig
cp .config $WORK/acs/$TARGET/uboot/.config
popd
