################################################################################
#
# rockchip-mkbootimg
#
################################################################################

ROCKCHIP_MKBOOTIMG_VERSION = 2348690523faee6ce3cea9eb9ff47e8b8d5e1df6
ROCKCHIP_MKBOOTIMG_SITE = https://github.com/neo-technologies/rockchip-mkbootimg.git
ROCKCHIP_MKBOOTIMG_SITE_METHOD = git

HOST_ROCKCHIP_MKBOOTIMG_DEPENDENCIES = host-openssl

define HOST_ROCKCHIP_MKBOOTIMG_BUILD_CMDS
	$(MAKE) -C $(@D) $(HOST_CONFIGURE_OPTS) \
		LDFLAGS="$(HOST_LDFLAGS) -lcrypto"
endef

define HOST_ROCKCHIP_MKBOOTIMG_INSTALL_CMDS
	$(INSTALL) -d -m 0755 $(HOST_DIR)/bin
	$(INSTALL) -m 0755 $(@D)/afptool $(HOST_DIR)/bin
	$(INSTALL) -m 0755 $(@D)/img_maker $(HOST_DIR)/bin
	$(INSTALL) -m 0755 $(@D)/mkbootimg $(HOST_DIR)/bin
	$(INSTALL) -m 0755 $(@D)/unmkbootimg $(HOST_DIR)/bin
	$(INSTALL) -m 0755 $(@D)/mkrootfs $(HOST_DIR)/bin
	$(INSTALL) -m 0755 $(@D)/mkupdate $(HOST_DIR)/bin
	$(INSTALL) -m 0755 $(@D)/mkcpiogz $(HOST_DIR)/bin
	$(INSTALL) -m 0755 $(@D)/unmkcpiogz $(HOST_DIR)/bin
endef

$(eval $(host-generic-package))
