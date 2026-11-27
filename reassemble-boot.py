#!/usr/bin/env python3
"""Reassemble the published gzip parts and verify both compressed and raw images."""
import gzip, hashlib, json
from pathlib import Path
root = Path(__file__).resolve().parent
manifest = json.loads((root / 'release/manifest.json').read_text())
parts = [root / 'release' / n for n in manifest['parts']]
compressed = b''.join(p.read_bytes() for p in parts)
assert hashlib.sha256(compressed).hexdigest() == manifest['gzip_sha256'], 'Compressed checksum mismatch'
raw = gzip.decompress(compressed)
assert len(raw) == 67108864
assert hashlib.sha256(raw).hexdigest() == manifest['boot_sha256'], 'Boot checksum mismatch'
out = root / 'SM-X115-public-boot-2026-11-28.img'
if out.exists():
    raise SystemExit('Output already exists; move it before running again.')
out.write_bytes(raw)
print(out)
