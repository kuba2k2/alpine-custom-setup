# Q8/Q8A/Q88 Allwinner A13 Tablet

## Prepare boot files

Format a microSD card as FAT32.

Copy the contents of `boot/` directory to the card.

## Prepare U-Boot upgrade image

Copy `acs/sunxi-common/a13-livesuit` to a Windows host. Copy `boot/sunxi-spl.bin` and `boot/u-boot-dtb.img` to the directory.

Run `drabon.bat` to create a LiveSuit image. The image is saved in `u-boot-sunxi.img` file.

## Flash U-Boot

Launch LiveSuit. Click the following:

- Yes
- Mandatory
- Next
- Yes
- *choose u-boot-sunxi.img*
- Finish

Connect the tablet in FEL mode with a USB cable. The flashing process will begin shortly. Answer "No" to the "mandatory format" question.

**NOTE:** You have to run LiveSuit *before* connecting the device. Otherwise it will never start flashing.

After flashing, the device should show a U-Boot console on the LCD screen. Rebooting should make it boot directly from NAND.

<!--
## Updating U-Boot

Insert the boot SD card with an updated `u-boot-dtb.img` file.

DOESN'T WORK.

```
load mmc 0:1 ${loadaddr} /u-boot-dtb.img
mtd erase uboot
mtd write.raw uboot ${fileaddr} 0 ${filesize}
mtd erase uboot-rescue
mtd write.raw uboot-rescue ${fileaddr} 0 ${filesize}
```
-->

## Prepare UBI partition

```
mtd erase ubi
ubi part ubi
ubi create env 0x20000
ubi create root
ubi info layout
```

## Boot Linux

Initial bootup of Linux from the SD card:

```
run bootcmd_mmc0
```

Login as root.

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
# install MTD (+UBI) tools
apk add mtd-utils
```

## Format root volume

```bash
cat /proc/mtd							# make sure there are 5 MTD partitions
ubiattach -p /dev/mtd4					# attach to "ubi" partition
ubinfo -a								# make sure the "env" and "root" volumes are present
mkfs.ubifs /dev/ubi0_1					# format the root volume
mkdir -p /mnt/root						# create a mountpoint
mount -t ubifs /dev/ubi0_1 /mnt/root	# mount the root volume
```

## Install the OS

```bash
# copy boot files
cp -R /media/mmcblk0p1/boot.scr /mnt/root/
cp -R /media/mmcblk0p1/boot /mnt/root/
cp -R /media/mmcblk0p1/extlinux /mnt/root/
# ignore bootloader updating
export BOOTLOADER=none
# install system files to the root volume
setup-disk -m sys -v -s 0 -k firmware-none /mnt/root
# copy kernel modules
mkdir -p /mnt/root/lib/modules
cp -R /lib/modules/`uname -r` /mnt/root/lib/modules/
# reboot into the OS
reboot
```

## Touchscreen support

```bash
# mount the SD card
mkdir -p /media/mmcblk0p1/
mount /dev/mmcblk0p1 /media/mmcblk0p1
# copy touchscreen firmware
mkdir -p /lib/firmware/silead/
cp /media/mmcblk0p1/gsl1680.fw /lib/firmware/silead/
# reload the module
rmmod silead && modprobe silead
```

## Updating the kernel

Compile a new kernel. Grab the `boot/` directory contents to the SD card used before.

```bash
mkdir -p /media/mmcblk0p1/
mount /dev/mmcblk0p1 /media/mmcblk0p1
mkdir -p /.modloop/
mount -o loop /media/mmcblk0p1/boot/modloop-acs /.modloop/
rm -rf /boot/*
rm -rf /lib/modules/`uname -r`
cp -R /media/mmcblk0p1/boot.scr /
cp -R /media/mmcblk0p1/boot /
cp -R /.modloop/modules/* /lib/modules/
umount /.modloop/
umount /media/mmcblk0p1/
rmdir /.modloop/
reboot
```

In case you're copying directly to `/boot`, you need to update kernel modules:

```bash
mkdir -p /.modloop/
mount -o loop /boot/modloop-acs /.modloop/
rm -rf /lib/modules/`uname -r`
cp -R /.modloop/modules/* /lib/modules/
umount /.modloop/
rmdir /.modloop/
```

<!--

### fbturbo X11 driver

DOESN'T WORK.

```bash
apk add git build-base autoconf libtool automake
apk add xorg-server-dev xorgproto libltdl libdrm libdrm-dev
git clone https://github.com/ssvb/xf86-video-fbturbo.git
cd xf86-video-fbturbo
autoreconf -vi
./configure --prefix=/usr
make
make install # as root
cp xorg.conf /etc/X11/xorg.conf # as root
```

-->
