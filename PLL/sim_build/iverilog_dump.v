module iverilog_dump();
initial begin
    $dumpfile("nco.fst");
    $dumpvars(0, nco);
end
endmodule
