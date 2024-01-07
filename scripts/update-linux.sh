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
echo "Updating Linux to $ver"
pushd linux/
git fetch --depth 1 origin refs/tags/$ver:refs/tags/$ver
echo ""
git checkout $ver
git checkout .
popd

echo ""
echo "Patching Linux"
./patch-linux.sh

popd
