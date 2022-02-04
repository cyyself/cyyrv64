module n4ddr_top(
    input           CLK100MHZ,
    input           CPU_RESETN,
    // 7seg
    output [7:0]    AN,
    output          CA,
    output          CB,
    output          CC,
    output          CD,
    output          CE,
    output          CF,
    output          CG,
    output          DP,
    // Buttons
    input           BTNC,
    input           BTNU,
    input           BTNL,
    input           BTNR,
    input           BTND,
    // Switches
    input  [15:0]   SW,
    // LEDs
    output [15:0]   LED,
    output          LED16_B,
    output          LED16_G,
    output          LED16_R,
    output          LED17_B,
    output          LED17_G,
    output          LED17_R,
    // UART
    input           UART_TXD_IN,
    output          UART_RXD_OUT
);

wire clk;
wire pll_locked;

clk_wiz_0 pll(
    .resetn     (CPU_RESETN),
    .clk_in1    (CLK100MHZ),
    .clk_out1   (clk),
    .locked     (pll_locked)
);

wire rst = !pll_locked;

wire [31:0] seg7_data;

wire [63:0] inst_addra;
wire [31:0] inst_douta;
wire        inst_ena;

wire [63:0] data_addra;
wire [63:0] data_dina;
wire [63:0] data_douta;
wire        data_ena;
wire [7:0]  data_wea;

wire [63:0] mem_addra;
wire [63:0] mem_dina;
wire [63:0] mem_douta;
wire        mem_ena;
wire [7:0]  mem_wea;

wire [63:0] dev_addra;
wire [63:0] dev_dina;
wire [63:0] dev_douta;
wire        dev_ena;
wire [7:0]  dev_wea;

wire [63:0] uart_addra;
wire [63:0] uart_dina;
wire [63:0] uart_douta;
wire        uart_ena;
wire [7:0]  uart_wea;

wire [63:0] bio_addra;
wire [63:0] bio_dina;
wire [63:0] bio_douta;
wire        bio_ena;
wire [7:0]  bio_wea;

board_io_sram64 board_io(
    // sram interface
    .addra      (bio_addra),
    .clka       (clk),
    .dina       (bio_dina),
    .douta      (bio_douta),
    .ena        (bio_ena),
    .wea        (bio_wea),
    // board io
    .rst        (rst),
    .seg7_data  (seg7_data),
    .LED        (LED),
    .STATUS_LED ({LED17_B,LED17_G,LED17_R,LED16_B,LED16_G,LED16_R}),
    .SW         (SW),
    .DIR_BTN    ({BTNC,BTNL,BTND,BTNR,BTNU})
);

seg7_phy seg7(
    .clk    (clk),
    .data   (seg7_data),
    .AN     (AN),
    .CA     (CA),
    .CB     (CB),
    .CC     (CC),
    .CD     (CD),
    .CE     (CE),
    .CF     (CF),
    .CG     (CG),
    .DP     (DP)
);

sram #(
    .LEN_ADDR(64),
    .DEPTH(8192),
    .INIT_FILE("start_inst.hex")
) inst_sram (
    .addra  (inst_addra),
    .clka   (clk),
    .dina   (0),
    .douta  (inst_douta),
    .ena    (inst_ena),
    .wea    (4'd0)
);

sram #(
    .LEN_ADDR(64),
    .LEN_DATA(64),
    .DEPTH(4096),
    .INIT_FILE("start_data.hex")
) data_sram (
    .addra  (mem_addra),
    .clka   (clk),
    .dina   (mem_dina),
    .douta  (mem_douta),
    .ena    (mem_ena),
    .wea    (mem_wea)
);

wire mem_dev_sel = data_addra[31:28] == 4'h6;

sram_xbar #(
    .LEN_ADDR(64),
    .LEN_DATA(64)
) xbar_mem_device (
    .clk            (clk),
    .slave_mux_in   (mem_dev_sel),
    .master_addra   (data_addra),
    .master_dina    (data_dina),
    .master_douta   (data_douta),
    .master_ena     (data_ena),
    .master_wea     (data_wea),
    .slave0_addra   (mem_addra),
    .slave0_dina    (mem_dina),
    .slave0_douta   (mem_douta),
    .slave0_ena     (mem_ena),
    .slave0_wea     (mem_wea),
    .slave1_addra   (dev_addra),
    .slave1_dina    (dev_dina),
    .slave1_douta   (dev_douta),
    .slave1_ena     (dev_ena),
    .slave1_wea     (dev_wea)
);

wire uart_bio_sel = dev_addra[27:24] == 4'h4;

sram_xbar #(
    .LEN_ADDR(64),
    .LEN_DATA(64)
) xbar_uart_bio (
    .clk            (clk),
    .slave_mux_in   (uart_bio_sel),
    .master_addra   (dev_addra),
    .master_dina    (dev_dina),
    .master_douta   (dev_douta),
    .master_ena     (dev_ena),
    .master_wea     (dev_wea),
    .slave0_addra   (uart_addra),
    .slave0_dina    (uart_dina),
    .slave0_douta   (uart_douta),
    .slave0_ena     (uart_ena),
    .slave0_wea     (uart_wea),
    .slave1_addra   (bio_addra),
    .slave1_dina    (bio_dina),
    .slave1_douta   (bio_douta),
    .slave1_ena     (bio_ena),
    .slave1_wea     (bio_wea)
);


pipeline pipeline(
    .clk        (clk),
    .rst        (rst),
    .inst_addra (inst_addra),
    .inst_douta (inst_douta),
    .inst_ena   (inst_ena),
    .data_addra (data_addra),
    .data_dina  (data_dina),
    .data_douta (data_douta),
    .data_ena   (data_ena),
    .data_wea   (data_wea)
);



wire  [7:0] uart_tx_data;
wire        uart_tx_valid;
wire        uart_tx_ready;
wire  [7:0] uart_rx_data;
wire        uart_rx_ready;

uart_phy #(.clk_hz(100000000)) uart_phy (
    .clk        (clk),
    .rst        (rst),
    .UART_TX    (UART_RXD_OUT),
    .UART_RX_i  (UART_TXD_IN),
    .tx_data    (uart_tx_data),
    .tx_valid   (uart_tx_valid),
    .tx_ready   (uart_tx_ready),
    .rx_data    (uart_rx_data),
    .rx_ready   (uart_rx_ready)
);

sram_uart_lite #(.FIFO_SIZE(64)) uart(
    .addra      (uart_addra),
    .clka       (clk),
    .dina       (uart_dina),
    .douta      (uart_douta),
    .ena        (uart_ena),
    .wea        (uart_wea),
    .tx_data    (uart_tx_data),
    .tx_valid   (uart_tx_valid),
    .tx_ready   (uart_tx_ready),
    .rx_data    (uart_rx_data),
    .rx_ready   (uart_rx_ready)
);

endmodule