#!/usr/bin/env python3
"""Verify the published restore parts and create a tar; does not flash a device."""
import gzip
import hashlib
import io
import json
import tarfile
from pathlib import Path

root = Path(__file__).resolve().parent
manifest = json.loads((root / 'manifest.json').read_text())
def check(data, expected, label):
    if hashlib.sha256(data).hexdigest() != expected:
        raise SystemExit('Checksum mismatch: ' + label)
compressed = b''.join((root / name).read_bytes() for name in manifest['parts'])
check(compressed, manifest['gzip_sha256'], 'compressed archive')
raw = gzip.decompress(compressed)
check(raw, manifest['tar_sha256'], 'restore tar')
with tarfile.open(fileobj=io.BytesIO(raw), mode='r:') as archive:
    members = archive.getmembers()
    if [m.name for m in members] != [m['name'] for m in manifest['images']]:
        raise SystemExit('Unexpected archive contents')
    for member, expected in zip(members, manifest['images']):
        if not member.isfile() or member.size != expected['bytes']:
            raise SystemExit('Unexpected image type or size')
        check(archive.extractfile(member).read(), expected['sha256'], member.name)
out = root / 'SM-X115-restore-android-boot.tar'
with out.open('xb') as target:
    target.write(raw)
print('Verified restore archive:', out)
print('Contains boot and up_param only. No device has been flashed.')
