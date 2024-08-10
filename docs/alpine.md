# Alpine and making it usable - post-install

## Environment setup

```bash
# enable community repository
setup-apkrepos -c -1
# make it cleaner
cat /etc/apk/repositories | sort | uniq | tee /etc/apk/repositories

# install sudo
apk add sudo
apk del doas
ln -s $(which sudo) /usr/bin/doas
# enable for 'wheel' group - without password
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel-nopw
# same with password
#echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheel
# keep EDITOR choice
echo 'Defaults env_keep += "EDITOR"' > /etc/sudoers.d/env-editor
# block root password login (still works via UART/fbconsole or SSH with pubkey)
passwd -d root

# replace busybox
apk add util-linux usbutils coreutils binutils findutils grep iproute2 wget less diffutils blkid
# add vim
apk add vim

# install bash
apk add bash bash-completion
# replace each user's shell
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

# for armhf, use the armv7 version:
curl -s https://api.github.com/repos/muesli/duf/releases/latest \
	| grep "browser_download_url.*armv7\.apk" \
	| cut -d : -f 2,3 \
	| tr -d \" \
	| wget -qi -
apk add --allow-untrusted duf_*_armv7.apk
rm -f duf_*_armv7.apk

# replace openssh with dropbear
apk add dropbear openssh-sftp-server
pkill -9 sshd
service dropbear start
rc-update add dropbear

# install several other useful utilities
apk add mc htop lsblk
apk add btop
# Midnight Commander somehow overrides custom prompt from /etc/profile.d
# add to each user's .bashrc
echo source /etc/profile.d/color_prompt.sh >> ~/.bashrc
ls -1 /home | xargs -I{} bash -c "echo source /etc/profile.d/color_prompt.sh >> /home/{}/.bashrc"

# support mDNS discovery
apk add avahi
rc-update add avahi-daemon

# set noatime for /
sed -i s/rw,relatime/rw,noatime/g /etc/fstab

# auto-mount /boot (only for SD/eMMC, not for NAND)
mkdir -p /boot
echo "LABEL=bootfs /boot vfat rw,noatime 0 0" >> /etc/fstab
```

### Shell environment vars

This will configure environment variables to enable color terminal, history control, locale/charset, etc.

If you're using the framebuffer console (no 256 colors support usually):

```bash
cat > /etc/profile.d/acs.sh << EOF
export CHARSET=UTF-8
export LANG=en_US.UTF-8
export LC_COLLATE=en_US
export HISTCONTROL=ignoreboth:erasedups
export EDITOR=/usr/bin/vim
export TERM=xterm-color
EOF
source /etc/profile.d/acs.sh
```

If you're using PuTTY/SSH/terminal emulator:

```bash
cat > /etc/profile.d/acs.sh << EOF
export CHARSET=UTF-8
export LANG=en_US.UTF-8
export LC_COLLATE=en_US
export HISTCONTROL=ignoreboth:erasedups
export EDITOR=/usr/bin/vim
export TERM=xterm-256color
EOF
source /etc/profile.d/acs.sh
```

### NetworkManager

Installing NetworkManager on Alpine seems simple, unless you spend many hours trying to fix it, because nobody has ever mentioned that `udev` is required for NM to work at all.

Run **as root**:
```bash
apk add eudev networkmanager networkmanager-cli networkmanager-tui
# install Wi-Fi support
apk add networkmanager-wifi
apk add wpa_supplicant
# configure udev
setup-devd udev
rc-update -a del networking
rc-update -a del wpa_supplicant
rc-update add networkmanager boot
# start NetworkManager
service networkmanager start
```

Edit `/etc/network/interfaces` and remove all interfaces except `lo`.

Check state of network interfaces with `nmcli dev`. If Wi-Fi is `unmanaged`, you'll most likely need to reboot.

Run `nmtui` to configure your network connections. If you're not able to activate any connections, reboot.

### Helper script to update modloop

```bash
cat > /usr/sbin/update-modloop << EOF
echo "Updating modloop from \$1"
mkdir -p /.modloop/
mount -o loop \$1 /.modloop/
cp -R /.modloop/modules/* /lib/modules/
umount /.modloop/
rmdir /.modloop/
EOF
chmod +x /usr/sbin/update-modloop
```

## Hardware/peripherals

### Serial console via USB (gadget)

Enable a USB Serial gadget configuration to manage the device via USB:

```bash
# load g_serial module on bootup
echo g_serial > /etc/modules-load.d/g_serial.conf
# start a getty automatically
echo ttyGS0::respawn:/sbin/getty -L 0 ttyGS0 115200 vt100 >> /etc/inittab
# allow root login
echo ttyGS0 >> /etc/securetty
```

### Serial console via USB (host)

Start a getty on hotplugging an USB-UART converter (`ttyUSB0`):

```bash
cat > /etc/udev/rules.d/20-getty-ttyUSB0.rules << EOF
ACTION=="add", SUBSYSTEM=="usb-serial", KERNEL=="ttyUSB0", RUN+="/sbin/getty -L 115200 ttyUSB0 vt100"
EOF
cat > /etc/udev/rules.d/20-getty-ttyACM0.rules << EOF
ACTION=="add", SUBSYSTEM=="usb-serial", KERNEL=="ttyACM0", RUN+="/sbin/getty -L 115200 ttyACM0 vt100"
EOF
udevadm control --reload
```

### Auto-mounting USB drives

```bash
# install udiskie
apk add udisks2 udiskie
# make it mount to /media/ instead of /run/media/<user>/
echo "ENV{ID_FS_USAGE}==\"filesystem|other|crypto\", ENV{UDISKS_FILESYSTEM_SHARED}=\"1\"" > /etc/udev/rules.d/99-udisks2.rules
# create a service unit
cat > /etc/init.d/udiskie << EOF
#!/sbin/openrc-run

supervisor=supervise-daemon
command=/usr/bin/udiskie
command_args="--automount --no-notify --no-tray --no-file-manager --no-terminal"

description="udiskie"

depend() {
   need dbus
}
EOF
# make it executable
chmod 755 /etc/init.d/udiskie
# make it autorun
rc-update add udiskie
service udiskie start
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
