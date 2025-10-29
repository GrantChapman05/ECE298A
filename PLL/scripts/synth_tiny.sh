#!/bin/bash
# synth_tiny.sh — run Yosys synthesis targeting Sky130 (TinyTapeout flow prep)
# Usage: ./scripts/synth_tiny.sh [top_module]    default: pll_top
set -euo pipefail
TOP="${1:-pll_top}"
mkdir -p synth
LOG="synth/yosys.log"

if ! command -v yosys >/dev/null 2>&1; then
  echo "[ERROR] yosys not found. Install with: sudo apt install yosys"
  exit 2
fi

YO_SCRIPT="read_verilog -sv src/*.v
hierarchy -top ${TOP}
proc; opt; fsm; opt; memory; opt
techmap; opt
abc -fast
clean
write_json synth/${TOP}.json
write_verilog -noattr synth/${TOP}_syn.v
"

echo "[INFO] Running Yosys for top=${TOP} ..."
echo "${YO_SCRIPT}" | yosys -q -l "${LOG}"
echo "[INFO] Netlists written to synth/${TOP}.json and synth/${TOP}_syn.v"
echo "[INFO] Full log at ${LOG}"
