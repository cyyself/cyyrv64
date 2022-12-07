`include "def.svh"
`include "def_axi.svh"

module core_top(
    input       clock,
    input       reset,
    // Interrupts
    input       MEI, // to PLIC
    input       MSI, // to CLINT
    input       MTI, // to CLINT
    // aw
    output [3:0]awid,
    output[31:0]awaddr,
    output [7:0]awlen,
    output [2:0]awsize,
    output [1:0]awburst,
    output      awvalid,
    input       awready,
    // w
    output[63:0]wdata,
    output [7:0]wstrb,
    output      wlast,
    output      wvalid,
    input       wready,
    // b
    input  [3:0]bid,
    input  [1:0]bresp,
    input       bvalid,
    output      bready,
    // ar
    output [3:0]arid,
    output[31:0]araddr,
    output [7:0]arlen,
    output [2:0]arsize,
    output [1:0]arburst,
    output      arvalid,
    input       arready,
    // r
    input  [3:0]rid,
    input [63:0]rdata,
    input  [1:0]rresp,
    input       rlast,
    input       rvalid,
    output      rready,
    // debug
    output      debug_commit,
    output[63:0]debug_pc,
    output[4:0] debug_reg_num,
    output[63:0]debug_wdata
);

axi axi_bus, icache_axi, dcache_axi;

assign awid             = axi_bus.awid;
assign awaddr           = axi_bus.awaddr;
assign awlen            = axi_bus.awlen;
assign awsize           = axi_bus.awsize;
assign awburst          = axi_bus.awburst;
assign awvalid          = axi_bus.awvalid;
assign axi_bus.awready  = awready;

assign wdata            = axi_bus.wdata;
assign wstrb            = axi_bus.wstrb;
assign wlast            = axi_bus.wlast;
assign wvalid           = axi_bus.wvalid;
assign axi_bus.wready   = wready;

assign axi_bus.bid      = bid;
assign axi_bus.bresp    = bresp;
assign axi_bus.bvalid   = bvalid;
assign bready           = axi_bus.bready;

assign arid             = axi_bus.arid;
assign araddr           = axi_bus.araddr;
assign arlen            = axi_bus.arlen;
assign arsize           = axi_bus.arsize;
assign arburst          = axi_bus.arburst;
assign arvalid          = axi_bus.arvalid;
assign axi_bus.arready  = arready;

assign axi_bus.rid      = rid;
assign axi_bus.rdata    = rdata;
assign axi_bus.rresp    = rresp;
assign axi_bus.rlast    = rlast;
assign axi_bus.rvalid   = rvalid;
assign rready           = axi_bus.rready;

hart_int hart_int_pack;

assign hart_int_pack.MEI = MEI;
assign hart_int_pack.MSI = MSI;
assign hart_int_pack.MTI = MTI;

debug_bus debug;

assign debug_commit = debug.commit;
assign debug_pc     = debug.pc;
assign debug_reg_num= debug.reg_num;
assign debug_wdata  = debug.wdata;


inst_bus ibus;
data_bus dbus;

axi_mux axi_mux_inst(
    .clock      (clock),
    .reset      (reset),
    .axi_bus    (axi_bus),
    .icache     (icache_axi),
    .dcache     (dcache_axi)
);

i_no_cache i_cache_inst (
    .clock      (clock),
    .reset      (reset),
    .axi_bus    (icache_axi),
    .ibus       (ibus)
);

d_no_cache d_cache_inst (
    .clock      (clock),
    .reset      (reset),
    .axi_bus    (dcache_axi),
    .dbus       (dbus)
);

core_pipeline pipeline_inst(
    .clock      (clock),
    .reset      (reset),
    .ext_int    (hart_int_pack),
    .i_bus      (ibus),
    .d_bus      (dbus),
    .debug      (debug)
);

endmodule
