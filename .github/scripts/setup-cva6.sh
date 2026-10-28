#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Quan Pham <quanpham071204@gmail.com> October 2026
# Setup environment for CVA6 after installation
# Usage: setup-cva6.sh <install-dir>
# Writes to $GITHUB_PATH and $GITHUB_ENV for GitHub Actions

set -euo pipefail

INSTALL_DIR="${1:?Usage: setup-cva6.sh <install-dir>}"
CVA6_DIR="$INSTALL_DIR/cva6"

if [[ ! -x "$CVA6_DIR/work-ver/Variane_testharness" ]]; then
  echo "ERROR: Variane_testharness not found in $CVA6_DIR/work-ver" >&2
  exit 1
fi

# Installed here rather than by install-cva6.sh so that editing it does not invalidate the simulator cache
mkdir -p "$INSTALL_DIR/bin"
install -m 0755 "$(dirname "$0")/run-cva6.sh" "$INSTALL_DIR/bin/run-cva6.sh"

echo "$INSTALL_DIR/bin" >>"$GITHUB_PATH"
echo "CVA6_REPO_DIR=$CVA6_DIR" >>"$GITHUB_ENV"
