# BC1077 (MID06N/Inet1/Protab2XXL)

Buildroot generates the following outputs in `images/`:

- `bootfs/` - kernel, initramfs, modloop and APK packages for Alpine Linux
- `bootfs.img` - FAT32 image of the bootfs directory
- `sdcard.img` - microSD card image with U-Boot and SPL
- `u-boot-sunxi-with-spl.bin` - U-Boot with SPL and DTB (for booting via FEL)
- `u-boot-dtb.img` - U-Boot with DTB, for updating existing installation in `/boot`

## Flash SD card image

Flash `sdcard.img` to a microSD card, using e.g. `dd` or `Win32DiskImager`.

Insert the SD card into the tablet.

Run this command to run U-Boot via FEL:

```bash
sunxi-fel uboot u-boot-sunxi-with-spl.bin
```

## Prepare UBI partition

Connect an UART adapter to access the U-Boot console.

Run the following commands to create a UBI volume for the root filesystem:

```
mtd erase ubi
ubi part ubi
ubi create env 0x20000
ubi create root
ubi info layout
```

Next, execute `sysboot mmc : any` to boot Alpine Linux from the SD card. Login as root.

## Enable network connectivity

Refer to [network.md](../../docs/network.md). The following steps won't work without a working Internet connection.

## Format root volume

Note: this step installs Linux to the NAND.

```bash
apk add mtd-utils						# install MTD (+UBI) tools
cat /proc/mtd							# make sure there are 4 MTD partitions
ubiattach -p /dev/mtd3					# attach to "ubi" partition
ubinfo -a								# make sure the "env" and "root" volumes are present
mkfs.ubifs -L rootfs /dev/ubi0_1		# format the root volume
# during installation:
mkdir -p /mnt/root						# create a mountpoint
mount -t ubifs /dev/ubi0_1 /mnt/root	# mount the root volume
```

## Install the OS

Refer to [install.md](../../docs/install.md).

Copy the boot files for U-Boot:

```bash
cp -R /media/mmcblk0p1/boot.scr /mnt/root/
cp -R /media/mmcblk0p1/boot /mnt/root/
cp -R /media/mmcblk0p1/extlinux /mnt/root/
```

Rebooting will boot the installed OS. Next, follow the [post-install guide](../../docs/alpine.md).
