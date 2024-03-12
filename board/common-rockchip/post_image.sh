#!/bin/bash
set -e

LOADER_DIR="${BR2_EXTERNAL_ACS_PATH}/board/common-rockchip/rkfw"
RKFW_DIR="${BINARIES_DIR}/rkfw"

CHIP_TYPE=$2
OUT_PREFIX=$3

mkdir -p "${RKFW_DIR}/"

echo "Generating Rockchip boot.img"
${HOST_DIR}/bin/mkbootimg \
	--kernel "${KERNEL}" \
	--ramdisk "${RAMDISK}" \
	--base 0x60400000 \
	--pagesize 16384 \
	--kernel_offset 0x60408000 \
	--ramdisk_offset 0x62000000 \
	--second_offset 0x60f00000 \
	--tags_offset 0x60088000 \
	--ramdiskaddr 0x62000000 \
	--output "${RKFW_DIR}/boot.img"

LOADER=`grep bootloader "${BOARD_DIR}/rkfw/package-file" | tr -s "\t" | cut -f2 | tr -d "\r\n"`
TEMP=`tempfile`

cp "${BOARD_DIR}/rkfw/package-file" "${RKFW_DIR}/"
cp "${LOADER_DIR}/rkfw/${LOADER}" "${RKFW_DIR}/"
dd if=/dev/zero of="${RKFW_DIR}/misc.img" bs=4096 count=12

VARIANTS=("live" "root")
for VARIANT in ${VARIANTS[@]}; do

	CMDLINE=`cat "${BOARD_DIR}/rkfw/cmdline-${VARIANT}.txt" | tr "\r\n" " "`

	cat "${BOARD_DIR}/rkfw/parameter" \
		| sed "s/\${VERSION}/${VERSION}/g" \
		| sed "s#\${CMDLINE}#${CMDLINE}#g" \
		> "${RKFW_DIR}/parameter-${VARIANT}"

	cp "${RKFW_DIR}/parameter-${VARIANT}" "${RKFW_DIR}/parameter"

	echo "Generating Rockchip '${VARIANT}' update image"

	${HOST_DIR}/bin/afptool \
		-pack "${RKFW_DIR}/" "${TEMP}"

	VERSION_HEX=`echo ${VERSION} | tr "." " "`
	VERSION_HEX=($VERSION_HEX)
	VERSION_BCD="$((16#${VERSION_HEX[0]})) $((16#${VERSION_HEX[1]})) $((16#${VERSION_HEX[2]}))"

	${HOST_DIR}/bin/img_maker \
		${CHIP_TYPE} \
		"${RKFW_DIR}/${LOADER}" \
		${VERSION_BCD} \
		"${TEMP}" \
		"${BINARIES_DIR}/${OUT_PREFIX}-${VERSION_NAME}-${VARIANT}.img"
done

rm -f "${RKFW_DIR}/package-file" "${RKFW_DIR}/parameter"
