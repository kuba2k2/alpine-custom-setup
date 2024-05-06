# Fingbox v1

## Before you start: backup the firmware

1. First of all - backup the stock firmware using U-Boot that's already installed on the device. You'll need to open it up to find the UART port on the other side of the main PCB.
2. Plug in any USB flash drive and use U-Boot to dump the eMMC (at least the first 2 GiB to have an usable backup). You can probably find many guides on how to do that; I don't remember the exact steps.
3. Having a working eMMC backup, open the 2-nd "recovery" partition (the eMMC is MBR-partitioned). You can do this with a good hex editor such as WinHex, or using `fdisk` and `dd` if you know your way around Linux.
4. There's a `compressed_p3.xz` file on the recovery partition. It contains the stock filesystem of the Ubuntu Core 16 distribution running on the Fingbox. Decompress that file to get a raw image of the EXT4 FS.
5. Mount or extract the EXT4 image. Navigate to `/system-data/var/lib/snapd/seed/`.
6. Find the Snap store ID in `assertions/model` file. Find the list of Snap IDs in `seed.yaml` file.
7. Decompress `snaps/domotz-platform-kernel_1.snap` (SquashFS archive). Grab `firmware/eeprom_ar9271.bin` from the filesystem.

I'm not providing Snap IDs or the firmware file here - if you own a Fingbox, you can find it yourself.

---

## Building

Buildroot generates the following outputs in `images/`:

- `bootfs/` - kernel, initramfs, modloop and APK packages for Alpine Linux
- `bootfs.img` - FAT32 image of the bootfs directory
- `sdcard.img` - microSD card image with bootfs and U-Boot SPL
- `u-boot-dtb.img` - U-Boot with DTB, for updating existing installation in `/boot`
- `u-boot-dtb.bin` - U-Boot with DTB, for running in FEL mode
- `sunxi-spl.bin` - U-Boot SPL, for running in FEL mode

## Flash the firmware

Enter FEL mode - connect the USB cable while pressing the `UBOOT` button.

Run these commands to flash SPL onto the EMMC and enable UMS mode:

```bash
# run SPL
sunxi-fel spl sunxi-spl.bin
# run U-Boot Proper
sunxi-fel write 0x4a000000 u-boot-dtb.bin
# write SPL for flashing
sunxi-fel write 0x43000000 sunxi-spl.bin
# write flashing commands
sunxi-fel write 0x43100000 fel-spl-ums.env
# jump to U-Boot
sunxi-fel exe 0x4a000000
```

The Fingbox should be now visible on your PC as a mass-storage device.

Flash `sdcard.img` to the Fingbox mass-storage device, using e.g. `dd` or `Win32DiskImager`.

The Fingbox should now have a MBR partition table with a single 128 MiB FAT32 partition. Put `eeprom_ar9271.bin` extracted before on the boot partition.

Reset the board - it should start booting Alpine Linux.

Connect an UART adapter or HDMI monitor to access the Linux console. Login as root.

## Enable network connectivity

Refer to [network.md](../../docs/network.md). The following steps won't work without a working Internet connection.

To install Wi-Fi EEPROM image (after installing firmware):

```bash
cp /media/mmcblk0p1/eeprom_ar9271.bin /lib/firmware/
```

To reload Wi-Fi drivers after installing firmware:

```bash
rmmod ath9k_htc && modprobe ath9k_htc
```

## Create & format root volume

Note: this step installs Linux to the eMMC.

First, create the root volume using `fdisk /dev/mmcblk?`:

- `n` / `p` / `2` / `<Enter>` / `<Enter>` - create a partition taking up the remaining free space
- `t` / `2` / `83` - set type to Linux (optional, should already be set)
- `p` - show the partition table

The partition table should now look like this:

```
??? TBD
```

Exit `fdisk` and write changes using `w`. If it fails to reread the partition table, reboot the system (remember to configure network again).

Format the root volume:

```bash
apk add e2fsprogs					# install mkfs.ext4
mkfs.ext4 -L rootfs /dev/mmcblk?p2	# format the root volume
```

## Install the OS

Refer to [install.md](../../docs/install.md).

Rebooting will boot the installed OS. Next, follow the [post-install guide](../../docs/alpine.md).

## Extra: bringing back Fingbox functionality

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
