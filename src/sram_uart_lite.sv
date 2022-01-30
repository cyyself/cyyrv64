module sram_uart_lite #(
    parameter BASE_ADDR = 64'h60000000
) (
    input  [63:0]   addra,
    input           clka,
    input  [63:0]   dina,
    output [63:0]   douta,
    input           ena,
    input  [7:0]    wea
);
// only for output

logic [63:0] addr_locked;
wire [63:0]  addra_prefix = {addra[63:3],3'd0};

assign douta = addr_locked == BASE_ADDR ? 64'h00_00_00_00_00_00_00_70_00 : 64'd0;
// 5: UART_LSR_TEMT | UART_LSR_THRE

always_ff @(posedge clka) begin
    addr_locked <= addra_prefix;
    if (addra_prefix == BASE_ADDR && wea[0]) begin
        $write("%c",dina[7:0]);
    end
end

endmodule