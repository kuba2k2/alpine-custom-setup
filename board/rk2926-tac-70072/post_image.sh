#!/bin/bash
set -e

BOARD_DIR=`dirname "$0"`

mkdir -p "${TARGET_DIR}/lib/vendor/"
cp ${BOARD_DIR}/modules/*.ko "${TARGET_DIR}/lib/vendor/"
INSMOD="\
insmod /lib/vendor/8188eu.ko\n\
insmod /lib/vendor/rk292xnand_ko.ko\n\
"
# insmod /lib/vendor/ump.ko\n\
# insmod /lib/vendor/mali.ko\n\

INIT="${TARGET_DIR}/init"
LINE='ebegin "Loading boot drivers"'
cp "${INIT}" "${INIT}.orig"
cat "${INIT}.orig" | tr "\n" "\r" | sed "s#${LINE}\r\r#${LINE}\r${INSMOD}\r#gm" | tr "\r" "\n" > "${INIT}"
rm "${INIT}.orig"

. ${BR2_EXTERNAL_ACS_PATH}/board/common/post_image.sh $*
. ${BR2_EXTERNAL_ACS_PATH}/board/rk2926-tac-70072/gen_bootimg.sh $* -rk28 "rk2926-tac-70072"
