# Alpine and making it usable - post-install

## Environment setup

```bash
# install sudo
apk add sudo
apk del doas
ln -s $(which sudo) /usr/bin/doas
# enable for 'wheel' group
echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheel
# same without password
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel-nopw

# replace busybox
apk add util-linux usbutils coreutils binutils findutils grep iproute2 wget less
# add vim
apk add vim

# install bash
apk add bash bash-completion
sed -i s#/bin/ash#/bin/bash#g /etc/passwd
# enable color prompt
ln -s /etc/profile.d/color_prompt.sh.disabled /etc/profile.d/color_prompt.sh

# install duf
apk add curl
curl -s https://api.github.com/repos/muesli/duf/releases/latest \
	| grep "browser_download_url.*$(apk --print-arch)\.apk" \
	| cut -d : -f 2,3 \
	| tr -d \" \
	| wget -qi -
apk add --allow-untrusted duf_*_$(apk --print-arch).apk
rm -f duf_*_$(apk --print-arch).apk

# install several other useful utilities
apk add mc htop lsblk
# Midnight Commander somehow overrides custom prompt from /etc/profile.d
echo source /etc/profile.d/color_prompt.sh > ~/.bashrc
```

### Shell environment vars

This will configure environment variables to enable color terminal, history control, locale/charset, etc.

Paste this into `/etc/profile.d/acs.sh`:

```bash
export CHARSET=UTF-8
export LANG=en_US.UTF-8
export LC_COLLATE=en_US
export HISTCONTROL=ignoreboth:erasedups
export EDITOR=/usr/bin/vim
export TERM=xterm-256color
```

### SSH server

```bash
# replace openssh with dropbear
apk add dropbear openssh-sftp-server
pkill -9 sshd
service dropbear start
rc-update add dropbear
```

### NetworkManager

Installing NetworkManager on Alpine seems simple, unless you spend many hours trying to fix it, because nobody has ever mentioned that `udev` is required for NM to work at all.

Run **as root**:
```bash
apk add eudev networkmanager networkmanager-cli networkmanager-tui
# install Wi-Fi support
apk add networkmanager-wifi
apk add wpa_supplicant
rc-update add wpa_supplicant
# errors are normal here
setup-devd udev
rc-update del hwdrivers sysinit
rc-update -a del networking
rc-update -a del wpa_supplicant
rc-update add networkmanager boot
rc-update add udev sysinit
rc-update add udev-postmount default
rc-update add udev-settle sysinit
rc-update add udev-trigger sysinit
```

Edit `/etc/network/interfaces` and remove all interfaces except `lo`.

Run `nmtui` to configure your network connections (you probably won't be able to activate them yet). Reboot to start NetworkManager and activate the network.

## Hardware/peripherals

### Network using an Ethernet cable

Connect the Ethernet cable (Wi-Fi won't work yet).

```bash
# enable the interface
ip link set eth0 up
# run a DHCP client
apk add dhcpcd
dhcpcd
```

### Network using `g_ether` USB gadget

Connect the device to a Windows PC using USB.

```bash
# enable the RNDIS gadget
modprobe g_ether
# after this, right-click your Ethernet/Wi-Fi adapter in Windows
# go to Properties -> Sharing
# enable Internet Connection Sharing, choose the new virtual adapter
ip link set dev usb0 up
# run a DHCP client
apk add dhcpcd
dhcpcd
# optional: replace the default route,
# which for some reason doesn't work sometimes
ip route delete default
ip route add default via 192.168.137.1
```

### Serial console via USB

Enable a USB Serial gadget configuration to manage the device via USB:

```bash
echo g_serial > /etc/modules-load.d/g_serial.conf
echo ttyGS0::respawn:/sbin/getty -L 0 ttyGS0 115200 vt100 >> /etc/inittab
echo ttyGS0 >> /etc/securetty
```

### Auto-mounting USB drives

```bash
apk add udisks2 udiskie
# make it mount to /media/ instead of /run/media/<user>/
echo "ENV{ID_FS_USAGE}==\"filesystem|other|crypto\", ENV{UDISKS_FILESYSTEM_SHARED}=\"1\"" > /etc/udev/rules.d/99-udisks2.rules
```

Create `/etc/init.d/udiskie`:

```bash
#!/sbin/openrc-run

supervisor=supervise-daemon
command=/usr/bin/udiskie --automount --no-notify --no-tray --no-file-manager --no-terminal

description="udiskie"

depend() {
   need dbus
}
```

Make it executable and make it autorun:

```bash
chmod 755 /etc/init.d/udiskie
rc-update add udiskie
```

### SD card/eMMC as USB UMS

```bash
umount /dev/mmcblk0p1
rmmod g_ether
modprobe g_mass_storage file=/dev/mmcblk0
# when you're done:
rmmod g_mass_storage
mount /dev/mmcblk0p1 /media/mmcblk0p1
```
