import math
import os
import pathlib
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
from cocotb_test.simulator import run

# ---------- Pure cocotb test (executed inside the sim) ----------
@cocotb.test()
async def nco_runs_and_has_expected_freq(dut):
    FW = int(os.getenv("PARAM_FW", "24"))
    fclk_hz = 100_000_000     # 100 MHz sim clock
    freq_word = int(os.getenv("FREQ_WORD", "5000000"))

    # Make a 100 MHz clock on dut.clk (10 ns period)
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Reset
    dut.rst_n.value = 0
    for _ in range(5):
        await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    # Count edges over a fixed observation time
    obs_us = 200  # 200 us
    t_end = obs_us * 1_000  # ns
    last = int(dut.nco_clk.value)
    rising = 0
    elapsed = 0
    step_ns = 10
    while elapsed < t_end:
        await RisingEdge(dut.clk)
        cur = int(dut.nco_clk.value)
        if last == 0 and cur == 1:
            rising += 1
        last = cur
        elapsed += step_ns

    # Compute measured frequency (rising edges per second)
    measured_hz = rising / (obs_us * 1e-6)
    expected_hz = (freq_word / (2**FW)) * fclk_hz

    tol = max(1000.0, 0.03 * expected_hz)  # 1 kHz or 3% tolerance
    assert abs(measured_hz - expected_hz) <= tol, \
        f"Measured {measured_hz:.1f} Hz vs expected {expected_hz:.1f} Hz (tol ±{tol:.1f})"

# ---------- Pytest/cocotb-test entry point (runs the compile/sim) ----------
def test_build_and_run():
    here = pathlib.Path(__file__).resolve().parent
    rtl = [str((here.parent / "src" / f).resolve()) for f in [
        "nco.v"
    ]]

    parameters = {"FW": 24}  # Verilog params
    extra_env = {
        "PARAM_FW": str(parameters["FW"]),
        "FREQ_WORD": "5000000",
    }

    run(
        simulator="icarus",
        verilog_sources=rtl,
        toplevel="nco",
        module="test_nco",     # name of this file (without .py)
        parameters=parameters,
        waves=True,            # creates dump.vcd (GTKWave)
        timescale="1ns/1ps",
        extra_env=extra_env
    )
