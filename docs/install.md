# Alpine Linux installation

First, make sure internet access works, by using `ping`.

Provided that you have already created and formatted an EXT4 partition labelled `rootfs`, run the following commands to install Alpine Linux:

```bash
# NOTE: don't skip interface configuration - otherwise the routing table will be cleared
# - the recommended NTP client is "busybox"
# - the recommended SSH server is "dropbear"
# - enable community repository when asked
# - don't configure install disks
# - don't store configs
# - don't use apk cache
setup-alpine
# install real blkid
apk add blkid
# create a mountpoint, mount the root volume
mkdir -p /mnt/root
mount `blkid -L rootfs` /mnt/root
# ignore bootloader installation
export BOOTLOADER=none
# install system files to the root volume
setup-disk -m sys -v -s 0 -k firmware-none /mnt/root
# copy kernel modules
mkdir -p /mnt/root/lib/modules/
cp -R /lib/modules/`uname -r` /mnt/root/lib/modules/
# copy extra firmware files
mkdir -p /mnt/root/lib/firmware/
cp -Rn /lib/firmware/* /mnt/root/lib/firmware/
```
