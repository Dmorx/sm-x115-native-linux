#!/usr/bin/python3
import pathlib,os,stat,time,grp
root=pathlib.Path('/sys/class/input');dev=pathlib.Path('/dev/input');dev.mkdir(parents=True,exist_ok=True)
for attempt in range(50):
 power=False
 for entry in root.glob('event*'):
  major,minor=map(int,(entry/'dev').read_text().strip().split(':'));p=dev/entry.name;number=os.makedev(major,minor)
  if not p.exists():os.mknod(p,stat.S_IFCHR|0o660,number)
  st=p.stat();assert stat.S_ISCHR(st.st_mode) and st.st_rdev==number,str(p)
  os.chmod(p,0o660);os.chown(p,0,grp.getgrnam('input').gr_gid)
  if (entry/'device/name').read_text().strip()=='mtk-pmic-keys':power=True
 if power:
  print('TABLET_POWER_INPUT_READY',flush=True);break
 time.sleep(.1)
else:raise RuntimeError('PMIC power input did not register within five seconds')
