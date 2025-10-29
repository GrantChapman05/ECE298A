/*
 * Module: pll_top
 * Desc: ADPLL top: ref_in -> sync -> PFD -> PI loop -> NCO -> divider (feedback)
 * Author: Grant Chapman, 2025-10-28
 */
module pll_top #(
  parameter integer FW     = 24,
  parameter integer KP_SH  = 6,
  parameter integer KI_SH  = 10,
  parameter integer DIV_N  = 4
)(
  input  wire             clk,       // system sample clock
  input  wire             rst_n,
  input  wire             ref_in,    // async reference clock (external)
  output wire             pll_out,   // synthesized clock from NCO
  output wire             locked
);
  // Sync/edge detect for reference and feedback
  wire ref_sync, ref_edge;
  sync_edge u_sync_ref(.clk(clk), .rst_n(rst_n), .async_in(ref_in), .sync_level(ref_sync), .sync_rise(ref_edge));

  wire fb_clk, fb_edge;
  divider #(.N(DIV_N)) u_div(.clk(pll_out), .rst_n(rst_n), .clk_div(fb_clk), .edge_pulse(fb_edge));

  // Phase detector
  wire up, dn;
  phase_detector u_pfd(.clk(clk), .rst_n(rst_n), .ref_edge(ref_edge), .fb_edge(fb_edge), .up(up), .dn(dn));

  // Loop filter -> freq control word
  wire [FW-1:0] freq_word;
  loop_filter #(.FW(FW), .KP_SH(KP_SH), .KI_SH(KI_SH))
    u_lf(.clk(clk), .rst_n(rst_n), .up(up), .dn(dn), .freq_word(freq_word));

  // NCO
  wire [FW-1:0] phase;
  nco #(.FW(FW)) u_nco(.clk(clk), .rst_n(rst_n), .freq_word(freq_word), .nco_clk(pll_out), .phase(phase));

  // Lock detector
  lock_detector u_lock(.clk(clk), .rst_n(rst_n), .up(up), .dn(dn), .locked(locked));
endmodule
