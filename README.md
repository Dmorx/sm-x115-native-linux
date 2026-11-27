# Native Linux on Samsung Galaxy Tab A9 LTE (SM-X115)

Experimental ARM64 Linux 5.10.205 and Debian 13 integration for SM-X115 / MT6789.

This public edition contains kernel configuration and patches, the Type-C state module, boot scripts, and modified kmscon sources for the power button, brightness fading and USB keyboard/mouse support. It does **not** contain a Debian filesystem, installed personal applications, home/root directories, account databases, SSH keys, Wi-Fi credentials, modem NVRAM, personal files, or device diagnostic reports.

## Build

The existing `build.sh` and manually triggered GitHub Actions workflow build the kernel and matching modules from the pinned upstream commit. They do not create a Debian disk image.

`module/` contains the GPL Type-C attachment helper. Build it against the matching configured kernel tree:

```sh
make -C /path/to/kernel-build ARCH=arm64 M="$PWD/module" modules
```

`runtime/` contains a reviewed filesystem overlay of text scripts and settings. Install the matching module and extract `kmscon-10.0.4-public-source.tar.gz` and build `kmscon-10.0.4` using its Meson instructions. Runtime requires Python 3, kmod, udev, dbus, login and suitable console/font dependencies. Debian users and passwords must be created locally. Network and modem setup is deliberately left to the owner.

## Hardware status

The original private installation was tested with the local display, power-button display toggle, brightness fading and USB OTG keyboard/mouse. Display blanking is not system suspend. LTE data connectivity is not claimed here. The sanitized public image has structural validation only and has not been boot-tested on hardware.

This is device-specific experimental development material, not a general Debian installer. The boot script expects a separately prepared ext4 Debian root at `/dev/sdc61`; do not flash it on a stock device or another model. Preserve your own recovery image and partition layout. There are no partition-writing or flashing scripts in this public edition.

## Licenses and provenance

Kernel sources: https://github.com/prabhatkrmishra/kernel_samsung_gta9 at commit `9555e884592fb2262db8ebdedb40ef9b811d7709`; kernel files retain their upstream GPL/SPDX terms. The Type-C helper declares GPL. The console sources retain their original COPYING and per-file notices. No blanket relicensing of third-party code is intended. The boot image is a repack of the locally tested image; this repository's existing build workflow is not a claim of byte-for-byte reproduction of that binary.

## Download the clean boot image

Download or clone this repository, then run `python3 reassemble-boot.py`. The script joins the binary parts under `release/`, verifies SHA-256, decompresses the image and checks its 64 MiB size. These parts are a transport format; never flash a part file. The image is not a complete Debian distribution.

## Public image preparation

The public image retains the tested kernel payload and matching modules. Its device serial is generic. Unauthenticated telnet and USB serial root shells are disabled; automatic Wi-Fi, modem, SSH, Avahi and personal swap startup are removed. USB gadget networking uses development address `10.66.0.2`. The custom module has debug information stripped and its embedded private source path replaced with a public path.

Prepare a fresh Debian 13 ARM64 filesystem and create your own account. No used Debian filesystem, personal applications, home directories or modem calibration data is included.

The image was structurally checked, including the ramdisk and nested archives; known personal markers were absent. The published image was downloaded, reassembled and checksum-verified. It has not been boot-tested after sanitization. Validation details and checksums are in `release/manifest.json`.

`runtime/etc/mdev.conf` is the single configuration source for both the initramfs `/etc/mdev.conf` and Debian `/etc/mdev.conf`. Copy it into both locations when preparing a new image. The unused storage-module load list has been removed; the boot script uses `initramfs/usb-modules.load` and explicit storage module loading.
