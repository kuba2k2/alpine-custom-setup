TOOLCHAIN_EXTERNAL_LINARO_2016_02_ARM_LINUX_GNUEABIHF_VERSION = 2016.02
TOOLCHAIN_EXTERNAL_LINARO_2016_02_ARM_LINUX_GNUEABIHF_SITE = https://releases.linaro.org/components/toolchain/binaries/4.9-2016.02/arm-linux-gnueabihf

ifeq ($(HOSTARCH),x86)
TOOLCHAIN_EXTERNAL_LINARO_2016_02_ARM_LINUX_GNUEABIHF_SOURCE = gcc-linaro-4.9-2016.02-i686_arm-linux-gnueabihf.tar.xz
else
TOOLCHAIN_EXTERNAL_LINARO_2016_02_ARM_LINUX_GNUEABIHF_SOURCE = gcc-linaro-4.9-2016.02-x86_64_arm-linux-gnueabihf.tar.xz
endif

$(eval $(toolchain-external-package))
