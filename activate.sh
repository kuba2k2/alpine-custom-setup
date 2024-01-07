#!/bin/bash
set -e
pushd $WORK
chmod -R +x acs/**/*.sh
# prepare environment
rm -f *.sh
ln -s -t . acs/scripts/*.sh
if compgen -G "acs/$TARGET/*.sh" > /dev/null; then
	ln -s -t . acs/$TARGET/*.sh
fi
cat acs/$TARGET/activate.txt | xargs -I{} ln -s -t $WORK {}
# cleanup previous versions
./cleanup-linux.sh
./cleanup-uboot.sh
# copy Linux .config
pushd linux/
rm -f .config
cp $WORK/acs/$TARGET/linux/.config .
make olddefconfig
cp .config $WORK/acs/$TARGET/linux/
popd
# copy U-Boot .config
pushd uboot/
rm -f .config
cp $WORK/acs/$TARGET/uboot/.config .
make olddefconfig
cp .config $WORK/acs/$TARGET/uboot/
popd
popd
