#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Quan Pham <quanpham071204@gmail.com> October 2026
# Run one ACT ELF on the CVA6 Verilator testharness.
# Usage: run-cva6.sh <elf>   (run_tests.py appends the ELF path)
# Env:   CVA6_REPO_DIR  CVA6 checkout holding work-ver/Variane_testharness
# The testharness writes its trace files to the current directory, so each
# test runs in its own scratch directory to keep parallel runs apart.

set -euo pipefail

ELF="$(realpath "${1:?Usage: run-cva6.sh <elf>}")"
TESTHARNESS="${CVA6_REPO_DIR:?CVA6_REPO_DIR is not set}/work-ver/Variane_testharness"

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT
cd "$WORK_DIR"
"$TESTHARNESS" "$ELF"
