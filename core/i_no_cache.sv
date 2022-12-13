`include "def_axi.svh"
`include "def.svh"

module i_no_cache (
    input                       clock,
    input                       reset,
    axi.master_no_id_read_only  axi_bus,
    inst_bus.slave              ibus
);

enum { IDLE, READ, FINISH_WAIT } status;

assign ibus.valid = status == FINISH_WAIT;
wire addr_err = |ibus.addr[63:32];

always_ff @(posedge clock) begin
    if (reset) begin
        axi_bus.araddr <= 0;
        axi_bus.arlen <= 0;
        axi_bus.arsize <= 2; // inst always 4 Bytes
        axi_bus.arburst <= BURST_FIXED;
        axi_bus.arvalid <= 0;
        axi_bus.rready <= 1;
        status <= IDLE;
        ibus.rdata <= 0;
        ibus.acc_err <= 0;
    end
    else begin
        case(status)
            IDLE: begin
                if (ibus.en) begin
                    if (addr_err) begin
                        ibus.acc_err <= 1'b1;
                        status <= FINISH_WAIT;
                    end
                    else begin
                        axi_bus.araddr <= {ibus.addr[31:2],2'd0};
                        axi_bus.arvalid <= 1;
                        status <= READ;
                    end
                end
            end
            READ: begin
                if (axi_bus.arready) axi_bus.arvalid <= 0;
                if (axi_bus.rvalid) begin
                    ibus.rdata <= axi_bus.araddr[2] ? axi_bus.rdata[63:32] : axi_bus.rdata[31:0];
                    ibus.acc_err <= axi_bus.rresp != RESP_OKEY;
                    status <= FINISH_WAIT;
                end
            end
            FINISH_WAIT: begin
                if (ibus.ready) begin
                    ibus.acc_err <= 1'b0;
                    if (ibus.en) begin // same as idle
                        if (addr_err) begin
                            ibus.acc_err <= 1'b1;
                            status <= FINISH_WAIT;
                        end
                        else begin
                            axi_bus.araddr <= {ibus.addr[31:2],2'd0};
                            axi_bus.arvalid <= 1;
                            status <= READ;
                        end
                    end
                end
            end
        endcase
    end
end

endmodule
