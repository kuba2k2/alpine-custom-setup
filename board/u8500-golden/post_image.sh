#!/bin/bash
set -e

BOARD_DIR=`dirname "$0"`

. ${BR2_EXTERNAL_ACS_PATH}/board/common/post_image.sh $*

UBOOT="${BINARIES_DIR}/u-boot.bin"

if [ ! -f "${UBOOT}" ]; then
	echo "No U-Boot found - bootloader image not generated"
	exit 0
fi

echo "Generating Android boot.img"

BOOTNAME="golden-u-boot.img"
BOOTPATH="${BINARIES_DIR}/${BOOTNAME}"

${HOST_DIR}/bin/abootimg \
	--create \
	"${BOOTPATH}" \
	-f "${BOARD_DIR}/bootimg.cfg" \
	-k "${UBOOT}" \
	-r "${UBOOT}"

cp "${BOOTPATH}" "${BINARIES_DIR}/boot.img"
tar -cf "${BOOTPATH}.tar" -C "${BINARIES_DIR}" "boot.img"
rm -f "${BINARIES_DIR}/boot.img"
