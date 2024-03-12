# Denver TAC-70072 Rockchip RK2926 Tablet

Buildroot generates the following outputs in `images/`:

- `bootfs/` - APK packages for Alpine Linux
- `rockchip/` - flashing files (per-partition images)
- `rk2926-tac-70072-3.19.0-live.img` - kernel package for first-time bootup
- `rk2926-tac-70072-3.19.0-root.img` - use this after installing the OS

## Prepare boot files

Flash `sdcard.img` to a microSD card, using e.g. `dd` or `Win32DiskImager`.

## Flash the kernel

Connect the tablet to a PC in Loader mode.

Insert the microSD card into the tablet (use an USB microSD reader for best results).

Using `AndroidTool`, or another Rockchip flashing tool, flash the generated "live" image. The tablet will start booting
into Linux.

**Note:** if you've inserted the microSD card into the tablet's reader and it hangs at "Mounting boot media":

- unplug the microSD card, wait for it to fail mounting (otherwise it will never continue)
- plug the card back in
- connect an USB keyboard
- `mkdir -p /media/mmcblk0p1`
- `mount /dev/mmcblk0p1 /media/mmcblk0p1`
- `exit`

After successful bootup, login as root.

```bash
# setup the current date for SSL to work
date -s 2024-01-01
```

## Enable network connectivity

Refer to [network.md](../../docs/network.md). The following steps won't work without a working Internet connection.

## Format root partition

```bash
cat /proc/mtd						# make sure there are 6 MTD partitions
apk add e2fsprogs					# install mkfs.ext3
mkfs.ext3 -L rootfs /dev/mtdblock5	# format the root volume
```

## Install the OS

Refer to [install.md](../../docs/install.md).

Now, reconnect the tablet in Loader mode and flash the generated "root" image.

Rebooting will boot the installed OS. Next, follow the [post-install guide](../../docs/alpine.md).

## Technical info

TAC-70072:

Component   | IC                | GPIOs
------------|-------------------|------
Mainboard   | 86V V2.1 20121228 |
CPU         | RK2926            |
NAND        | TC58TEG6DCJTA00   |
PMIC+RTC    | TPS65910          |
Gsensor     | ?                 |
Amplifier   | PT5305N           |
Charger     | EMC5040           |
Touchscreen | GSL1680           |
Wi-Fi       | RTL8188EUS        |

TAC-70072KC:

Component   | IC                  | GPIOs
------------|---------------------|------
Mainboard   | RC_P2926_Y703B_V2.5 |
CPU         | RK2926              |
NAND        | SDTNQGAMA-008G      |
PMIC+RTC    | TPS65910            |
Gsensor     | ?                   |
Amplifier   | PT5305N             |
Charger     | ?                   |
Touchscreen | AW5206              |
Wi-Fi       | RTL8188ETV          |
