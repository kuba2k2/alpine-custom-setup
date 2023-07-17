#!/bin/bash
set -e
pushd $WORK
rm -f boot/.config-linux
rm -rf boot/boot/dtbs-acs/
rm -f boot/boot/modloop-acs
rm -f boot/boot/System.map-acs
rm -f boot/boot/vmlinuz-acs
rm -rf $INSTALL_MOD_PATH
mkdir -p boot/boot/dtbs-acs/
mkdir -p $INSTALL_MOD_PATH
popd
