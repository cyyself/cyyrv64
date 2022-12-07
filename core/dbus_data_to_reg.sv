module dbus_data_to_reg(
    input        [2:0]  raddr,
    input        [2:0]  waddr,
    input       [63:0]  rdata,
    output logic[63:0]  wdata,
    input        [1:0]  rsize,
    input        [1:0]  wsize,
    input               ruext,
    input        [63:0] reg_in,
    output logic [63:0] reg_out
);

wire [7:0] rdata8  = rdata[ {raddr[2:0],3'd0} +: 8];
wire [15:0] rdata16 = rdata[ {raddr[2:1],4'd0} +: 16];
wire [31:0] rdata32 = rdata[ {raddr[2]  ,5'd0} +: 32];

always_comb begin
    case(rsize)
        0: reg_out = ruext ? {56'd0,rdata8} : {{56{rdata8[7]}},rdata8};
        1: reg_out = ruext ? {48'd0,rdata16} : {{48{rdata16[15]}},rdata16};
        2: reg_out = ruext ? {32'd0,rdata32} : {{32{rdata32[31]}},rdata32};
        3: reg_out = rdata;
    endcase
end

always_comb begin
    case (wsize)
        0: wdata = {56'd0,reg_in[7:0]} << {waddr[2:0],3'd0};
        1: wdata = {48'd0,reg_in[15:0]} << {waddr[2:1],4'd0};
        2: wdata = {32'd0,reg_in[31:0]} << {waddr[2],5'd0};
        3: wdata = reg_in;
    endcase
end

endmodule
