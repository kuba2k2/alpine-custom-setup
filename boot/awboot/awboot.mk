################################################################################
#
# awboot
#
################################################################################

AWBOOT_VERSION = $(call qstrip,$(BR2_TARGET_AWBOOT_VERSION))
AWBOOT_SITE = https://github.com/$(call qstrip,$(BR2_TARGET_AWBOOT_SOURCE))
AWBOOT_SITE_METHOD = git

AWBOOT_DEPENDENCIES = host-gcc-arm-none-eabi

AWBOOT_INSTALL_TARGET = NO
AWBOOT_INSTALL_IMAGES = YES

ifeq ($(BR2_TARGET_AWBOOT_FORMAT_FEL),y)
AWBOOT_BINS += awboot-fel.bin
endif
ifeq ($(BR2_TARGET_AWBOOT_FORMAT_SPI),y)
AWBOOT_BINS += awboot-boot-spi.bin
endif
ifeq ($(BR2_TARGET_AWBOOT_FORMAT_SD),y)
AWBOOT_BINS += awboot-boot-sd.bin
endif
ifeq ($(BR2_TARGET_AWBOOT_FORMAT_ALL),y)
AWBOOT_BINS += awboot-boot-all.bin
endif
ifeq ($(BR2_TARGET_AWBOOT_FORMAT_CUSTOM),y)
AWBOOT_BINS += $(call qstrip,$(BR2_TARGET_AWBOOT_FORMAT_CUSTOM_NAME))
endif

ifeq ($(BR2_TARGET_AWBOOT_BOARD_MANGOPI_DUAL),y)
AWBOOT_BOARD := mangopi-dual
endif
ifeq ($(BR2_TARGET_AWBOOT_BOARD_YUZUKI_LIZARD),y)
AWBOOT_BOARD := yuzuki-lizard
endif
ifeq ($(BR2_TARGET_AWBOOT_BOARD_CUSTOM),y)
AWBOOT_BOARD := $(call qstrip,$(BR2_TARGET_AWBOOT_BOARD_CUSTOM_NAME))
AWBOOT_BOARD_PATH := $(call qstrip,$(BR2_TARGET_AWBOOT_BOARD_CUSTOM_PATH))
endif

# arm-linux- (doesn't work, missing raise() for hard float)
# AWBOOT_CROSS = $(TARGET_CROSS)
# arm-none-eabi- (doesn't support hard float)
# AWBOOT_CROSS = $(call qstrip,$(BR2_TOOLCHAIN_BARE_METAL_BUILDROOT_ARCH))-
# arm-none-eabi- (from custom toolchain from xPack)
AWBOOT_CROSS = $(HOST_DIR)/gcc-arm-none-eabi/bin/arm-none-eabi-

AWBOOT_MAKE_OPTS += \
	CROSS_COMPILE=$(AWBOOT_CROSS) \
 	HOSTCC="$(HOSTCC) $(subst -I/,-isystem /,$(subst -I /,-isystem /,$(HOST_CFLAGS)))" \
 	HOSTLDFLAGS="$(HOST_LDFLAGS)" \
	LOG_LEVEL=40 \
	BOARD=$(AWBOOT_BOARD) \
	BUILD_REVISION=br-$(AWBOOT_VERSION) \

ifeq ($(BR2_TARGET_AWBOOT_BOARD_CUSTOM),y)
define AWBOOT_CONFIGURE_CMDS
	rm -f $(@D)/boards/$(AWBOOT_BOARD)
	ln -s $(AWBOOT_BOARD_PATH) $(@D)/boards/$(AWBOOT_BOARD)
endef
endif

define AWBOOT_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) $(AWBOOT_MAKE_OPTS)
endef

define AWBOOT_INSTALL_IMAGES_CMDS
	$(foreach f,$(AWBOOT_BINS), \
			cp -dpf $(@D)/$(subst awboot-,awboot-$(AWBOOT_BOARD)-,$(f)) $(BINARIES_DIR)/$(f)
	)
endef

$(eval $(generic-package))
