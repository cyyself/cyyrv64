module n4ddr_top(
    input           CLK100MHZ,
    input           CPU_RESETN,
    // 7seg
    output [7:0]    AN,
    output          CA,
    output          CB,
    output          CC,
    output          CD,
    output          CE,
    output          CF,
    output          CG,
    output          DP
);


seg7 seg7(
    .clk    (CLK100MHZ),
    .data   (32'hdeadbeef),
    .AN     (AN),
    .CA     (CA),
    .CB     (CB),
    .CC     (CC),
    .CD     (CD),
    .CE     (CE),
    .CF     (CF),
    .CG     (CG),
    .DP     (DP)
);

endmodule