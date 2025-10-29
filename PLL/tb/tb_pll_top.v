`timescale 1ns/1ps
module tb_pll_top;
  reg clk = 0, rst_n = 0;
  reg ref_in = 0;

  // Sample clock 100 MHz
  always #5 clk = ~clk;

  // Reference "async" ~ 2 MHz (250 ns half-period)
  always #250 ref_in = ~ref_in;

  wire pll_out, locked;
  pll_top #(.FW(24), .KP_SH(6), .KI_SH(11), .DIV_N(4)) dut (
    .clk(clk), .rst_n(rst_n), .ref_in(ref_in),
    .pll_out(pll_out), .locked(locked)
  );

  initial begin
    $dumpfile("sim/tb_pll_top.vcd");
    $dumpvars(0, tb_pll_top);
    #50  rst_n = 1;
    #200000 $finish; // 200 us
  end
endmodule
