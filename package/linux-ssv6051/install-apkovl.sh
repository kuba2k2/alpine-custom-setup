#!/bin/bash
set -e

APKOVL_DIR="${BINARIES_DIR}/apkovl"
mkdir -p "${APKOVL_DIR}/lib/firmware/"

# Install /lib/firmware/ssv6051-wifi.cfg
wget -O "${APKOVL_DIR}/lib/firmware/ssv6051-wifi.cfg" \
	https://github.com/armbian/firmware/raw/refs/heads/master/ssv6051-wifi.cfg

# Install /lib/firmware/ssv6051-wifi.cfg
wget -O "${APKOVL_DIR}/lib/firmware/ssv6051-sw.bin" \
	https://github.com/armbian/firmware/raw/refs/heads/master/ssv6051-sw.bin
