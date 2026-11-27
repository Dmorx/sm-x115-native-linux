#!/usr/bin/python3
import pathlib,grp,os
video=grp.getgrnam('video').gr_gid;inputs=grp.getgrnam('input').gr_gid;audio=grp.getgrnam('audio').gr_gid
s=f'''null 0:0 0666
zero 0:0 0666
full 0:0 0666
random 0:0 0666
urandom 0:0 0666
tty 0:0 0666
ptmx 0:0 0666
input/event[0-9]* 0:{inputs} 0660
dri/.* 0:{video} 0660
snd/.* 0:{audio} 0660
'''
for p in [pathlib.Path('/etc/mdev.conf'),pathlib.Path('/proc/1/root/etc/mdev.conf')]:p.parent.mkdir(exist_ok=True);p.write_text(s)
for n in ['null','zero','full','random','urandom','tty','ptmx']:
 try:os.chmod('/dev/'+n,0o666)
 except OSError:pass
print('MDEV_DEVICE_PERMISSIONS_FIXED')
