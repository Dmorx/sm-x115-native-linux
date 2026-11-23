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
git -C kernel apply --check ../msync-integer.patch
git -C kernel apply ../msync-integer.patch
git -C kernel apply --check ../prototype-fixes.patch
git -C kernel apply ../prototype-fixes.patch
git -C kernel apply --check ../usb-charger-vcodec.patch
git -C kernel apply ../usb-charger-vcodec.patch
git -C kernel apply --check ../encoder-typec.patch
git -C kernel apply ../encoder-typec.patch
git -C kernel apply --check ../typec-debug.patch
git -C kernel apply ../typec-debug.patch
git -C kernel apply --check ../typec-fod.patch
git -C kernel apply ../typec-fod.patch
git -C kernel apply --check ../thermal-camera-iommu.patch
git -C kernel apply ../thermal-camera-iommu.patch
mkdir -p out dist
cp native.config out/.config
# The MT6983 audio driver uses APIs absent from this source snapshot.
# SM-X115 uses the MT6789 audio path.
kernel/scripts/config --file out/.config -d SND_SOC_MT6983_MT6338 -d SND_SOC_MT6983
export PATH="/usr/lib/llvm-19/bin:$PATH"
export CCACHE_DIR="$PWD/.ccache"
export CCACHE_BASEDIR="$PWD"
ccache --max-size=2G
trap 'ccache --show-stats' EXIT
make -C kernel O="$PWD/out" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1 olddefconfig
# Compile all enabled Type-C drivers before the full build.
make -C kernel O="$PWD/out" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1 CC="ccache clang" KCFLAGS="-Wno-error" -j"$(nproc)" drivers/misc/mediatek/typec/tcpc/
make -C kernel O="$PWD/out" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1 CC="ccache clang" KCFLAGS="-Wno-error" -j"$(nproc)" \
  drivers/media/platform/mtk-vcodec/mtk_vcodec_enc.o \
  drivers/media/platform/mtk-vcodec/mtk_vcodec_util.o \
  drivers/power/supply/mtk_charger.o
make -C kernel O="$PWD/out" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1 CC="ccache clang" KCFLAGS="-Wno-error" -j"$(nproc)" Image modules
make -C kernel O="$PWD/out" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1 INSTALL_MOD_PATH="$PWD/dist/modules" modules_install
cp out/arch/arm64/boot/Image out/.config out/Module.symvers dist/
tar -C dist -czf dist/modules.tar.gz modules
rm -r dist/modules
(cd dist && sha256sum Image modules.tar.gz > SHA256SUMS)
