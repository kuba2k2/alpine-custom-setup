# Network connectivity

## Firmware installation

If the device requires special Wi-Fi firmware, it should be available in the `bootfs` volume:

```bash
apk add --force-non-repository /media/*/apks/*.apk
```

After this, you will probably need to reload the driver modules (`rmmod` and `modprobe`). Use `lsmod` to figure out which module needs to be reloaded.

## Using setup-alpine

If the Wi-Fi interface is detected after installing firmware, use `setup-interfaces -r` to scan for networks and connect. The `-r` parameter will restart `networking`, which enables DHCP too.

## Using wpa_supplicant

If `setup-interfaces` fails for some reason, try using `wpa_supplicant` directly.

First, kill all `wpa_supplicant` processes:

```bash
service wpa_supplicant stop
pkill -9 wpa_supplicant
```

Then, follow [wpa_supplicant - ArchWiki](https://wiki.archlinux.org/title/wpa_supplicant) guide to connect to Wi-Fi. Use the `wlan0` interface.

After connecting, run `udhcpc` to get an IP address.

## Using an Ethernet cable

If your device has an Ethernet interface and it's visible in the system.

```bash
# enable the interface
ip link set eth0 up
# run a DHCP client
apk add dhcpcd
dhcpcd
```

## Using `g_ether` USB gadget

If everything else fails, this should provide at least a temporary way of getting Internet access.

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

## Hard mode - console via USB only

If the only way to access Linux is over USB and you need to use it for `g_ether`, you need a few extra steps.

First, add this to `/etc/network/interfaces`:

```
auto usb0
iface usb0 inet dhcp
```

Then run `modprobe g_ether`. Connect the device to your PC and enable ICS as instructed above.

Disconnect the device, open the console again. Now, run something like `sleep 60; service networking restart`. After this, you have 60 seconds to reconnect the device to the PC.
