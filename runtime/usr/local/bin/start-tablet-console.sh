#!/bin/bash
set -eu
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export LANG=C.UTF-8 LC_ALL=C.UTF-8
mkdir -p /run /dev/shm /run/sshd /run/dbus
chmod 1777 /tmp /dev/shm
python3 /usr/local/libexec/tablet-mdev-permissions.py || echo TABLET_MDEV_PERMISSION_SETUP_FAILED >&2
modprobe mtk-pmic-keys 2>/dev/null || true
modprobe xhci-mtk-hcd 2>/dev/null || true
/usr/local/libexec/tablet-input-ready.py || true
if ! pgrep -x systemd-udevd >/dev/null; then
  SYSTEMD_IGNORE_CHROOT=1 /usr/lib/systemd/systemd-udevd --daemon || true
fi
SYSTEMD_IGNORE_CHROOT=1 udevadm trigger --subsystem-match=input --subsystem-match=drm --action=add 2>/dev/null || true
SYSTEMD_IGNORE_CHROOT=1 udevadm settle --timeout=5 2>/dev/null || true
chmod 666 /dev/null /dev/zero /dev/urandom /dev/random /dev/tty /dev/ptmx 2>/dev/null || true
pgrep -x dbus-daemon >/dev/null || { rm -f /run/dbus/pid; dbus-daemon --system --fork || true; }
modprobe tablet_usb_state 2>/dev/null || true
nohup /usr/local/libexec/tablet-usb-otg.py >>/var/log/tablet-usb-otg.log 2>&1 </dev/null &
while :; do
  /usr/local/bin/kmscon --no-libseat --no-switchvt --no-hwaccel --rotate left --font-size 20 --font-name 'DejaVu Sans Mono' --dpms-timeout 60 --mouse --soft-cursor --term xterm-256color --no-issue --login -- /bin/login -p || true
  sleep 2
done
