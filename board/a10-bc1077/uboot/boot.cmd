echo "Serial number:	${serial#}"

setenv bootargs "console=ttyS0,115200"

if test -e ubi ubi0:root /bin/sh; then
	echo "Found root filesystem on UBI"
	setenv bootargs "${bootargs} rootfstype=ubifs ubi.mtd=ubi root=ubi0:root rw rootwait"
elif test -e mmc 0:2 /bin/sh; then
	fsuuid mmc 0:2 rootuuid
	echo "Found root filesystem on MMC 0:2 with UUID=${rootuuid}"
	setenv bootargs "${bootargs} root=UUID=${rootuuid}"
elif test -e mmc 1:2 /bin/sh; then
	fsuuid mmc 1:2 rootuuid
	echo "Found root filesystem on MMC 1:2 with UUID=${rootuuid}"
	setenv bootargs "${bootargs} root=UUID=${rootuuid}"
else
	echo "Root filesystem not found!"
fi

if test -n ${fel_booted} && test -n ${fel_scriptaddr}; then
	echo "Booting from FEL..."
	source ${fel_scriptaddr}
fi

if test -e ubi ubi0:root ${bootfile}; then
	echo "Booting from UBI..."
	sysboot ubi ubi0:root any
fi

if test -e mmc 0:1 ${bootfile}; then
	echo "Booting from MMC 0:1..."
	sysboot mmc 0:1 any
fi

if test -e mmc 1:1 ${bootfile}; then
	echo "Booting from MMC 1:1..."
	sysboot mmc 1:1 any
fi

echo "Fallback to UMS..."
ums 0 mmc 1
