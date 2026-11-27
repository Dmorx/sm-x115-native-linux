#!/usr/bin/python3
"""Select USB data role and its matching 5 V supply from native Type-C state."""
import fcntl,pathlib,subprocess,time
lock=open('/run/tablet-usb-otg.lock','w')
try:fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
except BlockingIOError:raise SystemExit(0)
attach_path=pathlib.Path('/sys/kernel/tablet_usb/attach')
mode_path=pathlib.Path('/sys/class/udc/musb-hdrc/device/cmode')
vbus_path=pathlib.Path('/sys/module/musb_hdrc/parameters/vbus_on')
option_path=pathlib.Path('/sys/module/musb_hdrc/parameters/option')
last=None;started=time.monotonic()
print('USB_OTG_ROLE_AND_POWER_POLICY_STARTED',flush=True)
while True:
 try:
  if not attach_path.exists():
   subprocess.run(['modprobe','tablet_usb_state'],check=False);time.sleep(1);continue
  attach=attach_path.read_text().strip();current=mode_path.read_text().strip()
  host=attach=='2';powered=vbus_path.read_text().strip() in ('Y','1')
  # Always turn the local supply off before accepting an upstream PC/charger.
  if not host and powered:option_path.write_text('10\n')
  target='2' if host else ('3' if attach=='1' else ('3' if time.monotonic()-started<10 and current=='3' else '0'))
  if current!=target:mode_path.write_text(target+'\n')
  if host and not powered:option_path.write_text('9\n')
  state=(attach,target,vbus_path.read_text().strip())
  if state!=last:print('USB_OTG_STATE attach=%s cmode=%s vbus=%s'%state,flush=True);last=state
 except OSError as e:print('USB_OTG_POLICY_ERROR',str(e),flush=True)
 time.sleep(.25)
