/*
 * Module: lock_detector
 * Desc: Counts "quiet" cycles with no UP/DN; asserts locked after threshold.
 * Author: Grant Chapman, 2025-10-28
 */
module lock_detector #(
  parameter integer THRESH = 1024
)(
  input  wire clk,
  input  wire rst_n,
  input  wire up,
  input  wire dn,
  output reg  locked
);
  localparam CW = $clog2(THRESH+1);
  reg [CW-1:0] qcnt;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      qcnt   <= '0;
      locked <= 1'b0;
    end else begin
      if (up || dn) qcnt <= '0;
      else if (qcnt != THRESH[CW-1:0]) qcnt <= qcnt + 1'b1;
      locked <= (qcnt == THRESH[CW-1:0]);
    end
  end
endmodule
