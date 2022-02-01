module sram #(
    parameter LEN_ADDR  = 32,
    parameter LEN_DATA  = 32,
    parameter DEPTH     = 32,
    parameter INIT_FILE = ""
) (
    input  [LEN_ADDR-1:0]   addra,
    input                   clka,
    input  [LEN_DATA-1:0]   dina,
    output [LEN_DATA-1:0]   douta,
    input                   ena,
    input  [LEN_DATA/8-1:0] wea
);

(* ram_style="block" *) reg [LEN_DATA-1:0] ram [DEPTH-1:0];

wire [$clog2(DEPTH)-1:0] line_addr = addra[$clog2(LEN_DATA/8) +: $clog2(DEPTH)];
wire [LEN_DATA-1:0] write_mask;

genvar i;
generate
    for (i=0;i<LEN_DATA/8;i++) assign write_mask[i*8 +: 8] = {8{wea[i]}};
endgenerate

integer j;

initial begin
    for (j=0;j<DEPTH;j++) ram[j] = 0;
    if (INIT_FILE != "") $readmemh(INIT_FILE, ram);
end

logic [$clog2(DEPTH)-1:0]   line_addr_locked;
logic [LEN_DATA-1:0]        write_mask_locked;
logic [LEN_DATA-1:0]        dina_locked;

always_ff @(posedge clka) begin // read
    if (ena) begin
        line_addr_locked    <= line_addr;
        write_mask_locked   <= write_mask;
        dina_locked         <= dina;
    end
end

wire [LEN_DATA-1:0] new_data = (ram[line_addr_locked] & (~write_mask_locked)) | (dina_locked & write_mask_locked);

assign douta = new_data;

always_ff @(posedge clka) begin // do write at next posedge clk
    ram[line_addr_locked] <= new_data;
end

endmodule