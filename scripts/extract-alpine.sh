#!/bin/bash
set -e
pushd $WORK
# cleanup previous versions
rm -rf boot/apks/
rm -f boot/boot/initramfs-acs
mkdir -p boot/boot/
# extract the archive
tar -C boot -T acs/scripts/extract-alpine.txt --wildcards -xzvf alpine-uboot-*.tar.gz > /dev/null
# unpack initramfs
rm -rf initramfs/
mkdir -p initramfs/
cat boot/boot/initramfs-lts | gzip -d | cpio -i -D initramfs/ > /dev/null
# remove modloop signature
rm -f initramfs/var/cache/misc/*modloop*.SIGN.RSA.*.pub
# remove built-in modules
rm -rf initramfs/lib/modules/*-lts
# pack initramfs
pushd initramfs/
find . -print0 | cpio --null -ov --format=newc | gzip -c > $WORK/boot/boot/initramfs-acs
popd
rm -rf boot/boot/initramfs-lts
rm -rf initramfs/
popd
