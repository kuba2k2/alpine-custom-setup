#!/bin/bash
pushd $WORK/linux
cp $WORK/acs/$TARGET/linux/.config .config
make menuconfig
cp .config $WORK/acs/$TARGET/linux/.config
popd
