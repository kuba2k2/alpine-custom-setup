#!/bin/bash
set -e

BOARD_DIR=`dirname "$0"`

# Build Amlogic FIP image
pushd "${BINARIES_DIR}/amlogic-boot-fip/"
./build-fip.sh khadas-vim ../u-boot-dtb.bin .
# Use BL2 from stock firmware
rm -f u-boot.bin u-boot.sd.bin u-boot.bin.usb.bl2
cat "${BOARD_DIR}/uboot/u-boot.bin.usb.bl2" u-boot.bin.usb.tpl > ../u-boot-dtb.fip
popd

# Build Amlogic Upgrade Package
${HOST_DIR}/bin/mkamlimage \
	"${BINARIES_DIR}/u-boot-live.img" \
	"normal,USB,DDR=${BOARD_DIR}/uboot/u-boot.bin.usb.bl2" \
	"normal,USB,UBOOT=${BINARIES_DIR}/amlogic-boot-fip/u-boot.bin.usb.tpl" \
	"normal,conf,platform=${BOARD_DIR}/platform.conf"

. ${BR2_EXTERNAL_ACS_PATH}/board/common/post_image.sh $*
