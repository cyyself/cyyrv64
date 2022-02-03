module uart_phy #(
    parameter integer clk_hz    = 100000000,    // 100MHz
    parameter integer baudrate  = 115200
) (
    input               clk,
    input               rst,
    output              UART_TX,
    input               UART_RX,
    input        [7:0]  tx_data,
    input               tx_valid,
    output              tx_ready,
    output logic [7:0]  rx_data,
    output logic        rx_ready
);
// uart 8n1

if (clk_hz < baudrate * 64) $error("UART clock frequency too low or baud rate too high");

parameter integer clk_div       = ((clk_hz + baudrate / 2) / baudrate) - 1;
parameter integer clk_div_half  = clk_div / 2;

// tx {
logic uart_tx_busy = 0;
assign tx_ready = !uart_tx_busy;

logic [31:0] clk_cnt_tx = 0;

always_ff @(posedge clk) begin
    if (!uart_tx_busy || rst) clk_cnt_tx <= 0;
    else clk_cnt_tx <= (clk_cnt_tx == clk_div) ? 0 : (clk_cnt_tx + 1);
end


logic [9:0] tx_bit_buffer = {1'b1,9'd0};
logic [3:0] tx_bit_idx = 4'd9;
assign UART_TX = tx_bit_buffer[tx_bit_idx];

always_ff @(posedge clk) begin
    if (rst) begin
        uart_tx_busy    <= 0;
        tx_bit_buffer   <= {1'b1,9'd0};
        tx_bit_idx      <= 4'd9;
    end
    else if (!uart_tx_busy && tx_valid) begin
        tx_bit_buffer   <= {1'b1,tx_data,1'b0};
        uart_tx_busy    <= 1;
        tx_bit_idx      <= 0;
    end
    else if (clk_cnt_tx == clk_div) begin
        if (tx_bit_idx == 4'd9) uart_tx_busy <= 0;
        else tx_bit_idx <= tx_bit_idx + 1;
    end
end

// tx }

// rx {

logic rx_res = 0;
always_ff @(posedge clk) begin
    if (rst) rx_res <= 0;
    else rx_res <= UART_RX;
end
logic uart_rx_busy = 0;
logic [31:0] clk_cnt_rx = 0;
always_ff @(posedge clk) begin
    if (!uart_rx_busy || rst) clk_cnt_rx <= 0;
    else clk_cnt_rx <= (clk_cnt_rx == clk_div) ? 0 : (clk_cnt_rx + 1);
end

wire uart_rx_neg = rx_res && !UART_RX;
logic [9:0] rx_data_raw = 0;
logic [3:0] rx_bit_idx;
always_ff @(posedge clk) begin
    if (rst) begin
        uart_rx_busy    <= 0;
        rx_bit_idx      <= 0;
        rx_ready        <= 0;
    end
    else if (!uart_rx_busy && uart_rx_neg) begin
        uart_rx_busy    <= 1;
        rx_bit_idx      <= 0;
        rx_ready        <= 0;
    end
    else if (clk_cnt_rx == clk_div_half) begin
        rx_data_raw[rx_bit_idx] <= UART_RX;
    end
    else if (clk_cnt_rx == clk_div) begin
        if (rx_bit_idx == 4'd9) begin
            uart_rx_busy    <= 0;
            rx_ready        <= !rx_data_raw[0] & rx_data_raw[9];
        end
        else begin
            rx_bit_idx      <= rx_bit_idx + 1;
        end
    end
    else begin
        rx_ready        <= 0;
    end
end

assign rx_data = rx_data_raw[8:1];

// rx }

endmodule