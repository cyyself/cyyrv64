module sram_xbar #(
    parameter LEN_ADDR  = 32,
    parameter LEN_DATA  = 32
) (
    input                   clk,
    input                   slave_mux_in,
    input  [LEN_ADDR-1:0]   master_addra,
    input  [LEN_DATA-1:0]   master_dina,
    output [LEN_DATA-1:0]   master_douta,
    input                   master_ena,
    input  [LEN_DATA/8-1:0] master_wea,
    output [LEN_ADDR-1:0]   slave0_addra,
    output [LEN_DATA-1:0]   slave0_dina,
    input  [LEN_DATA-1:0]   slave0_douta,
    output                  slave0_ena,
    output [LEN_DATA/8-1:0] slave0_wea,
    output [LEN_ADDR-1:0]   slave1_addra,
    output [LEN_DATA-1:0]   slave1_dina,
    input  [LEN_DATA-1:0]   slave1_douta,
    output                  slave1_ena,
    output [LEN_DATA/8-1:0] slave1_wea
);

logic last_mux;

always_ff @(posedge clk) begin
    last_mux <= slave_mux_in;
end

assign slave0_ena   = slave_mux_in == 0 && master_ena;
assign slave1_ena   = slave_mux_in == 1 && master_ena;

assign slave0_wea   = slave_mux_in == 0 ? master_wea : 0;
assign slave1_wea   = slave_mux_in == 1 ? master_wea : 0;

assign master_douta = last_mux ? slave1_douta : slave0_douta;

assign slave0_addra = master_addra;
assign slave1_addra = master_addra;

assign slave0_dina  = master_dina;
assign slave1_dina  = master_dina;

endmodule