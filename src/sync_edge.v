/*
 * Module: sync_edge
 * Desc: 2FF synchronizer + rising-edge pulse
 * Author: Grant Chapman, 2025-10-28
 */
module sync_edge (
  input  wire clk,
  input  wire rst_n,
  input  wire async_in,
  output wire sync_level,
  output wire sync_rise
);
  reg q1, q2;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin q1<=1'b0; q2<=1'b0; end
    else begin q1<=async_in; q2<=q1; end
  end
  assign sync_level = q2;
  assign sync_rise  = q1 & ~q2;
endmodule
