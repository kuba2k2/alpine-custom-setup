################################################################################
#
# linux-ssv6051
#
################################################################################

LINUX_SSV6051_VERSION = rockchip-6.19
LINUX_SSV6051_SOURCE = wifi-driver-ssv6051.patch
LINUX_SSV6051_SITE = https://raw.githubusercontent.com/armbian/build/4ccaf7e/patch/kernel/archive/$(LINUX_SSV6051_VERSION)/patches.armbian

LINUX_SSV6051_MODULE_SUBDIRS = ssv6051/
LINUX_SSV6051_MODULE_MAKE_OPTS = \
	CONFIG_SSV6051=m

define LINUX_SSV6051_EXTRACT_CMDS
	rm -rf $(@D)/ssv6051/
	patch -p4 -d $(@D) -t -i $(LINUX_SSV6051_DL_DIR)/$(LINUX_SSV6051_SOURCE) || true
endef

LINUX_SSV6051_INSTALL_IMAGES = YES
define LINUX_SSV6051_INSTALL_IMAGES_CMDS
	source $(LINUX_SSV6051_PKGDIR)/install-apkovl.sh
endef

$(eval $(kernel-module))
$(eval $(generic-package))
