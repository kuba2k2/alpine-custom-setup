# Banana Pi M2+

Buildroot generates the following outputs in `images/`:

- `bootfs/` - kernel, initramfs, modloop and APK packages for Alpine Linux
- `bootfs.img` - FAT32 image of the bootfs directory
- `sdcard.img` - microSD card image with U-Boot and SPL
- `u-boot-sunxi-with-spl.bin` - U-Boot with SPL and DTB (for booting via FEL)
- `u-boot-dtb.img` - U-Boot with DTB, for updating existing installation in `/boot`

## Flash SD card image

Flash `sdcard.img` to a microSD card, using e.g. `dd` or `Win32DiskImager`.

Insert the SD card into the Banana Pi board - it should start booting Alpine Linux.

Connect an UART adapter or HDMI monitor to access the Linux console. Login as root.

## Enable network connectivity

Refer to [network.md](../../docs/network.md). The following steps won't work without a working Internet connection.

To reload Wi-Fi drivers after installing firmware:

```bash
rmmod brcmfmac && modprobe brcmfmac
```

## Create & format root volume

Note: this step installs Linux to SD card, not the eMMC.

First, create the root volume in `fdisk /dev/mmcblk?`:

- `n` / `p` / `2` / `264192` / `<Enter>` - create a partition taking up the remaining free space
- `t` / `2` / `83` - set type to Linux (optional, should already be set)
- `p` - show the partition table

The partition table should now look like this:

```
Device       Boot StartCHS    EndCHS        StartLBA     EndLBA    Sectors  Size Id Type
/dev/mmcblk2p1 *  0,32,33     16,113,33         2048     264191     262144  128M  c Win95 FAT32 (LBA)
/dev/mmcblk2p2    70,25,28    1023,113,33     264192   62333951   62069760 29.5G 83 Linux
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

## Extra: additional USB port

The Banana Pi M2+ has an additional, 4th USB port, in the form of an unsoldered pin header.

The two pin holes right next to GPIO pins 39/40 are USB data pins:

```
| .. | .. |
| 37 | 38 |
| 39 | 40 |
+----+----+
| D- | D+ |
+----+----+
```

To enable support for the USB `ehci3` and `ohci3` controllers, add the following line to `/boot/extlinux/extlinux.conf`:

```
FDTOVERLAYS /boot/dtbs-acs/sunxi-h3-usb3.dtbo
```
