`timescale 1ns/1ps
`default_nettype none

//8-bit programmable counter with synchronous load and tri-state outputs
module id_counter (
    input  wire        clk,        //clock
    input  wire        rst,        //synchronous, active-high reset
    input  wire        enable,     //count enable
    input  wire        load,       //synchronous load enable
    input  wire [7:0]  load_data,  //data to load when load=1
    input  wire        oe,         //output enable (1=drive q, 0=high-Z)
    output wire [7:0]  q           //tri-stated output bus
);

    reg [7:0] count;

    //Synchronous logic: reset -> load -> increment
    always @(posedge clk) begin
        if (rst) begin
            count <= 8'd0;
        end else if (load) begin
            count <= load_data;
        end else if (enable) begin
            count <= count + 8'd1; //wraps naturally at 255 -> 0
        end
    end

    //Tri-state output
    assign q = oe ? count : 8'bz;

endmodule

`default_nettype wire