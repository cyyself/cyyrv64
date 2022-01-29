module sram #(
    parameter LEN_ADDR  = 32,
    parameter LEN_DATA  = 32,
    parameter DEPTH     = 32,
    parameter INIT_FILE = ""
) (
    input  [LEN_ADDR-1:0]           addra,
    input                           clka,
    input  [LEN_DATA-1:0]           dina,
    output logic [LEN_DATA-1:0]     douta,
    input                           ena,
    input  [LEN_DATA/8-1:0]         wea
);

(* ram_style="block" *) reg [LEN_DATA-1:0] ram [DEPTH-1:0];

wire [$clog2(DEPTH)-1:0] line_addr = addra[$clog2(LEN_DATA/8) +: $clog2(DEPTH)];
wire [LEN_DATA-1:0] write_mask;
wire [LEN_DATA-1:0] new_data = (ram[line_addr] & (~write_mask)) | (dina & write_mask);

genvar i;
generate
    for (i=0;i<LEN_DATA/8;i++) assign write_mask[i*8 +: 8] = {8{wea[i]}};
endgenerate

integer j;

initial begin
    for (j=0;j<DEPTH;j++) ram[j] = 0;
    if (INIT_FILE != "") $readmemh(INIT_FILE, ram);
end



always_ff @(posedge clka) begin // read
    if (ena) douta <= new_data;
    else douta <= 0;
end

always_ff @(posedge clka) begin // write
    if (ena) ram[line_addr] <= new_data;
end

endmodule