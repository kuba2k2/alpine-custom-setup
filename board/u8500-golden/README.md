# Samsung Galaxy S3 mini (GT-I8190N)

Buildroot generates the following outputs in `images/`:

- `bootfs/` - kernel, initramfs, modloop and APK packages for Alpine Linux
- `bootfs.img` - FAT32 image of the bootfs directory
- `golden-u-boot.img.tar` - U-Boot with DTB, for flashing to `Kernel` via Odin
- `golden-u-boot.img` - U-Boot with DTB, for flashing to `Kernel` via TWRP/`dd`

## Flash & run U-Boot

Flash `golden-u-boot.img.tar` using Odin. To enter Download Mode, press and hold `Power`+`Vol-`+`Home`.

Alternatively, flash `golden-u-boot.img` using TWRP.

At first boot the device will fall back to UMS mode, because of no `bootfs` installed.

## (Re-)partition the EMMC

Connect the Galaxy S3 mini to your PC - it should be now visible as a mass-storage device.

*Note: change `/dev/sdc` to the UMS device.*

- `fdisk /dev/sdc`
- `x` / `p` / `r` - print the complete partition table
- `d` / `25` - delete `DATAFS` partition (4.7 GiB)
- `d` / `24` - delete `HIDDEN` partition (320 MiB)
- `d` / `23` - delete `CACHEFS` partition (840 MiB)
- `d` / `22` - delete `SYSTEM` partition (1.2 GiB)
- `n` / `22` / `<Enter>` / `+128M` - create a new 128 MiB partition at index 22
- `t` / `22` / `11` - change type to `Microsoft basic data`
- `n` / `23` / `<Enter>` / `<Enter>` - create a new partition at index 23
- `x` - enter Expert mode
- `n` / `22` / `bootfs` - change label to `bootfs`
- `n` / `23` / `rootfs` - change label to `rootfs`
- `r` - exit Expert mode
- `w` - write changes

The stock partition table:

<details>

```
Disk /dev/sdc: 7.29 GiB, 7818182656 bytes, 15269888 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 52444E41-494F-2044-4D4D-43204449534B
First LBA: 34
Last LBA: 15269854
Alternative LBA: 15269887
Partition entries LBA: 2
Allocated partition entries: 128

Device       Start      End Sectors Type-UUID                            UUID                                 Name
/dev/sdc1        0      255     256 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4D42-522C47505400 MBR,GPT
/dev/sdc2      256     1023     768 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4D61-73746572544F MasterTOC
/dev/sdc3     1024     3071    2048 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-5049-540000000000 PIT
/dev/sdc4     6144     8191    2048 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4D44-354844520000 MD5HDR
/dev/sdc5     8192     9215    1024 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-5354-45626F6F7431 STEboot1
/dev/sdc6     9216    10239    1024 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-5354-45626F6F7432 STEboot2
/dev/sdc7    10240    11263    1024 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-446E-740000000000 Dnt
/dev/sdc8    11264    12287    1024 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-7265-736572766564 reserved
/dev/sdc9    16384    18431    2048 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4353-505341465300 CSPSAFS
/dev/sdc10   18432    20479    2048 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4353-505341465332 CSPSAFS2
/dev/sdc11   20480    53247   32768 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4546-530000000000 EFS
/dev/sdc12   53248    86015   32768 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4D6F-64656D465300 ModemFS
/dev/sdc13   86016   118783   32768 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4D6F-64656D465332 ModemFS2
/dev/sdc14  118784   221183  102400 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-466F-746100000000 Fota
/dev/sdc15  380928   381055     128 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4950-4C204D6F6465 IPL Modem
/dev/sdc16  385024   413695   28672 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4D6F-64656D000000 Modem
/dev/sdc17  417792   421887    4096 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4C6F-6B6534000000 Loke4
/dev/sdc18  421888   425983    4096 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-326E-644C6F6B6534 2ndLoke4
/dev/sdc19  425984   458751   32768 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-5041-52414D000000 PARAM
/dev/sdc20  458752   491519   32768 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4B65-726E656C0000 Kernel
/dev/sdc21  491520   524287   32768 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4B65-726E656C3200 Kernel2
/dev/sdc22  524288  2981887 2457600 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-5359-5354454D0000 SYSTEM
/dev/sdc23 2981888  4702207 1720320 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4341-434845465300 CACHEFS
/dev/sdc24 4702208  5357567  655360 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4849-4444454E0000 HIDDEN
/dev/sdc25 5357568 15269854 9912287 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4441-544146530000 DATAFS
```

</details>

The modified partition table should look like this:

```
Disk /dev/sdc: 7.29 GiB, 7818182656 bytes, 15269888 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 52444E41-494F-2044-4D4D-43204449534B
First LBA: 34
Last LBA: 15269854
Alternative LBA: 15269887
Partition entries LBA: 2
Allocated partition entries: 128

Device      Start      End  Sectors Type-UUID                            UUID                                 Name
/dev/sdc1       0      255      256 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4D42-522C47505400 MBR,GPT
/dev/sdc2     256     1023      768 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4D61-73746572544F MasterTOC
/dev/sdc3    1024     3071     2048 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-5049-540000000000 PIT
/dev/sdc4    6144     8191     2048 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4D44-354844520000 MD5HDR
/dev/sdc5    8192     9215     1024 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-5354-45626F6F7431 STEboot1
/dev/sdc6    9216    10239     1024 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-5354-45626F6F7432 STEboot2
/dev/sdc7   10240    11263     1024 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-446E-740000000000 Dnt
/dev/sdc8   11264    12287     1024 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-7265-736572766564 reserved
/dev/sdc9   16384    18431     2048 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4353-505341465300 CSPSAFS
/dev/sdc10  18432    20479     2048 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4353-505341465332 CSPSAFS2
/dev/sdc11  20480    53247    32768 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4546-530000000000 EFS
/dev/sdc12  53248    86015    32768 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4D6F-64656D465300 ModemFS
/dev/sdc13  86016   118783    32768 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4D6F-64656D465332 ModemFS2
/dev/sdc14 118784   221183   102400 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-466F-746100000000 Fota
/dev/sdc15 380928   381055      128 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4950-4C204D6F6465 IPL Modem
/dev/sdc16 385024   413695    28672 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4D6F-64656D000000 Modem
/dev/sdc17 417792   421887     4096 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4C6F-6B6534000000 Loke4
/dev/sdc18 421888   425983     4096 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-326E-644C6F6B6534 2ndLoke4
/dev/sdc19 425984   458751    32768 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-5041-52414D000000 PARAM
/dev/sdc20 458752   491519    32768 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4B65-726E656C0000 Kernel
/dev/sdc21 491520   524287    32768 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 52444E41-494F-2044-4B65-726E656C3200 Kernel2
/dev/sdc22 524288   786431   262144 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7 4D5F643E-02F7-984B-A9C2-DB6571DDF9AD bootfs
/dev/sdc23 786432 15269854 14483423 0FC63DAF-8483-4772-8E79-3D69D8477DE4 A6D07C03-0992-8149-805A-67BD452FB822 rootfs
```

## Flash boot partition

Either:

1. Type `fastboot usb 0` on the U-Boot console. Flash the bootfs partition using `fastboot flash bootfs bootfs.img`.

or:

2. Flash the bootfs partition using `dd if=bootfs.img of=/dev/sdc22`.

Resetting the device should boot Alpine Linux. Connecting the UART cable (before powering on the phone) will let you use the Linux console.

## Enable network connectivity

Refer to [network.md](../../network.md). The following steps won't work without a working Internet connection.

To reload Wi-Fi drivers after installing firmware:

```bash
rmmod brcmfmac && modprobe brcmfmac
```

## Format root volume

```bash
apk add e2fsprogs					# install mkfs.ext3
mkfs.ext4 -L rootfs /dev/mmcblk?p23	# format the root volume
```

## Install the OS

Refer to [install.md](../../docs/install.md).

Rebooting will boot the installed OS. Next, follow the [post-install guide](../../docs/alpine.md).
