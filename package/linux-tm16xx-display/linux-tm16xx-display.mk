################################################################################
#
# linux-tm16xx-display
#
################################################################################

LINUX_TM16XX_DISPLAY_VERSION = 3bd8337
LINUX_TM16XX_DISPLAY_SITE = $(call github,jefflessard,tm16xx-display,$(LINUX_TM16XX_DISPLAY_VERSION))

LINUX_TM16XX_DISPLAY_MODULE_SUBDIRS = drivers/auxdisplay/
LINUX_TM16XX_DISPLAY_MODULE_MAKE_OPTS = \
	CONFIG_SEG_LED_GPIO=n \
	CONFIG_LINEDISP=n \
	CONFIG_TM16XX=m \
	CONFIG_TM16XX_I2C=m \
	CONFIG_TM16XX_SPI=m

define LINUX_TM16XX_DISPLAY_LINUX_CONFIG_FIXUPS
	$(call KCONFIG_SET_OPT,CONFIG_SEG_LED_GPIO,m)
	$(call KCONFIG_SET_OPT,CONFIG_LINEDISP,m)
endef

$(eval $(kernel-module))
$(eval $(generic-package))
