#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Quan Pham <quanpham071204@gmail.com> October 2026
# Install Verilator, Spike (fesvr) and the CVA6 Verilator testharness for CI
# Usage: install-cva6.sh <install-dir>
# Update commits/versions to rebuild (cache key is derived from this script's hash).

set -euo pipefail

INSTALL_DIR="${1:?Usage: install-cva6.sh <install-dir>}"
mkdir -p "$INSTALL_DIR"
INSTALL_DIR="$(cd "$INSTALL_DIR" && pwd)"
NUM_JOBS="${NUM_JOBS:-$(nproc)}"

CVA6_COMMIT="ddb26b316ab77985ef9d49f3c314f1d1d12866e8"
VERILATOR_VERSION="v5.008" # pinned by CVA6 in verif/regress/install-verilator.sh
TARGET="cv64a6_imafdc_sv39_hpdcache_pmp_mmu_axi"

VERILATOR_DIR="$INSTALL_DIR/verilator"
CVA6_DIR="$INSTALL_DIR/cva6"
SPIKE_DIR="$INSTALL_DIR/spike"

export PATH="$VERILATOR_DIR/bin:$PATH"
export VERILATOR_INSTALL_DIR="$VERILATOR_DIR"

# Install Verilator from source
if [[ ! -x "$VERILATOR_DIR/bin/verilator" ]]; then
  rm -rf "$INSTALL_DIR/verilator-src"
  git clone --depth 1 --branch "$VERILATOR_VERSION" https://github.com/verilator/verilator.git "$INSTALL_DIR/verilator-src"
  (
    cd "$INSTALL_DIR/verilator-src"
    autoconf
    ./configure --prefix="$VERILATOR_DIR"
    make -j"$NUM_JOBS"
    make install
  )
  rm -rf "$INSTALL_DIR/verilator-src"
fi
verilator --version

# Fetch only the pinned CVA6 commit and its submodules (shallow, to keep the download and cache small)
if [[ ! -d "$CVA6_DIR/.git" ]]; then
  git init -q "$CVA6_DIR"
  git -C "$CVA6_DIR" remote add origin https://github.com/openhwfoundation/cva6.git
fi
git -C "$CVA6_DIR" fetch --depth 1 origin "$CVA6_COMMIT"
git -C "$CVA6_DIR" checkout -q --detach FETCH_HEAD
git -C "$CVA6_DIR" submodule update --init --recursive --depth 1 --jobs 4

# Apply the submodule patches listed under submodule_patches in
# flows/config/dependencies.yml (CVA6 applies them with git apply, see
# flows/recipes/git_dependencies.py). Without the hpdcache ones the build fails.
# Skip a patch that is already applied so the script can be re-run.
apply_patch() {
  local dir="$1" patch="$CVA6_DIR/verif/patches/$2"
  if git -C "$dir" apply --reverse --check "$patch" 2>/dev/null; then
    echo "Already applied: $2"
  else
    git -C "$dir" apply "$patch"
  fi
}
apply_patch "$CVA6_DIR/core/cache_subsystem/hpdcache" hpdcache-blackbox-ecc-sram-port-list.patch
apply_patch "$CVA6_DIR/core/cache_subsystem/hpdcache" hpdcache-bufferable-attribute.patch
apply_patch "$CVA6_DIR/verif/core-v-verif" core-v-verif-axi-amo-synchronizer.patch
apply_patch "$CVA6_DIR/verif/core-v-verif" core-v-verif-obi-assert-aid-queue-depth.patch
apply_patch "$CVA6_DIR/verif/core-v-verif" core-v-verif-obi-assert-outstanding-counter.patch

# Build Spike/fesvr from the sources vendored in core-v-verif; the testharness links against them
NUM_JOBS="$NUM_JOBS" SPIKE_INSTALL_DIR="$SPIKE_DIR" bash "$CVA6_DIR/verif/regress/install-spike.sh"

# Build the testharness. The Makefile requires RISCV but only uses it for
# include/library paths, which the Spike install provides.
export RISCV="${RISCV:-$SPIKE_DIR}"
make -C "$CVA6_DIR" verilate target="$TARGET" SPIKE_INSTALL_DIR="$SPIKE_DIR" NUM_JOBS="$NUM_JOBS"

test -x "$CVA6_DIR/work-ver/Variane_testharness" ||
  {
    echo "ERROR: Variane_testharness not produced for $TARGET"
    exit 1
  }

# Keep only what run_cmd.txt needs (the testharness and libfesvr it links to), so the CI cache stays small
find "$CVA6_DIR" -mindepth 1 -maxdepth 1 ! -name work-ver -exec rm -rf {} +
find "$CVA6_DIR/work-ver" -mindepth 1 -maxdepth 1 ! -name Variane_testharness -exec rm -rf {} +
find "$SPIKE_DIR" -mindepth 1 -maxdepth 1 ! -name lib -exec rm -rf {} +
find "$SPIKE_DIR/lib" -mindepth 1 -maxdepth 1 ! -name 'libfesvr.so*' -exec rm -rf {} +
