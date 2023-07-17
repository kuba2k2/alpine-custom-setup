#!/bin/bash
set -e
pushd $WORK
rm -f boot/.config-uboot
rm -rf boot/u-boot*
rm -rf boot/*-spl.bin
rm -rf boot/*.scr
popd
