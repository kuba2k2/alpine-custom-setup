#!/bin/bash
set -e
pushd $WORK
# cleanup the previous build
./cleanup-linux.sh
# build the kernel
pushd linux/
make -j4 zImage
make -j4 dtbs
make -j4 modules
make -j4 modules modules_install
popd
# pack modloop
mksquashfs $INSTALL_MOD_PATH/lib/ boot/boot/modloop-acs -b 1048576 -comp xz -Xdict-size 100%
# copy to boot directory
./copy-linux.sh
cp linux/.config boot/.config-linux
# copy default extlinux config
mkdir -p boot/extlinux/
cp acs/scripts/extlinux.conf boot/extlinux/
popd
