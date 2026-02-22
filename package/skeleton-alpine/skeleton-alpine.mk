################################################################################
#
# skeleton-alpine
#
################################################################################

SKELETON_ALPINE_ADD_TOOLCHAIN_DEPENDENCY = NO
SKELETON_ALPINE_ADD_SKELETON_DEPENDENCY = NO
SKELETON_ALPINE_PROVIDES = skeleton

SKELETON_ALPINE_INSTALL_TARGET = YES
SKELETON_ALPINE_INSTALL_IMAGES = YES

SKELETON_ALPINE_RELEASE = $(call qstrip,$(BR2_ROOTFS_SKELETON_ALPINE_RELEASE))
SKELETON_ALPINE_VERSION = $(call qstrip,$(BR2_ROOTFS_SKELETON_ALPINE_VERSION))
SKELETON_ALPINE_ARCH = $(call qstrip,$(BR2_ROOTFS_SKELETON_ALPINE_ARCH))

SKELETON_ALPINE_MIRROR = https://dl-cdn.alpinelinux.org/alpine/v$(SKELETON_ALPINE_RELEASE)
SKELETON_ALPINE_SITE = $(SKELETON_ALPINE_MIRROR)/releases/$(SKELETON_ALPINE_ARCH)

ifeq ($(SKELETON_ALPINE_ARCH),armv7)
	SKELETON_ALPINE_SOURCE = alpine-rpi-$(SKELETON_ALPINE_VERSION)-armv7.tar.gz
	SKELETON_ALPINE_DIST = rpi
else ifeq ($(SKELETON_ALPINE_ARCH),armhf)
	SKELETON_ALPINE_SOURCE = alpine-rpi-$(SKELETON_ALPINE_VERSION)-armhf.tar.gz
	SKELETON_ALPINE_DIST = rpi
else ifeq ($(SKELETON_ALPINE_ARCH),riscv64)
	SKELETON_ALPINE_SOURCE = alpine-uboot-$(SKELETON_ALPINE_VERSION)-riscv64.tar.gz
	SKELETON_ALPINE_DIST = lts
else
	$(error Architecture $(SKELETON_ALPINE_ARCH) is not supported)
endif

# SKELETON_ALPINE_DEPENDENCIES += host-xorriso

# $(HOST_DIR)/bin/osirrox \
# 	-indev $(SKELETON_ALPINE_DL_DIR)/$(SKELETON_ALPINE_SOURCE) \
# 	-extract /boot/initramfs-lts $(@D)/boot/initramfs-lts \
# 	-extract /apks/ $(@D)/apks/ \
# 	-extract /.alpine-release $(@D)/.alpine-release

define SKELETON_ALPINE_EXTRACT_CMDS
	mkdir -p $(@D)/boot/
	mkdir -p $(@D)/initramfs/
	tar -xz \
		-C $(@D)/ \
		-f $(SKELETON_ALPINE_DL_DIR)/$(SKELETON_ALPINE_SOURCE) \
		./boot/initramfs-$(SKELETON_ALPINE_DIST) \
		./apks/ \
		./.alpine-release
	gzip -dc $(@D)/boot/initramfs-$(SKELETON_ALPINE_DIST) | cpio -i -u -D $(@D)/initramfs/
	rm -f $(@D)/initramfs/var/cache/misc/*modloop*.SIGN.RSA.*.pub
	rm -rf $(@D)/initramfs/lib/modules/*-rpi
	rm -rf $(@D)/initramfs/lib/modules/*-lts
	rm -rf $(@D)/initramfs/lib/firmware/*
endef

define SKELETON_ALPINE_INSTALL_TARGET_CMDS
	cp -r $(@D)/initramfs/. $(TARGET_DIR)/
	touch $(TARGET_DIR)/etc/shadow
endef

define SKELETON_ALPINE_INSTALL_IMAGES_CMDS
	mkdir -p $(BINARIES_DIR)/bootfs/apks/
	cp -r $(@D)/apks/. $(BINARIES_DIR)/bootfs/apks/
	cp -r $(@D)/.alpine-release $(BINARIES_DIR)/bootfs/

	FIRMWARE=$(BR2_ROOTFS_SKELETON_ALPINE_FIRMWARE); \
	for name in $${FIRMWARE}; do \
		if ! compgen -G "$(BINARIES_DIR)/bootfs/apks/linux-firmware-$$name*.apk" > /dev/null; then \
			wget --recursive \
				--no-parent --no-clobber --no-directories \
				--accept "linux-firmware-$$name*.apk" \
				-P $(BINARIES_DIR)/bootfs/apks/ \
				$(SKELETON_ALPINE_MIRROR)/main/$(SKELETON_ALPINE_ARCH)/; \
		fi; \
	done
endef

$(eval $(generic-package))
