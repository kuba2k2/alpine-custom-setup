#!/bin/bash
set -e

echo "Generating Android boot.img"
${HOST_DIR}/bin/abootimg \
	--create \
	"$2" \
	-f "${BOARD_DIR}/bootimg.cfg" \
	-k "${KERNEL}" \
	-r "${RAMDISK}"
