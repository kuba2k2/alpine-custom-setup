# alpine-custom-setup

This is a collection of scripts and guides for installing Alpine Linux on some hardware that I own, as well as for getting the most of Alpine by configuring it properly.

The common scripts are a good starting point for building custom kernels & U-Boot for porting to new devices.

This has been tested with the latest (at the time of writing) versions of Linux and U-Boot, 6.3.11 and 2023.04 respectively.

Also see: [alpine-home-assistant](https://github.com/kuba2k2/alpine-home-assistant)

## Preparation

Create a directory for the build (i.e. `/work`). Make sure you have the compiler installed.

```bash
# choose accordingly:
# - fingbox-v1
# - q8-tablet
export TARGET=fingbox-v1
export CROSS_COMPILE=arm-linux-gnueabihf-
export ARCH=arm
export WORK=/work
export INSTALL_MOD_PATH=$WORK/modloop/
cd $WORK
```

## Sources

Checkout Linux kernel v6.3.11 (or any version you choose) to `$WORK/linux/` directory (shallow clone will do).
Checkout U-Boot v2023.04 (or any version you choose) to `$WORK/uboot/` directory (shallow clone will do).

## Environment

Checkout this repository to `$WORK/acs/`.

Activate the environment:

```bash
# note: this WILL overwrite any .config changes!
source $WORK/acs/activate.sh
```

## Alpine release

Download Alpine Linux generic armv7 release .tar.gz. Run:

```bash
$WORK/extract-alpine.sh
```

## Patch the sources

```bash
# apply patches and create tags
$WORK/patch-linux.sh
$WORK/patch-uboot.sh
```

## Configure

If you need to configure U-Boot or Linux, use the following scripts. These will copy your changes into the ACS repo.

```bash
$WORK/config-uboot.sh
$WORK/config-linux.sh
```

## Build

```bash
# build U-Boot
$WORK/build-uboot.sh
# build Linux kernel
$WORK/build-linux.sh
```

## Install - target-specific

- [`fingbox-v1`](fingbox-v1/README.md)
- [`q8-tablet`](q8-tablet/README.md)

## Configure - post-install

See [`alpine.md`](alpine.md) for various tips for best usability.
