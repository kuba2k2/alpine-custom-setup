# Fingbox v1

## Backup the firmware

1. First of all - backup the stock firmware using U-Boot that's already installed on the device. You'll need to open it up to find the UART port on the other side of the main PCB.
2. Plug in any USB flash drive and use U-Boot to dump the eMMC (at least the first 2 GiB to have an usable backup). You can probably find many guides on how to do that; I don't remember the exact steps.
3. Having a working eMMC backup, open the 2-nd "recovery" partition (the eMMC is MBR-partitioned). You can do this with a good hex editor such as WinHex, or using `fdisk` and `dd` if you know your way around Linux.
4. There's a `compressed_p3.xz` file on the recovery partition. It contains the stock filesystem of the Ubuntu Core 16 distribution running on the Fingbox. Decompress that file to get a raw image of the EXT4 FS.
5. Mount or extract the EXT4 image. Navigate to `/system-data/var/lib/snapd/seed/`.
6. Find the Snap store ID in `assertions/model` file. Find the list of Snap IDs in `seed.yaml` file.
7. Decompress `snaps/domotz-platform-kernel_1.snap` (SquashFS archive). Grab `firmware/eeprom_ar9271.bin` from the filesystem.

I'm not providing Snap IDs or the firmware file here - if you own a Fingbox, you can find it yourself.

## Run U-Boot

Enter FEL mode - connect the USB cable while pressing the `UBOOT` button.

Run these commands to flash SPL onto the EMMC and enable UMS mode:
```bash
# run SPL
sunxi-fel spl $WORK/uboot/spl/sunxi-spl.bin
# run U-Boot Proper
sunxi-fel write 0x4a000000 $WORK/uboot/u-boot-dtb.bin
# write SPL for flashing
sunxi-fel write 0x43000000 $WORK/uboot/spl/sunxi-spl.bin
# write flashing commands
sunxi-fel write 0x43100000 $WORK/acs/fingbox-v1/fel-spl-ums.env
# jump to U-Boot
sunxi-fel exe 0x4a000000
```

## Partition the EMMC

The Fingbox should be now visible on your PC as a mass-storage device.

Note: change `/dev/sde` to the UMS device.

- `fdisk /dev/sde`
- `o` - clear the MBR
- `n` - new partition
- `p` - primary
- `<Enter>` - index 1
- `<Enter>` - starting sector
- `+128M` - `boot` partition size
- `t` - change type
- `c` - FAT32
- `a` - mark as active/bootable
- `n` - new partition
- `p` - primary
- `<Enter>` - index 2
- `<Enter>` - starting sector
- `<Enter>` - ending sector
- `w` - write changes

Format the boot partition:
```bash
partprobe
mkfs.vfat -n BOOT /dev/sde1
```

Copy the contents of `boot/` directory to the newly created boot partition.

Put `eeprom_ar9271.bin` extracted before on the boot partition.

## Boot Linux

Reset the board to boot into Alpine Linux. Login as root.

## Enable network connectivity

Refer to [alpine.md -> Hardware/peripherals](../alpine.md#network-using-g_ether-usb-gadget).

## Basic setup

```bash
# don't initialize network connections; no disks, no configs, no apk cache
setup-alpine
# enable community repository
sed -i '/v3\.\d*\/community/s/^#//' /etc/apk/repositories
# update apk repos
apk update
# install mkfs.ext4
apk add e2fsprogs
```

## Format root volume

```bash
mkfs.ext4 -L root /dev/mmcblk0p2	# format the root volume
mkdir -p /mnt/root					# create a mountpoint
mount /dev/mmcblk0p2 /mnt/root		# mount the root volume
```

## Install Wi-Fi drivers

Do this now, so that it gets installed to the disk along with the base system.

```bash
# install Wi-Fi firmware
apk add wireless-regdb linux-firmware-ath9k_htc
# copy Wi-Fi EEPROM image
cp /media/mmcblk0p1/eeprom_ar9271.bin /lib/firmware/
```

## Install the OS

```bash
# ignore bootloader updating
export BOOTLOADER=none
# actually install the OS to the disk
setup-disk -m sys -v -s 0 -k firmware-none /mnt/root
# copy kernel modules
mkdir -p /mnt/root/lib/modules
cp -R /lib/modules/`uname -r` /mnt/root/lib/modules/
# automatically mount the boot partition
mkdir -p /mnt/root/boot
echo -e "/dev/mmcblk0p1\t/boot\t\tvfat\tro\t0 0" >> /mnt/root/etc/fstab
# copy Wi-Fi EEPROM image
cp /media/mmcblk0p1/eeprom_ar9271.bin /mnt/root/lib/firmware/
# reboot into the OS
reboot
```

## Serial console via USB

Refer to [alpine.md -> Serial console via USB](../alpine.md#serial-console-via-usb).

## Updating the kernel

Compile a new kernel. Grab the `boot/` directory contents from the build. Copy everything to the `/boot` directory on the device.

Update kernel modules on the device:

```bash
mkdir -p /.modloop/
mount -o loop /boot/boot/modloop-acs /.modloop/
rm -rf /lib/modules/`uname -r`
cp -R /.modloop/modules/* /lib/modules/
umount /.modloop/
rmdir /.modloop/
```

Reboot the device to run the updated kernel.

## Bringing back Fingbox functionality

A barebones Alpine Linux setup will not do what the Fingbox is supposed to do, which is monitoring the network and reporting various data.

Normally, a program called "Fingbox Agent" is responsible for that. In order to make Fingbox Agent run on Alpine, a custom Python package needs to be installed.

1. Ensure you have Python 3.10 or newer installed. If not: `sudo apk add python3`
2. Create a work directory: `sudo mkdir -p /usr/share/fingbox-agent`
3. Create a Python virtual environment: `sudo python3 -m venv /usr/share/fingbox-agent/venv`
4. Run a shell and activate the environment: `sudo bash` and then `source /usr/share/fingbox-agent/venv/bin/activate`
5. Install pysnapd package: `pip install pysnapd`
6. Run the supervisor configuration: `pysnapd /usr/share/fingbox-agent configure`
	- type in the snap store ID found previously in "Backup the firmware" (`model` file)
	- type in the following snap names: `core` and `fingbox-agent` (press Enter when asked about revision)
7. Run the following commands to configure the working environment:

```bash
pushd /usr/share/fingbox-agent/data-ro/
mkdir -p ./log/ ./run/resolvconf/ ./sys/class/gpio/gpio362/ ./dev/
popd

mknod /usr/share/fingbox-agent/data-ro/dev/i2c-0 c 89 0

echo overlook.fingbox.logging.level=DEBUG > /usr/share/fingbox-agent/data-ro/log/log.properties
echo nameserver 8.8.8.8 > /usr/share/fingbox-agent/data-ro/run/resolvconf/resolv.conf

touch /usr/share/fingbox-agent/data-ro/sys/class/gpio/export
touch /usr/share/fingbox-agent/data-ro/sys/class/gpio/unexport
touch /usr/share/fingbox-agent/data-ro/sys/class/gpio/gpio362/direction
touch /usr/share/fingbox-agent/data-ro/sys/class/gpio/gpio362/value

cat << EOF > /usr/share/fingbox-agent/data-ro/entrypoint.sh
cp -R /leds/* /
exec "fingbox.bin" "\$@"
EOF
chmod +x /usr/share/fingbox-agent/data-ro/entrypoint.sh
```

8. Run the supervisor to check if it works: `pysnapd /usr/share/fingbox-agent run -b /proc -r 10 -- bash /entrypoint.sh --dev 1`
9. Logs should start showing up, and the Fingbox LEDs should start blinking. Now, exit the supervisor with Ctrl+C.
10. Make sure Fingbox is not running: `pkill -9 fingbox.bin`
11. Create an OpenRC unit file:

```bash
cat << EOF > /etc/init.d/fingbox-agent
#!/sbin/openrc-run

name="Fingbox Agent"
command="/usr/share/fingbox-agent/venv/bin/pysnapd"
command_args="/usr/share/fingbox-agent run -b /proc -r 10 -- bash /entrypoint.sh"
supervisor="supervise-daemon"

depend() {
	need dbus
}
EOF
chmod +x /etc/init.d/fingbox-agent
```

12. You can exit the root shell now.
13. Start the service: `sudo service fingbox-agent start`
14. If you want to view Fingbox Agent logs, run `sudo tail -F /usr/share/fingbox-agent/data-rw/log/fingbox-agent.log`
