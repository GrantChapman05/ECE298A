#!/bin/bash
# run_sim.sh — compile & run a testbench with Icarus Verilog and open VCD in GTKWave
# Usage: ./scripts/run_sim.sh tb_nco   (omit .v extension)
set -euo pipefail
TB_NAME="${1:-}"
if [[ -z "$TB_NAME" ]]; then
  echo "Usage: $0 <tb_name_without_.v>   e.g. $0 tb_nco"
  exit 1
fi
mkdir -p sim
OUT_EXE="sim/${TB_NAME}.out"
VCD="sim/${TB_NAME}.vcd"

if ! command -v iverilog >/dev/null 2>&1; then
  echo "[ERROR] iverilog not found. Install with: sudo apt install iverilog"
  exit 2
fi

echo "[INFO] Compiling ${TB_NAME}.v with sources in src/ ..."
iverilog -g2012 -o "${OUT_EXE}" -I src tb/${TB_NAME}.v src/*.v

echo "[INFO] Running simulation -> ${VCD}"
vvp "${OUT_EXE}"

if command -v gtkwave >/dev/null 2>&1; then
  echo "[INFO] Opening ${VCD} in GTKWave..."
  gtkwave "${VCD}" >/dev/null 2>&1 &
else
  echo "[WARN] GTKWave not found. Install with: sudo apt install gtkwave"
fi
