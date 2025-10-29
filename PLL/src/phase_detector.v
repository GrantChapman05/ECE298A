/*
 * Module: phase_detector
 * Desc: Phase-Frequency Detector (PFD): asserts up when ref leads, dn when fb leads.
 * Author: Grant Chapman, 2025-10-28
 */
module phase_detector (
  input  wire clk,       // sampling clock
  input  wire rst_n,
  input  wire ref_edge,  // 1-cycle pulse on ref rising edge (synchronized)
  input  wire fb_edge,   // 1-cycle pulse on fb rising edge (synchronized)
  output reg  up,
  output reg  dn
);
  // Simple pulse PFD: set with own edge, clear with the other.
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin up<=1'b0; dn<=1'b0; end
    else begin
      // set
      if (ref_edge) up <= 1'b1;
      if (fb_edge)  dn <= 1'b1;
      // async-style reset using mutual arrival
      if (ref_edge && dn) dn <= 1'b0;
      if (fb_edge  && up) up <= 1'b0;
      // If both asserted (rare), clear both next cycle
      if (up && dn) begin up<=1'b0; dn<=1'b0; end
    end
  end
endmodule
