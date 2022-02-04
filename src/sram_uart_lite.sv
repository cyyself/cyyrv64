module sram_uart_lite #(
    parameter BASE_ADDR = 64'h60000000,
    parameter FIFO_SIZE = 256
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
/*
    Warning:
    
    Although there are 64 bits for data, this interface support
    byte read/write only.

    This means your addra input should set low 3 bits for byte
    address and do not set ena to high more than one clock for
    one transaction, else will cause byte loss.

    Please mind that your CPU core should not set ena to high 
    continuously during pipeline stalling.

*/

wire tx_writeable = !tx_valid & tx_ready;

always_ff @(posedge clka) begin
    if (ena) begin
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

reg [7:0] fifo [FIFO_SIZE-1:0];
reg [$clog2(FIFO_SIZE)-1:0] fifo_idx = 0;
wire fifo_full  = {1'b0,fifo_idx} == FIFO_SIZE - 1;
wire fifo_we    = rx_ready;
wire fifo_read  = ena && !wea[0] && addra[2:0] == 3'd0;
wire fifo_shift = fifo_read || (fifo_we && fifo_full);

integer j;
initial begin
    for (j=0;j<FIFO_SIZE;j++) fifo[j] = 0;
end

genvar i;
generate
    for (i=0;i<FIFO_SIZE-1;i++)
    always_ff @(posedge clka) begin
        if (i == fifo_idx && fifo_we) fifo[i] <= rx_data;
        else if (fifo_shift) fifo[i] <= fifo[i+1];
    end
endgenerate

always_ff @(posedge clka) begin
    if (fifo_shift && !fifo_we) begin
        if (|fifo_idx) fifo_idx  <= fifo_idx - 1;
    end
    else if (fifo_we && !fifo_shift) begin
        fifo_idx    <= fifo_idx + 1;
    end
    if (ena) begin
        /*
            5: UART_LSR_TEMT | UART_LSR_THRE | UART_LSR_DR
            UART_LSR_TEMT: 0x40, Transmitter empty
            UART_LSR_THRE: 0x20, Transmit-hold-register empty
            UART_LSR_DR  : 0x01, Receiver data ready
        */
        douta <= {16'd0,{1'b0,tx_writeable,tx_writeable,4'd0,|fifo_idx},32'd0,fifo[0]};
    end
end

endmodule