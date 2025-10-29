/*
 * Module: nco
 * Desc: Phase accumulator NCO. MSB is output clock.
 * Author: Grant Chapman, 2025-10-28
 */
module nco #(
  parameter integer FW = 24
)(
  input  wire             clk,
  input  wire             rst_n,
  input  wire [FW-1:0]    freq_word,
  output reg              nco_clk,    // square wave
  output reg [FW-1:0]     phase       // (optional) observable phase
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      phase   <= '0;
      nco_clk <= 1'b0;
    end else begin
      phase   <= phase + freq_word;
      nco_clk <= phase[FW-1];
    end
  end
endmodule
