#!/bin/bash
set -e
pushd $WORK
# ask for version if not specified
if [ $# -le 2 ]; then
	read -p "Enter version tag (without v-prefix): "
	ver="v$REPLY"
	echo ""
else
	ver="v$1"
fi

# pull & checkout
echo "Updating U-Boot to $ver"
pushd uboot/
git fetch --depth 1 origin refs/tags/$ver:refs/tags/$ver
echo ""
git checkout $ver
git checkout .
popd

echo ""
echo "Patching U-Boot"
./patch-uboot.sh

popd
