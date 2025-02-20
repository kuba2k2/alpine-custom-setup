################################################################################
#
# gcc-arm-none-eabi
#
################################################################################

GCC_ARM_NONE_EABI_VERSION = $(call qstrip,$(BR2_PACKAGE_HOST_GCC_ARM_NONE_EABI_VERSION))
GCC_ARM_NONE_EABI_SOURCE = xpack-arm-none-eabi-gcc-$(GCC_ARM_NONE_EABI_VERSION)-linux-x64.tar.gz
GCC_ARM_NONE_EABI_SITE = https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/download/v$(GCC_ARM_NONE_EABI_VERSION)

define HOST_GCC_ARM_NONE_EABI_EXTRACT_CMDS
endef

define HOST_GCC_ARM_NONE_EABI_BUILD_CMDS
endef

define HOST_GCC_ARM_NONE_EABI_INSTALL_CMDS
	mkdir -p $(HOST_DIR)/gcc-arm-none-eabi/
	tar -C $(HOST_DIR)/gcc-arm-none-eabi/ --strip-components 1 -xavf $(HOST_GCC_ARM_NONE_EABI_DL_DIR)/$(HOST_GCC_ARM_NONE_EABI_SOURCE)
endef

$(eval $(host-generic-package))
