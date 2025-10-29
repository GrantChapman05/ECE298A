#!/bin/bash
# lint.sh — run Verilator lint on all src/*.v
set -euo pipefail
if ! command -v verilator >/dev/null 2>&1; then
  echo "[ERROR] verilator not found. Install with: sudo apt install verilator"
  exit 2
fi
verilator --lint-only -Wall -Wno-fatal src/*.v
echo "[INFO] Verilator lint completed."
