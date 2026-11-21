#!/usr/bin/env bash
set -euo pipefail
git clone --depth 1 --branch 14.0 https://github.com/prabhatkrmishra/kernel_samsung_gta9.git kernel
test "$(git -C kernel rev-parse HEAD)" = 9555e884592fb2262db8ebdedb40ef9b811d7709
python3 - <<'PY'
from pathlib import Path
p = Path("kernel/drivers/Kconfig")
p.write_text(p.read_text().replace('source "drivers/kernelsu/Kconfig"', ''))
PY
git -C kernel apply --check ../gamma-stack.patch
git -C kernel apply ../gamma-stack.patch
mkdir -p out dist
cp native.config out/.config
# The MT6983 audio driver uses APIs absent from this source snapshot.
# SM-X115 uses the MT6789 audio path.
kernel/scripts/config --file out/.config -d SND_SOC_MT6983_MT6338 -d SND_SOC_MT6983
export PATH="/usr/lib/llvm-19/bin:$PATH"
make -C kernel O="$PWD/out" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1 olddefconfig
make -C kernel O="$PWD/out" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1 KCFLAGS="-Wno-error" -j4 Image modules
make -C kernel O="$PWD/out" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1 INSTALL_MOD_PATH="$PWD/dist/modules" modules_install
cp out/arch/arm64/boot/Image out/.config out/Module.symvers dist/
tar -C dist -czf dist/modules.tar.gz modules
rm -r dist/modules
(cd dist && sha256sum Image modules.tar.gz > SHA256SUMS)
