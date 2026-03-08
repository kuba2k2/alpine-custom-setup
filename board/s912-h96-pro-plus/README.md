# H96 Pro+

Buildroot generates the following outputs in `images/`:

- `bootfs/` - kernel, initramfs, modloop and APK packages for Alpine Linux
- `bootfs.img` - FAT32 image of the bootfs directory
- `sdcard.img` - microSD card image with bootfs and U-Boot
- `u-boot-dtb.bin` - U-Boot as a raw binary, for running via vendor U-Boot
- `u-boot-dtb.fip` - U-Boot as an Amlogic FIP image, for running directly from eMMC/SD
- `u-boot-live.img` - U-Boot as an Amlogic upgrade package, for flashing over USB

## Alternative: boot from stock U-Boot

To test if the system works properly before installing it to the internal eMMC, the stock (vendor) U-Boot can be used.

1. Flash `sdcard.img` to a microSD card, using e.g. `dd` or `Win32DiskImager`.
2. Enter U-Boot console by connecting an UART adapter and interrupting autoboot.
3. Insert the microSD card into the device.
4. Use `fatload mmc 0:1 0x1000000 u-boot-dtb.bin; go 0x1000000` to start mainline U-Boot.
5. The device should start booting Alpine Linux.

Connect an UART adapter or HDMI monitor to access the Linux console. Login as root.

## Recommended: flash the firmware

1. Enter Amlogic USB download mode - connect an USB A-A cable and power on the device.
2. Flash `u-boot-live.img` using Amlogic USB Burning Tool. This might fail with a `Switch status` error - this is expected.
3. The device should be now visible on your PC as a mass-storage device.
4. Flash `sdcard.img` to the USB mass-storage device, using e.g. `dd` or `Win32DiskImager`.
5. Disconnect USB and reset the device - it should start booting Alpine Linux.

Connect an UART adapter or HDMI monitor to access the Linux console. Login as root.

## Enable network connectivity

Refer to [network.md](../../docs/network.md). The following steps won't work without a working Internet connection.

**IMPORTANT:** Wi-Fi may not work without `udev` configured. Run `setup-devd udev` to install `eudev` (using an Ethernet connection), and reboot to make Wi-Fi available.

To reload Wi-Fi drivers after installing firmware:

```bash
rmmod ath10k_sdio; modprobe ath10k_sdio
```

## Create & format root volume

Note: this step installs Linux to the eMMC.

First, create the root volume using `fdisk /dev/mmcblk?`:

- `n` / `p` / `2` / `270336` / `<Enter>` - create a partition taking up the remaining free space
- `t` / `2` / `83` - set type to Linux (optional, should already be set)
- `p` - show the partition table

The partition table should now look like this:

```
Device       Boot StartCHS    EndCHS        StartLBA     EndLBA    Sectors  Size Id Type
/dev/mmcblk1p1 *  0,130,3     16,211,3          8192     270335     262144  128M  c Win95 FAT32 (LBA)
/dev/mmcblk1p2    425,12,1    1023,211,3      270336   61071359   60801024 28.9G 83 Linux
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
