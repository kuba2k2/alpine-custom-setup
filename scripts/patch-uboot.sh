#!/bin/bash
set -e
pushd $WORK/uboot/
# remove old tags
git am --abort 2> /dev/null || true
git tag -d $TARGET 2> /dev/null || true

# apply all patches
git am $WORK/acs/$TARGET/uboot/*.patch

# copy .dts and commit
if compgen -G "$WORK/acs/$TARGET/*.dts" > /dev/null; then
	cp $WORK/acs/$TARGET/*.dts arch/arm/dts/
fi
if compgen -G "$WORK/acs/$TARGET/uboot/*.dts" > /dev/null; then
	cp $WORK/acs/$TARGET/uboot/*.dts arch/arm/dts/
fi
git add arch/arm/dts/
# commit .dts changes
git commit --amend --no-edit

# copy default env and commit
# if compgen -G "$WORK/acs/$TARGET/uboot/board/*" > /dev/null; then
# 	cp -R $WORK/acs/$TARGET/uboot/board/* board/
# 	git add board/
# 	git commit -m "board: add $TARGET default environment"
# fi

# create tags
git tag -a -m $TARGET $TARGET
git checkout $TARGET
# show commit log
git log --oneline
popd
