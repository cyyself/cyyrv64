module top_axi_wrapper(
    input       clock,
    input       reset,
    // Interrupts
    input       MEI, // to PLIC
    input       MSI, // to CLINT
    input       MTI, // to CLINT
    // aw
    output [3:0]MAXI_awid,
    output[31:0]MAXI_awaddr,
    output [7:0]MAXI_awlen,
    output [2:0]MAXI_awsize,
    output [1:0]MAXI_awburst,
    output      MAXI_awvalid,
    input       MAXI_awready,
    // w
    output[63:0]MAXI_wdata,
    output [7:0]MAXI_wstrb,
    output      MAXI_wlast,
    output      MAXI_wvalid,
    input       MAXI_wready,
    // b
    input  [3:0]MAXI_bid,
    input  [1:0]MAXI_bresp,
    input       MAXI_bvalid,
    output      MAXI_bready,
    // ar
    output [3:0]MAXI_arid,
    output[31:0]MAXI_araddr,
    output [7:0]MAXI_arlen,
    output [2:0]MAXI_arsize,
    output [1:0]MAXI_arburst,
    output      MAXI_arvalid,
    input       MAXI_arready,
    // r
    input  [3:0]MAXI_rid,
    input [63:0]MAXI_rdata,
    input  [1:0]MAXI_rresp,
    input       MAXI_rlast,
    input       MAXI_rvalid,
    output      MAXI_rready,
    // debug
    output      debug_commit,
    output[63:0]debug_pc,
    output[4:0] debug_reg_num,
    output[63:0]debug_wdata
);


core_top core_inst(
    .clock      (clock),
    .reset      (reset),
    // Interrupts
    .MEI        (MEI), // to PLIC
    .MSI        (MSI), // to CLINT
    .MTI        (MTI), // to CLINT
    // aw
    .awid       (MAXI_awid),
    .awaddr     (MAXI_awaddr),
    .awlen      (MAXI_awlen),
    .awsize     (MAXI_awsize),
    .awburst    (MAXI_awburst),
    .awvalid    (MAXI_awvalid),
    .awready    (MAXI_awready),
    // w
    .wdata      (MAXI_wdata),
    .wstrb      (MAXI_wstrb),
    .wlast      (MAXI_wlast),
    .wvalid     (MAXI_wvalid),
    .wready     (MAXI_wready),
    // b
    .bid        (MAXI_bid),
    .bresp      (MAXI_bresp),
    .bvalid     (MAXI_bvalid),
    .bready     (MAXI_bready),
    // ar
    .arid       (MAXI_arid),
    .araddr     (MAXI_araddr),
    .arlen      (MAXI_arlen),
    .arsize     (MAXI_arsize),
    .arburst    (MAXI_arburst),
    .arvalid    (MAXI_arvalid),
    .arready    (MAXI_arready),
    // r
    .rid        (MAXI_rid),
    .rdata      (MAXI_rdata),
    .rresp      (MAXI_rresp),
    .rlast      (MAXI_rlast),
    .rvalid     (MAXI_rvalid),
    .rready     (MAXI_rready),
    // debug
    .debug_commit(debug_commit),
    .debug_pc   (debug_pc),
    .debug_reg_num(debug_reg_num),
    .debug_wdata(debug_wdata)
);

endmodule
