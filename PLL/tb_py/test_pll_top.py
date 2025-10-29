import os
import pathlib
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
from cocotb_test.simulator import run

@cocotb.test()
async def pll_locks_eventually(dut):
    # 100 MHz sample clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Generate ~2 MHz reference on ref_in
    async def ref_gen():
        half = 250  # ns (2 MHz)
        while True:
            dut.ref_in.value = 0
            await Timer(half, units="ns")
            dut.ref_in.value = 1
            await Timer(half, units="ns")
    cocotb.start_soon(ref_gen())

    # Reset
    dut.rst_n.value = 0
    for _ in range(5):
        await RisingEdge(dut.clk)
    dut.rst_n.value = 1

    # Wait up to 2 ms for lock
    locked = False
    for _ in range(int(2_000_000 / 10)):  # 2 ms / 10 ns per cycle
        await RisingEdge(dut.clk)
        if int(dut.locked.value) == 1:
            locked = True
            break

    assert locked, "PLL did not assert 'locked' within 2 ms sim time"

def test_build_and_run():
    here = pathlib.Path(__file__).resolve().parent
    rtl = [str((here.parent / "src" / f).resolve()) for f in [
        "sync_edge.v",
        "phase_detector.v",
        "loop_filter.v",
        "nco.v",
        "divider.v",
        "lock_detector.v",
        "pll_top.v",
    ]]

    parameters = {
        "FW": 24,
        "KP_SH": 6,
        "KI_SH": 11,
        "DIV_N": 4,
    }

    run(
        simulator="icarus",
        verilog_sources=rtl,
        toplevel="pll_top",
        module="test_pll_top",
        parameters=parameters,
        waves=True,
        timescale="1ns/1ps",
        extra_env={k: str(v) for k, v in parameters.items()},
    )
