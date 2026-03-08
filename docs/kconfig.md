# Kernel configuration

## Required options

- `CONFIG_SQUASHFS=y`
- `CONFIG_SQUASHFS_XZ=y`
- `CONFIG_BLK_DEV_INITRD=y`
- `CONFIG_BLK_DEV_LOOP=y`
- `CONFIG_RD_GZIP=y`

## OpenRC init errors

- `net.ipv4.tcp_syncookies` -> `CONFIG_SYN_COOKIES`
- `kernel.unprivileged_bpf_disabled` -> `CONFIG_BPF_SYSCALL`
- `/proc/sys/kernel/hotplug` -> `CONFIG_CPU_HOTPLUG_STATE_CONTROL`

## Firmware support

- `CONFIG_FW_LOADER_COMPRESS=y`
- `CONFIG_FW_LOADER_COMPRESS_ZSTD=y`

# U-Boot configuration

## Required options

```shell
# Default boot command - for devices with eMMC - adjust 'ums' command
# Specifying 'mmc x:0` makes it work even without a valid partition table
CONFIG_BOOTCOMMAND="if load mmc 0:1 ${scriptaddr} /boot.scr || load mmc 1:1 ${scriptaddr} /boot.scr; then source ${scriptaddr}; else ums 0 mmc 1:0; fi"
# Default boot command - for devices without eMMC (only SD/NAND)
CONFIG_BOOTCOMMAND="load mmc 0:1 ${scriptaddr} /boot.scr; source ${scriptaddr}"

# Default preboot command - for devices with a boot button
CONFIG_PREBOOT="if button <name>; then usb start; ums 0 mmc 1:0; fi"
CONFIG_PREBOOT="if gpio input <name>; then usb start; ums 0 mmc 0:0; fi"
# Default preboot command - for devices without a boot button
CONFIG_PREBOOT=""

# Other boot options
CONFIG_BOOTFILE="/extlinux/extlinux.conf"
CONFIG_USE_BOOTCOMMAND=y
CONFIG_USE_BOOTFILE=y
CONFIG_USE_PREBOOT=y
# Commands used in boot script
CONFIG_CMD_EXT4=y
CONFIG_CMD_FS_UUID=y
CONFIG_CMD_SYSBOOT=y
# Image formats
CONFIG_LEGACY_IMAGE_FORMAT=y
CONFIG_SUPPORT_RAW_INITRD=y

# Environment support (FAT) - for devices with eMMC/SD boot media
CONFIG_ENV_IS_NOWHERE=n
CONFIG_ENV_IS_IN_FAT=y
CONFIG_ENV_FAT_INTERFACE="mmc"
CONFIG_ENV_FAT_DEVICE_AND_PART=":auto"
CONFIG_ENV_FAT_FILE="uboot.env"
CONFIG_ENV_VARS_UBOOT_CONFIG=y
```

## Miscellaneous options

```shell
# USB Mass Storage gadget support
CONFIG_CMD_USB_MASS_STORAGE=y
CONFIG_USB_GADGET_DOWNLOAD=y
CONFIG_USB_GADGET=y
```

## Size tweaking

```shell
# General options
CONFIG_LZ4=n
CONFIG_LZMA=n
CONFIG_MMC_HW_PARTITIONING=n
CONFIG_SMBIOS=n
CONFIG_SPL_POWER=n
CONFIG_SYS_LONGHELP=n
# Unused commands
CONFIG_CMD_BDI=n
CONFIG_CMD_BOOTEFI=n
CONFIG_CMD_CONSOLE=n
CONFIG_CMD_CPU=n
CONFIG_CMD_CYCLIC=n
CONFIG_CMD_DM=n
CONFIG_CMD_EDITENV=n
CONFIG_CMD_EFICONFIG=n
CONFIG_CMD_ELF=n
CONFIG_CMD_FDT=n
CONFIG_CMD_FLASH=n
CONFIG_CMD_GPT=n
CONFIG_CMD_LOADB=n
CONFIG_CMD_LOADS=n
CONFIG_CMD_LZMADEC=n
CONFIG_CMD_UNLZ4=n
CONFIG_CMD_UNZIP=n
CONFIG_CMD_XIMG=n
CONFIG_RANDOM_UUID=n
# Unused boot methods
CONFIG_BOOTM_EFI=n
CONFIG_BOOTM_NETBSD=n
CONFIG_BOOTM_PLAN9=n
CONFIG_BOOTM_RTEMS=n
CONFIG_BOOTM_VXWORKS=n
CONFIG_BOOTSTD=n
CONFIG_DISTRO_DEFAULTS=n
CONFIG_EFI_LOADER=n
CONFIG_FIT=n
# Unused filesystems/partition types
# (disables GPT; leave CONFIG_EFI_PARTITION if needed)
CONFIG_CMD_EXT2=n
CONFIG_EFI_PARTITION=n
CONFIG_FS_EXT4=n
CONFIG_ISO_PARTITION=n
# Disable network support
CONFIG_CMD_NET=n
CONFIG_NET=n
CONFIG_NO_NET=y
```
