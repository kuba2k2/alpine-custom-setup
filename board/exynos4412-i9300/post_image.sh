#!/bin/bash
set -e

BOARD_DIR=`dirname "$0"`

. ${BR2_EXTERNAL_ACS_PATH}/board/common/post_image.sh $*

# BOOTNAME="i9300-${VERSION_NAME}.img"
# BOOTPATH="${BINARIES_DIR}/${BOOTNAME}"
# . ${BR2_EXTERNAL_ACS_PATH}/board/common-android/post_image.sh $* "${BOOTPATH}"
# cp "${BOOTPATH}" "${BINARIES_DIR}/boot.img"
# tar -cf "${BOOTPATH}.tar" -C "${BINARIES_DIR}" "boot.img"
# rm -f "${BINARIES_DIR}/boot.img"

FWBL1="${BOARD_DIR}/p4412_s_fwbl1.bin"
SPL="${BINARIES_DIR}/u-boot-spl.bin"
UBOOT="${BINARIES_DIR}/u-boot.bin"
BOOTLOADER="${BINARIES_DIR}/i9300-bootloader-emmc.bin"

if [ ! -f "${UBOOT}" ]; then
	echo "No U-Boot found - bootloader image not generated"
	exit 0
fi

echo "Generating Samsung bootloader image"
dd if="${FWBL1}" of="${BOOTLOADER}" bs=512 seek=0
dd if="${SPL}" of="${BOOTLOADER}" bs=512 seek=16
dd if="${UBOOT}" of="${BOOTLOADER}" bs=512 seek=48
