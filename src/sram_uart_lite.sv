module sram_uart_lite #(
    parameter BASE_ADDR = 64'h60000000
) (
    input        [63:0] addra,
    input               clka,
    input        [63:0] dina,
    output logic [63:0] douta,
    input               ena,
    input         [7:0] wea,
    // to phy
    output logic  [7:0] tx_data,
    output logic        tx_valid,
    input               tx_ready,
    input         [7:0] rx_data,
    input               rx_ready
);

wire tx_writeable = !tx_valid & tx_ready;

always_ff @(posedge clka) begin
    if (ena) begin
        douta <= {16'd0,{1'b0,tx_writeable,tx_writeable,5'd0},40'd0}; // 5: UART_LSR_TEMT | UART_LSR_THRE
        if (wea[0]) begin
            tx_data     <= dina[7:0];
            tx_valid    <= 1;
            $write("%c",dina[7:0]);
        end
        else begin
            tx_data     <= 0;
            tx_valid    <= 0;
        end
    end
    else begin
        tx_data     <= 0;
        tx_valid    <= 0;
    end
end

endmodule