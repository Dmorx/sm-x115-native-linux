# Public edition — 2026-11-28

The private Debian backup is excluded in full, rather than exporting a used root filesystem with selected directories deleted. Prepare a fresh Debian 13 ARM64 root filesystem separately and create your own account. No home directory, personal application or modem calibration data is shipped.

The separate public boot image retains the tested kernel payload and matching module bundle. It replaces the gadget device serial with a generic public identifier, removes unauthenticated telnet and USB serial root shells, and removes automatic Wi-Fi, modem, SSH, Avahi and personal swap-file startup from the console script. USB gadget networking still uses the development address 10.66.0.2; it is not an authenticated remote management service.

The boot image does not include Debian itself and will not boot into a useful console without a correctly prepared root filesystem and runtime dependencies. The stock partition assumption `/dev/sdc61` is retained from the tested device; it requires independent verification before use. Do not use this image as a stock-Android installation package.

Verification: boot container regenerated; kernel payload unchanged; ramdisk and nested runtime archive checked; shell/Python syntax checked; release contents scanned for the known device serial, private host paths, keys and account/home data. The cleaned image has not been flashed or boot-tested.

The text-only runtime overlay and console sources are published in this repository. Binary distribution, if available, is listed in `release/`; checksums are included with local deliverables.

The custom module also has debug information stripped and its embedded private source path replaced with a public path. The binary is distributed as gzip parts under `release/`; use `reassemble-boot.py` and verify the checksums.
