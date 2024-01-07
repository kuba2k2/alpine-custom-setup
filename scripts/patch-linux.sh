#!/bin/bash
set -e
pushd $WORK/linux/
# remove old tags
git am --abort 2> /dev/null || true
git tag -d $TARGET 2> /dev/null || true

# apply all patches
git am $WORK/acs/$TARGET/linux/*.patch

# copy .dts and commit
if compgen -G "$WORK/acs/$TARGET/*.dts" > /dev/null; then
	cp $WORK/acs/$TARGET/*.dts arch/arm/boot/dts/allwinner/
fi
if compgen -G "$WORK/acs/$TARGET/linux/*.dts" > /dev/null; then
	cp $WORK/acs/$TARGET/linux/*.dts arch/arm/boot/dts/allwinner/
fi
git add arch/arm/boot/dts/
# commit .dts changes
git commit --amend --no-edit

# create tags
git tag -a -m $TARGET $TARGET
git checkout $TARGET
# show commit log
git log --oneline
popd
