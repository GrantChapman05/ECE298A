/*
 * Module: divider
 * Desc: Rising-edge tick every N cycles of in_clk; also outputs divided square wave.
 * Author: Grant Chapman, 2025-10-28
 */
module divider #(
  parameter integer N = 4
)(
  input  wire clk,
  input  wire rst_n,
  output reg  clk_div,
  output wire edge_pulse
);
  localparam CW = $clog2(N);
  reg [CW-1:0] cnt;
  reg          pulse;

  assign edge_pulse = pulse;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cnt   <= '0;
      clk_div <= 1'b0;
      pulse <= 1'b0;
    end else begin
      pulse <= 1'b0;
      if (cnt == N-1) begin
        cnt   <= '0;
        clk_div <= ~clk_div;
        pulse <= 1'b1;
      end else begin
        cnt <= cnt + 1'b1;
      end
    end
  end
endmodule
