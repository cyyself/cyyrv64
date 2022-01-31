module cpu_top(
    input   clk,
    input   rst
);

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

wire [63:0] uart_addra;
wire [63:0] uart_dina;
wire [63:0] uart_douta;
wire        uart_ena;
wire [7:0]  uart_wea;

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

sram #(
    .LEN_ADDR(64),
    .DEPTH(4096),
    .INIT_FILE("start_inst.hex")
) inst_sram (
    .addra  (inst_addra),
    .clka   (clk),
    .dina   (0),
    .douta  (inst_douta),
    .ena    (inst_ena),
    .wea    (4'd0)
);

wire slave_mux_in = {data_addra[63:3],3'd0} == 64'h60000000;

sram_xbar #(
    .LEN_ADDR(64),
    .LEN_DATA(64)
) sram_xbar (
    .clk            (clk),
    .slave_mux_in   (slave_mux_in),
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
    .slave1_addra   (uart_addra),
    .slave1_dina    (uart_dina),
    .slave1_douta   (uart_douta),
    .slave1_ena     (uart_ena),
    .slave1_wea     (uart_wea)
);

sram #(
    .LEN_ADDR(64),
    .LEN_DATA(64),
    .DEPTH(2048),
    .INIT_FILE("start_data.hex")
) data_sram (
    .addra  (mem_addra),
    .clka   (clk),
    .dina   (mem_dina),
    .douta  (mem_douta),
    .ena    (mem_ena),
    .wea    (mem_wea)
);

sram_uart_lite uart(
    .addra  (uart_addra),
    .clka   (clk),
    .dina   (uart_dina),
    .douta  (uart_douta),
    .ena    (uart_ena),
    .wea    (uart_wea)
);
endmodule