`include "def_axi.svh"
`include "def.svh"

module d_no_cache(
    input               clock,
    input               reset,
    axi.master_no_id    axi_bus,
    data_bus.slave      dbus
);

// warn: according to amba axi spec, master should NOT wait awvalid before asserting wvalid.

enum { IDLE, READ, WRITE, FINISH_WAIT } status;

logic [7:0] wstrb_gen;

always_comb begin
    case (dbus.size)
        0: wstrb_gen = 8'b1 << dbus.addr[2:0];
        1: wstrb_gen = 8'b11 << {dbus.addr[2:1],1'd0};
        2: wstrb_gen = 8'b1111 << {dbus.addr[2:2],2'd0};
        3: wstrb_gen = 8'b11111111;
    endcase
end

assign dbus.valid = status == FINISH_WAIT;

wire addr_err = |dbus.addr[63:32];

always_ff @(posedge clock) begin
    if (reset) begin
        // reset all reg
        axi_bus.awaddr <= 0;
        axi_bus.awlen <= 0;
        axi_bus.awsize <= 0;
        axi_bus.awburst <= BURST_FIXED;
        axi_bus.awvalid <= 0;
        axi_bus.wdata <= 0;
        axi_bus.wstrb <= 0;
        axi_bus.wlast <= 1;
        axi_bus.wvalid <= 0;
        axi_bus.bready <= 1;
        axi_bus.araddr <= 0;
        axi_bus.arlen <= 0;
        axi_bus.arsize <= 0;
        axi_bus.arburst <= BURST_FIXED;
        axi_bus.arvalid <= 0;
        axi_bus.rready <= 1;
        status <= IDLE;
        dbus.rdata <= 0;
    end
    else begin
        case (status)
            IDLE: begin
                if (dbus.en) begin
                    if (addr_err) begin
                        dbus.acc_err <= 1'b1;
                        status <= FINISH_WAIT;
                    end
                    else begin
                        if (dbus.write) begin
                            axi_bus.awaddr <= dbus.addr[31:0];
                            axi_bus.awsize <= {1'b0,dbus.size};
                            axi_bus.awvalid <= 1;
                            axi_bus.wdata  <= dbus.wdata;
                            axi_bus.wstrb  <= wstrb_gen;
                            axi_bus.wvalid <= 1;
                            status <= WRITE;
                        end
                        else begin
                            axi_bus.araddr <= dbus.addr[31:0];
                            axi_bus.arsize <= {1'b0,dbus.size};
                            axi_bus.arvalid <= 1;
                            status <= READ;
                        end
                    end
                end
            end
            READ: begin
                if (axi_bus.arready) axi_bus.arvalid <= 0;
                if (axi_bus.rvalid) begin
                    dbus.rdata <= axi_bus.rdata;
                    dbus.acc_err <= axi_bus.rresp != RESP_OKEY;
                    status <= FINISH_WAIT;
                end
            end
            WRITE: begin
                if (axi_bus.awready) axi_bus.awvalid <= 0;
                if (axi_bus.wready) axi_bus.wvalid <= 0;
                if (axi_bus.bvalid) begin 
                    status <= FINISH_WAIT;
                    dbus.acc_err <= axi_bus.bresp != RESP_OKEY;
                end
            end
            FINISH_WAIT: begin
                if (dbus.ready) begin
                    dbus.acc_err <= 1'b0;
                    if (dbus.en) begin
                        if (addr_err) begin
                            dbus.acc_err <= 1'b1;
                            status <= FINISH_WAIT;
                        end
                        else begin
                            if (dbus.write) begin
                                axi_bus.awaddr <= dbus.addr[31:0];
                                axi_bus.awsize <= {1'b0,dbus.size};
                                axi_bus.awvalid <= 1;
                                axi_bus.wdata  <= dbus.wdata;
                                axi_bus.wstrb  <= wstrb_gen;
                                axi_bus.wvalid <= 1;
                                status <= WRITE;
                            end
                            else begin
                                axi_bus.araddr <= dbus.addr[31:0];
                                axi_bus.arsize <= {1'b0,dbus.size};
                                axi_bus.arvalid <= 1;
                                status <= READ;
                            end
                        end
                    end
                    else status <= IDLE;
                end
            end
        endcase
    end
end

endmodule
