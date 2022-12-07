`include "def_axi.svh"

module axi_mux(
    input clock,
    input reset,

    axi.master                  axi_bus,
    axi.slave_no_id_read_only   icache,
    axi.slave_no_id             dcache
);

// pass-through aw {
assign axi_bus.awid     = 4'd1; // id=1 for dcache
assign axi_bus.awaddr   = dcache.awaddr;
assign axi_bus.awlen    = dcache.awlen;
assign axi_bus.awsize   = dcache.awsize;
assign axi_bus.awburst  = dcache.awburst;
assign axi_bus.awvalid  = dcache.awvalid;
assign dcache.awready   = axi_bus.awready;
// pass-through aw }

// pass-through w {
assign axi_bus.wdata    = dcache.wdata;
assign axi_bus.wstrb    = dcache.wstrb;
assign axi_bus.wlast    = dcache.wlast;
assign axi_bus.wvalid   = dcache.wvalid;
assign dcache.wready    = axi_bus.wready;
// pass-through aw }

// pass-through b {
assign dcache.bvalid    = axi_bus.bvalid;
assign dcache.bresp     = axi_bus.bresp;
assign axi_bus.bready   = dcache.bready;
// pass-through b }

// mux ar {
// we need to lock ar to avoid signals change during handshake
reg ar_sel_lock;
reg ar_sel_val;
wire ar_sel = ar_sel_lock ? ar_sel_val : (dcache.arvalid ? 1'b1 : 1'b0);
always_ff @(posedge clock) begin
    if (reset) begin
        ar_sel_lock <= 0;
        ar_sel_val  <= 0;
    end
    else begin
        if (axi_bus.arvalid) begin
            if (axi_bus.arready) begin
                ar_sel_lock <= 0;
            end
            else begin
                ar_sel_lock <= 1'b1;
                ar_sel_val  <= ar_sel;
            end
        end
    end
end
assign axi_bus.arid     = {3'd0,ar_sel};
assign axi_bus.araddr   = ar_sel ? dcache.araddr    : icache.araddr;
assign axi_bus.arlen    = ar_sel ? dcache.arlen     : icache.arlen;
assign axi_bus.arsize   = ar_sel ? dcache.arsize    : icache.arsize;
assign axi_bus.arburst  = ar_sel ? dcache.arburst   : icache.arburst;
assign axi_bus.arvalid  = ar_sel ? dcache.arvalid   : icache.arvalid;
assign icache.arready   = !ar_sel && axi_bus.arready;
assign dcache.arready   =  ar_sel && axi_bus.arready;
// mux ar }

// mux r based on rid {
wire r_sel = axi_bus.rid[0];
assign icache.rdata     = axi_bus.rdata;
assign icache.rresp     = axi_bus.rresp;
assign icache.rlast     = axi_bus.rlast;
assign icache.rvalid    = !r_sel && axi_bus.rvalid;
assign dcache.rdata     = axi_bus.rdata;
assign dcache.rresp     = axi_bus.rresp;
assign dcache.rlast     = axi_bus.rlast;
assign dcache.rvalid    = r_sel && axi_bus.rvalid;
assign axi_bus.rready   = r_sel ? dcache.rready : icache.rready;
// mux r based on rid }

endmodule
