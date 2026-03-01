#!/bin/bash
set -e

APKOVL_DIR="${BINARIES_DIR}/apkovl"

# Install /etc/init.d/display
DIR="${APKOVL_DIR}/etc/init.d/"
FILE="${APKOVL_DIR}/etc/init.d/display"
if [ ! -f "${APKOVL_DIR}/etc/init.d/display" ]; then
	mkdir -p "${DIR}"
	tee "${FILE}" <<EOF
#!/sbin/openrc-run

name="TM16xx Display Service"
command="/usr/sbin/display-service"
supervisor="supervise-daemon"

start_pre() {
	modprobe -a tm16xx_i2c tm16xx_spi
}
EOF
	chmod +x "${FILE}"
fi

# Install /usr/sbin/display-service
DIR="${APKOVL_DIR}/usr/sbin/"
FILE="${APKOVL_DIR}/usr/sbin/display-service"
if [ ! -f "${FILE}" ]; then
	mkdir -p "${DIR}"
	wget -O "${FILE}" \
		"https://github.com/jefflessard/tm16xx-display/raw/refs/heads/main/display-service"
	chmod +x "${FILE}"
	sed -i 's/systemctl is-active --quiet "$SERVICE_NAME"/service "$SERVICE_NAME" status/g' "${FILE}"
	sed -i 's/systemctl stop "$SERVICE_NAME"/service "$SERVICE_NAME" stop/g' "${FILE}"
	sed -i 's/systemctl start "$SERVICE_NAME"/service "$SERVICE_NAME" start/g' "${FILE}"
fi
