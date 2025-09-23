`timescale 1ns/1ps
`default_nettype none

module id_counter_tb;

    //Testbench signals
    reg clk;
    reg rst;
    reg enable;
    reg load;
    reg [7:0] load_data;
    reg oe;
    wire [7:0] q;

    //Instantiate DUT (Device Under Test)
    id_counter uut (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .load(load),
        .load_data(load_data),
        .oe(oe),
        .q(q)
    );

    //Clock generation: 10ns period
    always #5 clk = ~clk;

    initial begin
        //Initialize signals
        clk = 0;
        rst = 0;
        enable = 0;
        load = 0;
        load_data = 8'h00;
        oe = 0;

        $display("Starting simulation...");

        //Apply synchronous reset
        @(posedge clk);
        rst = 1;
        @(posedge clk);
        rst = 0;

        //Load a known value
        @(posedge clk);
        load_data = 8'hA5;
        load = 1;
        @(posedge clk);
        load = 0;

        //Observe the loaded value
        oe = 1;
        $display("After load: q = %h (expected A5)", q);

        //Enable counting for a few cycles
        enable = 1;
        repeat(5) @(posedge clk);
        enable = 0;
        $display("After counting 5 cycles: q = %h (expected AA)", q);

        //Tri-state test
        oe = 0;
        @(posedge clk);
        $display("With oe=0, q should be Z. q = %h", q);

        //Finish simulation
        #20;
        $display("Simulation complete.");
        $finish;
    end

endmodule

`default_nettype wire