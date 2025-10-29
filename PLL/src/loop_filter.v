/*
 * Module: loop_filter
 * Desc: Discrete-time PI: freq_word += Kp*e + Ki*int(e), where e = (+1 for up, -1 for dn, 0 else)
 * Gains are right-shift powers to keep it synthesis-friendly.
 * Author: Grant Chapman, 2025-10-28
 */
module loop_filter #(
  parameter integer FW     = 24,    // width of frequency control word
  parameter integer KP_SH  = 6,     // Kp = 1/2^KP_SH
  parameter integer KI_SH  = 10     // Ki = 1/2^KI_SH
)(
  input  wire                 clk,
  input  wire                 rst_n,
  input  wire                 up,
  input  wire                 dn,
  output reg  [FW-1:0]        freq_word   // unsigned phase increment for NCO
);
  // signed error: +1, 0, -1
  wire signed [2:0] e = up ? 3'sd1 : (dn ? -3'sd1 : 3'sd0);

  // integral term (signed)
  reg signed [FW:0] iacc; // one extra bit

  wire signed [FW:0] p_term = $signed(e) >>> KP_SH;
  wire signed [FW:0] i_next = iacc + ($signed(e) >>> KI_SH);
  wire signed [FW:0] sum    = p_term + i_next;

  // saturate to [0 .. 2^FW-1]
  function [FW-1:0] sat_u;
    input signed [FW:0] x;
    begin
      if (x < 0) sat_u = {FW{1'b0}};
      else if (x > $signed({1'b0,{FW{1'b1}}})) sat_u = {FW{1'b1}};
      else sat_u = x[FW-1:0];
    end
  endfunction

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      iacc      <= '0;
      freq_word <= {FW{1'b0}};
    end else begin
      iacc      <= i_next;
      freq_word <= sat_u(sum);
    end
  end
endmodule
