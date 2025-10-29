`timescale 1ns/1ps
module tb_nco;
  localparam FW = 24;
  reg clk = 0, rst_n = 0;
  wire nco_clk;
  wire [FW-1:0] phase;

  nco #(.FW(FW)) dut (
    .clk(clk), .rst_n(rst_n),
    .freq_word(24'd5000000),
    .nco_clk(nco_clk),
    .phase(phase)
  );

  initial begin
    $dumpfile("sim/tb_nco.vcd");
    $dumpvars(0, tb_nco);
    #50  rst_n = 1;
    #5000 $finish;
  end
  always #5 clk = ~clk; // 100 MHz
endmodule
