echo "Serial number:     ${serial#}"

setenv bootargs "console=tty0 console=ttyS0,115200 rootfstype=ubifs ubi.mtd=ubi root=ubi0:root rw rootwait"

if test -n ${fel_booted} && test -n ${fel_scriptaddr}; then
	echo "Booting from FEL..."
	source ${fel_scriptaddr}
fi

if test -e ubi ubi0:root /${boot_syslinux_conf}; then
	echo "Booting from UBI..."
	sysboot ubi ubi0:root any ${scriptaddr} /${boot_syslinux_conf}
fi
