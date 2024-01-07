#!/bin/bash
pushd $WORK
cp linux/arch/arm/boot/dts/allwinner/*.dtb boot/boot/dtbs-acs/
cp linux/arch/arm/boot/zImage boot/boot/vmlinuz-acs
cp linux/System.map boot/boot/System.map-acs
popd
