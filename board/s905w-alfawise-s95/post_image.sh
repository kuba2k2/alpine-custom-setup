#!/bin/bash
set -e

BOARD_DIR=`dirname "$0"`

# Build Amlogic FIP image
pushd "${BINARIES_DIR}/amlogic-boot-fip/"
./build-fip.sh jethub-j80 ../u-boot-dtb.bin .
cp u-boot.bin ../u-boot-dtb.fip
popd

. ${BR2_EXTERNAL_ACS_PATH}/board/common/post_image.sh $*
