# Kernel configuration

## Required options

- `CONFIG_SQUASHFS`
- `CONFIG_BLK_DEV_LOOP`

## OpenRC init errors

- `net.ipv4.tcp_syncookies` -> `CONFIG_SYN_COOKIES`
- `kernel.unprivileged_bpf_disabled` -> `CONFIG_BPF_SYSCALL`
- `/proc/sys/kernel/hotplug` -> `CONFIG_CPU_HOTPLUG_STATE_CONTROL`
