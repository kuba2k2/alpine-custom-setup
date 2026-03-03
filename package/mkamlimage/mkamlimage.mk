################################################################################
#
# mkamlimage
#
################################################################################

MKAMLIMAGE_VERSION = 5f3c083
MKAMLIMAGE_SITE = $(call github,kuba2k2,mkamlimage,$(MKAMLIMAGE_VERSION))

define HOST_MKAMLIMAGE_BUILD_CMDS
	$(MAKE) $(HOST_CONFIGURE_OPTS) -C $(@D) all
endef

define HOST_MKAMLIMAGE_INSTALL_CMDS
	$(INSTALL) -d -m 0755 $(HOST_DIR)/bin
	$(INSTALL) -m 0755 $(@D)/mkamlimage $(HOST_DIR)/bin
	$(INSTALL) -m 0755 $(@D)/unamlimage $(HOST_DIR)/bin
endef

$(eval $(host-generic-package))
