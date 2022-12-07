`ifndef AXI_DEF
`define AXI_DEF

typedef enum logic [1:0] {
    BURST_FIXED = 2'd0,
    BURST_INCR  = 2'd1,
    BURST_WRAP  = 2'd2
} axi_burst_t;

typedef enum logic [1:0] {
    RESP_OKEY   = 2'd0,
    RESP_EXOKEY = 2'd1,
    RESP_SLVERR = 2'd2,
    RESP_DECERR = 2'd3
} axi_resp_t;

interface axi;
    logic  [3:0]awid;
    logic [31:0]awaddr;
    logic  [7:0]awlen;
    logic  [2:0]awsize;
    axi_burst_t awburst;
    logic       awvalid;
    logic       awready;
    // w
    logic [63:0]wdata;
    logic  [7:0]wstrb;
    logic       wlast;
    logic       wvalid;
    logic       wready;
    // b
    logic  [3:0]bid;
    axi_resp_t  bresp;
    logic       bvalid;
    logic       bready;
    // ar
    logic  [3:0]arid;
    logic [31:0]araddr;
    logic  [7:0]arlen;
    logic  [2:0]arsize;
    logic  [1:0]arburst;
    logic       arvalid;
    logic       arready;
    // r
    logic  [3:0]rid;
    logic [63:0]rdata;
    axi_resp_t  rresp;
    logic       rlast;
    logic       rvalid;
    logic       rready;

    modport master(
        output awid, awaddr, awlen, awsize, awburst, awvalid,
        input  awready,
        output wdata, wstrb, wlast, wvalid,
        input  wready,
        input  bid, bresp, bvalid,
        output bready,
        output arid, araddr, arlen, arsize, arburst, arvalid,
        input  arready,
        input  rid, rdata, rresp, rlast, rvalid,
        output rready
    );

    modport slave(
        input  awid, awaddr, awlen, awsize, awburst, awvalid,
        output awready,
        input  wdata, wstrb, wlast, wvalid,
        output wready,
        output bid, bresp, bvalid,
        input  bready,
        input  arid, araddr, arlen, arsize, arburst, arvalid,
        output arready,
        output rid, rdata, rresp, rlast, rvalid,
        input  rready
    );

    modport master_no_id(
        output awaddr, awlen, awsize, awburst, awvalid,
        input  awready,
        output wdata, wstrb, wlast, wvalid,
        input  wready,
        input  bresp, bvalid,
        output bready,
        output araddr, arlen, arsize, arburst, arvalid,
        input  arready,
        input  rdata, rresp, rlast, rvalid,
        output rready
    );

    modport master_no_id_read_only(
        output araddr, arlen, arsize, arburst, arvalid,
        input  arready,
        input  rdata, rresp, rlast, rvalid,
        output rready
    );

    modport slave_no_id(
        input  awaddr, awlen, awsize, awburst, awvalid,
        output awready,
        input  wdata, wstrb, wlast, wvalid,
        output wready,
        output bresp, bvalid,
        input  bready,
        input  araddr, arlen, arsize, arburst, arvalid,
        output arready,
        output rdata, rresp, rlast, rvalid,
        input  rready
    );

    modport slave_no_id_read_only(
        input  araddr, arlen, arsize, arburst, arvalid,
        output arready,
        output rdata, rresp, rlast, rvalid,
        input  rready
    );

endinterface
`endif
