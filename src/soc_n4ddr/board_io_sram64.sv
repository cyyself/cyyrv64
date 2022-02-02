module board_io_sram64 #(
    parameter BASE_ADDR = 64'h64000000
) (
    // sram interface
    input  [63:0]   addra,
    input           clka,
    input  [63:0]   dina,
    output [63:0]   douta,
    input           ena,
    input  [7:0]    wea,
    // board io
    input           rst,
    output [31:0]   seg7_data,
    output [15:0]   LED,
    output [5:0]    STATUS_LED,
    input  [15:0]   SW,
    input  [4:0]    DIR_BTN
);

// write first, generate address interface with 64 bits

logic [63:0] out_line [1:0];
logic [63:0] in_line;

assign seg7_data  = out_line[0][31:0];  // 0-3
assign LED        = out_line[0][47:32]; // 4-5
assign STATUS_LED = out_line[0][53:48]; // 6: {0,0,LD17(R,G,B),LD16(R,G,B)}
// SOC_CLOCK    8-15 (read only)
// SW:          16-17
// DIR_BTN:     18  {0,0,0,C,L,D,R,U}

always_ff @(posedge clka) begin // write input to reg
    in_line <= {43'd0,DIR_BTN,SW};
end

wire [63:0] write_mask;
genvar i;
generate
    for (i=0;i<8;i++) assign write_mask[i*8 +: 8] = {8{wea[i]}};
endgenerate

logic [63:0] addr_locked        = 0;
logic [63:0] write_mask_locked  = 0;
logic [63:0] dina_locked        = 0;

always_ff @(posedge clka) begin // sram read ctrl
    if (ena) begin
        addr_locked         <= addra;
        write_mask_locked   <= write_mask;
        dina_locked         <= dina;
    end
end

wire [63:0] new_data = (out_line[0] & (~write_mask_locked)) | (dina_locked & write_mask_locked);

always_ff @(posedge clka) begin // sram write ctrl
    if (rst) begin
        {out_line[1],out_line[0]}   <= 0;
    end
    else begin
        out_line[0] <= new_data;
        out_line[1] <= out_line[1] + 1; // soc clock
    end
end

assign douta = 
    {addr_locked[63:4],4'd0} == BASE_ADDR ? out_line[addr_locked[3]] :
    in_line;


endmodule