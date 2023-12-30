setenv bootm_size 0xa000000
setenv kernel_addr_r 0x42000000
setenv fdt_addr_r 0x43000000
setenv scriptaddr 0x43100000
setenv pxefile_addr_r 0x43200000
setenv fdtoverlay_addr_r 0x43300000
setenv ramdisk_addr_r 0x43400000
setenv eeprom_addr 0x44000000
setenv eeprom_i2c 0x50
mac_invalid_eth0=02:00:00:00:42:42
mac_invalid_wlan0=02:00:00:00:43:43
mac_invalid_usb0=02:00:00:00:44:44

i2c dev 0
i2c speed 100000

if i2c md ${eeprom_i2c} 0.1 0; then
	echo "Reading EEPROM..."
	eeprom read 0 ${eeprom_i2c} ${eeprom_addr} 0x00 0x0C
	# eth0 address
	setexpr m0 *0x44000000 \& 0xFF
	setexpr m1 *0x44000001 \& 0xFF
	setexpr m2 *0x44000002 \& 0xFF
	setexpr m3 *0x44000003 \& 0xFF
	setexpr m4 *0x44000004 \& 0xFF
	setexpr m5 *0x44000005 \& 0xFF
	setenv -f ethaddr ${m0}:${m1}:${m2}:${m3}:${m4}:${m5}
	# wlan0 address
	setexpr m0 *0x44000006 \& 0xFF
	setexpr m1 *0x44000007 \& 0xFF
	setexpr m2 *0x44000008 \& 0xFF
	setexpr m3 *0x44000009 \& 0xFF
	setexpr m4 *0x4400000a \& 0xFF
	setexpr m5 *0x4400000b \& 0xFF
	setenv -f wlanaddr ${m0}:${m1}:${m2}:${m3}:${m4}:${m5}
	# usb0 address
	setexpr m0 *0x44000000 \& 0xFF
	setexpr m1 *0x44000001 \& 0xFF
	setexpr m2 *0x44000002 \& 0xFF
	setexpr m3 *0x44000003 \& 0xFF
	setexpr m4 *0x44000004 \& 0xFF
	setexpr m4 ${m4} \| 0x40
	setexpr m5 *0x44000005 \& 0xFF
	setenv -f usbaddr ${m0}:${m1}:${m2}:${m3}:${m4}:${m5}
	# serial number
	mw.l 0x44000000 0x69726573 # 'seri'
	mw.l 0x44000004 0x3d5f6c61 # 'al_='
	eeprom read 0 ${eeprom_i2c} 0x44000008 0x32 0x28
	env import -t ${eeprom_addr} 0x30
	setenv -f serial# ${serial_}
else
	echo "!! EEPROM not found"
	setenv -f ethaddr ${mac_invalid_eth0}
	setenv -f wlanaddr ${mac_invalid_wlan0}
	setenv -f usbaddr ${mac_invalid_usb0}
fi

echo "Serial number:     ${serial#}"
echo "MAC Address eth0:  ${ethaddr}"
echo "MAC Address wlan0: ${wlanaddr}"
echo "MAC Address usb0:  ${usbaddr}"

setenv bootargs "console=ttyS0,115200 ath9k_hw.hwaddr=${wlanaddr}"

if test -e mmc 1:2 /bin/sh; then
	fsuuid mmc 1:2 rootuuid
	echo "Found root filesystem on MMC 1:2 with UUID=${rootuuid}"
	setenv bootargs "${bootargs} root=UUID=${rootuuid}"
fi

if test -n ${fel_booted} && test -n ${fel_scriptaddr}; then
	echo "Booting from FEL..."
	source ${fel_scriptaddr}
fi

if test -e mmc 1:1 /extlinux/extlinux.conf; then
	echo "Booting from MMC 1:1..."
	sysboot mmc 1:1 any ${scriptaddr} /extlinux/extlinux.conf
fi

echo "Fallback to UMS..."
ums 0 mmc 1
