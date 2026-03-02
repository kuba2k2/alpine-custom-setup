# Updating the system

## Updating Linux

The files required to boot Linux are the kernel itself (`vmlinuz-acs`), the initial ramdisk (`initramfs-acs`), the modloop (`modloop-acs`) and device trees (`dtbs-acs/`).

- On most targets (that boot from eMMC/SD), the boot files are installed in the `/boot` partition.
- On targets with NAND (and UBIFS), the boot files are installed directly to the root directory (`/`).

Updating Linux involves copying the files from Buildroot's `images/bootfs/` to the boot partition.

1. Mount the boot partition, if not mounted already: `mount --onlyonce /boot`.
2. Copy all files and directories from `images/bootfs/` to the device's boot partition - this should be done on the device itself.
3. Update modloop to ensure kernel modules are on the device's rootfs: `update-modloop /boot/boot/modloop-acs`.
4. Update `apkovl` to copy board-specific files to the device's rootfs: `tar -C / -xaovf /boot/alpine.apkovl.tar.gz --exclude 'etc/*'`.
4. Reboot the device to start the updated Linux kernel.

## Updating U-Boot

The method of installing U-Boot differs for most SoC families, so appropriate steps must be taken, depending on the device.

### Allwinner - with eMMC/SD

TBD

### Amlogic - with eMMC

1. Copy the U-Boot FIP file from Buildroot's `images/` to the device - `u-boot-dtb.fip`.
2. Flash it to the `mmcblk1` device, skipping the MBR - `dd if=u-boot-dtb.fip of=/dev/mmcblk1 bs=512 seek=1`.
3. Reboot the device to start the updated U-Boot.

### Other devices

Refer to the main device README to find out how to install U-Boot.
