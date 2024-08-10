# Samsung Galaxy S3 (GT-I9300)

Buildroot generates the following outputs in `images/`:

- `bootfs/` - kernel, initramfs, modloop and APK packages for Alpine Linux
- `bootfs.img` - FAT32 image of the bootfs directory
- `i9300-bootloader-emmc.bin` - U-Boot with SPL, DTB and first-stage loader
<!-- - `i9300-alpine3.19.0-linux6.1.64.img.tar` - boot.img for flashing to `BOOT` via Odin -->
<!-- - `i9300-alpine3.19.0-linux6.1.64.img` - boot.img for flashing to `BOOT` via TWRP/`dd` -->

U-Boot sources taken from [An (almost) fully libre Galaxy S3](https://blog.forkwhiletrue.me/posts/an-almost-fully-libre-galaxy-s3/) by [Simon Shields](https://forkwhiletrue.me/).

## Flash & run U-Boot

Flash `i9300-bootloader-emmc.bin` using the instructions from the blog post linked above.

At first boot the device will fall back to UMS mode, because of no `bootfs` installed.

Note: for testing, you can install the bootfs to an SD card instead. U-Boot will first try to run `boot.scr` from there.

### Updating U-Boot

<details>

Load from file:

```bash
fatload mmc 1:1 0x50000000 i9300-bootloader-emmc.bin
```

Load from `BOOT` partition (flashed by fastboot first):

```bash
read mmc 0 BOOT 0x50000000 0x0 end
```

---

Write to eMMC `boot0` area:

```bash
mmc dev 0 1
mmc write 0x50000000 0x0 0x2000
```

Verify with `md.b` (optional):

```bash
mmc read 0x50000000 0x0 0x2000
md.b 0x50000000 0x400
```

</details>

### Charging in U-Boot

To enable battery charging in U-Boot console, run this:

```
charger dev charger && charger wait muic-max77693 fuelgauge
```

and connect the phone for USB charging.

## (Re-)partition the EMMC

Reboot the device into Recovery mode (`Power` + `Home` + `Vol+`). This will enable UMS mode.

Connect the Galaxy S3 to your PC - it should be now visible as a mass-storage device.

*Note: change `/dev/sdd` to the UMS device.*

- `fdisk /dev/sdd`
- `d` / `12` - delete `USERDATA` partition (11.5 GiB)
- `d` / `11` - delete `OTA` partition (8 MiB)
- `d` / `10` - delete `HIDDEN` partition (560 MiB)
- `d` / `9` - delete `SYSTEM` partition (1.5 GiB)
- `d` / `8` - delete `CACHE` partition (1 GiB)
- `n` / `8` / `<Enter>` / `+128M` - create a new 128 MiB partition at index 8
- `t` / `8` / `11` - change type to `Microsoft basic data`
- `n` / `8` / `<Enter>` / `<Enter>` - create a new partition at index 9
- `x` - enter Expert mode
- `n` / `8` / `bootfs` - change label to `bootfs`
- `n` / `9` / `rootfs` - change label to `rootfs`
- `r` - exit Expert mode
- `w` - write changes

The final partition table should look like this:

```
Disk /dev/sdd: 14.69 GiB, 15758000128 bytes, 30777344 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 52444E41-494F-2044-4D4D-43204449534B
First LBA: 34
Last LBA: 30777310
Alternative LBA: 30777343
Partition entries LBA: 2
Allocated partition entries: 128

Device      Start      End  Sectors Type-UUID                            UUID                                 Name
/dev/sdd1    8192    16383     8192 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-424F-544130000000 BOTA0
/dev/sdd2   16384    24575     8192 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-424F-544131000000 BOTA1
/dev/sdd3   24576    65535    40960 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4546-530000000000 EFS
/dev/sdd4   65536    81919    16384 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-5041-52414D000000 PARAM
/dev/sdd5   81920    98303    16384 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-424F-4F5400000000 BOOT
/dev/sdd6   98304   114687    16384 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-5245-434F56455259 RECOVERY
/dev/sdd7  114688   180223    65536 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-5241-44494F000000 RADIO
/dev/sdd8  180224   442367   262144 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 D7B38EA0-8FAE-FE47-AFA0-2B99E904862A bootfs
/dev/sdd9  442368 30777310 30334943 0FC63DAF-8483-4772-8E79-3D69D8477DE4 F7E63448-E359-EE43-80DD-A00281CB5709 rootfs
```

## Flash boot partition

Reboot the device into Fastboot mode (`Power` + `Home` + `Vol-`).

Flash the bootfs partition using `fastboot flash bootfs bootfs.img`.

Resetting the device should boot Alpine Linux. Connecting the UART cable (before powering on the phone) will let you use the Linux console.

## Enable network connectivity

Refer to [network.md](../../network.md). The following steps won't work without a working Internet connection.

## Format root volume

```bash
apk add e2fsprogs					# install mkfs.ext3
mkfs.ext4 -L rootfs /dev/mmcblk?p9	# format the root volume
```

## Install the OS

```bash
# don't initialize network connections; no disks, no configs, no apk cache
setup-alpine
# create a mountpoint, mount the root volume
mkdir -p /mnt/root
mount `blkid -L rootfs` /mnt/root
# ignore bootloader installation
export BOOTLOADER=none
# install system files to the root volume
setup-disk -m sys -v -s 0 -k firmware-none /mnt/root
# copy kernel modules
mkdir -p /mnt/root/lib/modules
cp -R /lib/modules/`uname -r` /mnt/root/lib/modules/
```

## Post-install

Add necessary firmware packages:

```
apk add linux-firmware-s5p-mfc
```
