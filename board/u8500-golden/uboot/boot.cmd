setenv scriptaddr		0x00100000
setenv kernel_addr_r	0x00200000
setenv fdt_addr_r		0x01f00000
setenv ramdisk_addr_r	0x02000000
setenv pxefile_addr_r	0x03000000

echo "Serial number:     ${serial#}"

setenv bootargs ""
setenv fdtfile "ste-ux500-samsung-golden.dtb"

if test -e mmc 0:17 /bin/sh; then
	fsuuid mmc 0:17 rootuuid
	echo "Found root filesystem on MMC 0:17 with UUID=${rootuuid}"
	setenv bootargs "${bootargs} root=UUID=${rootuuid}"
else
	echo "Root filesystem not found!"
fi

if test -e mmc 1:1 /extlinux/extlinux.conf; then
	echo "Booting from MMC 1:1..."
	sysboot mmc 1:1 any
fi

if test -e mmc 0:16 /extlinux/extlinux.conf; then
	echo "Booting from MMC 0:16..."
	sysboot mmc 0:16 any
fi

echo "Fallback to UMS..."
ums 0 mmc 0
