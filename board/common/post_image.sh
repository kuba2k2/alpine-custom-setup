#!/bin/bash
set -e

COMMON_DIR="${BR2_EXTERNAL_ACS_PATH}/board/common"
BOOTFS_DIR="${BINARIES_DIR}/bootfs"
BOOT_DIR="${BINARIES_DIR}/bootfs/boot"
EXTLINUX_DIR="${BINARIES_DIR}/bootfs/extlinux"

mkdir -p "${BOOT_DIR}/"
mkdir -p "${EXTLINUX_DIR}/"

if [ ! -f "${BINARIES_DIR}/zImage" ]; then
	echo "Missing zImage - please compile the kernel first!"
	exit 1
fi

#

echo "Extracting version information"
if [ -f "${BOOTFS_DIR}/.alpine-release" ]; then
	export VERSION=`cat "${BOOTFS_DIR}/.alpine-release" | cut -d " " -f1 | cut -d "-" -f3`
else
	export VERSION=`date +%y.%-m.%-d`
fi
export UNAME=`ls -1 "${TARGET_DIR}/lib/modules/"`
export LINUX=`echo ${UNAME} | tr -dc "0-9."`
export VERSION_NAME="alpine${VERSION}-linux${LINUX}"

#

echo "Copying Linux kernel"
# if compgen -G "${BINARIES_DIR}/*.dtb" > /dev/null; then
	# cat "${BINARIES_DIR}/zImage" ${BINARIES_DIR}/*.dtb > "${BOOT_DIR}/vmlinuz-acs"
# else
cat "${BINARIES_DIR}/zImage" > "${BOOT_DIR}/vmlinuz-acs"
# fi
export KERNEL="${BOOT_DIR}/vmlinuz-acs"

#

if compgen -G "${BINARIES_DIR}/*.dtb" > /dev/null; then
	echo "Copying Device Tree Blobs"
	mkdir -p "${BOOT_DIR}/dtbs-acs/"
	cp ${BINARIES_DIR}/*.dtb "${BOOT_DIR}/dtbs-acs/"

	if compgen -G "${BOARD_DIR}/overlays/*.dts" > /dev/null; then
		echo "Compiling Device Tree Overlays"
		for file in ${BOARD_DIR}/overlays/*.dts; do
			output=${file##*/}
			output=${output%.*}
			${HOST_DIR}/bin/dtc \
				-@ -I dts -O dtb \
				$file \
				-o "${BOOT_DIR}/dtbs-acs/${output}.dtbo"
		done
	fi
else
	echo "No DTBs found"
fi

#

if [ -f "${BINARIES_DIR}/u-boot-dtb.img" ]; then
	echo "Copying U-Boot with DTB"
	cp "${BINARIES_DIR}/u-boot-dtb.img" "${BOOTFS_DIR}/"
fi

#

if [ -f "${BOARD_DIR}/uboot/boot.cmd" ]; then
	echo "Compiling U-Boot script"
	if [ ! -f "${HOST_DIR}/bin/mkimage" ]; then
		echo "mkimage not found! Please install host u-boot tools"
		exit 1
	fi
	"${HOST_DIR}/bin/mkimage" \
		-A arm \
		-T script \
		-d "${BOARD_DIR}/uboot/boot.cmd" "${BOOTFS_DIR}/boot.scr"
fi

#

echo "Copying extlinux config"
cp "${COMMON_DIR}/extlinux.conf" "${EXTLINUX_DIR}/"

#

if [ -f "${TARGET_DIR}/sbin/apk" ]; then
	echo "Packing modloop"
	${HOST_DIR}/bin/mksquashfs \
		"${TARGET_DIR}/lib/modules/" \
		"${BOOT_DIR}/modloop-acs" \
		-keep-as-directory \
		-noappend \
		-b 1048576 \
		-comp xz \
		-Xdict-size 100%
	export MODLOOP="${BOOT_DIR}/modloop-acs"

	echo "Packing initramfs"
	pushd ${TARGET_DIR}
	find . ! -wholename "./lib/modules/*" -print0 | cpio --null -o --format=newc | gzip -c > "${BOOT_DIR}/initramfs-acs"
	popd
	export RAMDISK="${BOOT_DIR}/initramfs-acs"

	echo "Packing apkovl"
	cp "${COMMON_DIR}/alpine.apkovl.tar" "${BOOTFS_DIR}/"
	if [ -d "${BOARD_DIR}/apkovl/" ]; then
		tar -rf "${BOOTFS_DIR}/alpine.apkovl.tar" -C "${BOARD_DIR}/apkovl/" .
	fi
	rm -f "${BOOTFS_DIR}/alpine.apkovl.tar.gz"
	gzip "${BOOTFS_DIR}/alpine.apkovl.tar"
else
	echo "Alpine Linux rootfs not detected!"
	export RAMDISK="${BINARIES_DIR}/rootfs.cpio.gz"
fi

#

echo "Packing bootfs"
rm -f "${BINARIES_DIR}/bootfs.img"
${HOST_DIR}/sbin/mkdosfs \
	-F 32 \
	-n bootfs \
	-C "${BINARIES_DIR}/bootfs.img" 131072
${HOST_DIR}/bin/mcopy \
	-i "${BINARIES_DIR}/bootfs.img" \
	-s \
	${BINARIES_DIR}/bootfs/* ::

#

if [ -f "${BOARD_DIR}/genimage.cfg" ]; then
	echo "Running genimage"
	${CONFIG_DIR}/support/scripts/genimage.sh -c "${BOARD_DIR}/genimage.cfg"
fi
