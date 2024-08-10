setenv scriptaddr 0x40000100
setenv kernel_addr_r 0x40008000
setenv fdt_addr_r 0x40f00000
setenv ramdisk_addr_r 0x41000000
setenv pxefile_addr_r 0x50000000

echo "Serial number:     ${serial#}"

setenv bootargs "console=ttySAC2,115200"
setenv fdtfile "exynos4412-i9300.dtb"

led red off
led green off
led blue off

if test -e mmc 0:9 /bin/sh; then
	fsuuid mmc 0:9 rootuuid
	echo "Found root filesystem on MMC 0:9 with UUID=${rootuuid}"
	setenv bootargs "${bootargs} root=UUID=${rootuuid}"
else
	echo "Root filesystem not found!"
fi

if test -e mmc 1:1 /extlinux/extlinux.conf; then
	echo "Booting from MMC 1:1..."
	led red on
	led blue on
	sysboot mmc 1:1 any ${scriptaddr} /extlinux/extlinux.conf
fi

if test -e mmc 0:8 /extlinux/extlinux.conf; then
	echo "Booting from MMC 0:8..."
	led green on
	sysboot mmc 0:8 any ${scriptaddr} /extlinux/extlinux.conf
fi

echo "Fallback to UMS..."
led red on
ums 0 mmc 0
