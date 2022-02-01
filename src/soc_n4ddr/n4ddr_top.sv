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
    output          LED17_R
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

wire [63:0] bio_addra;
wire [63:0] bio_dina;
wire [63:0] bio_douta;
wire        bio_ena;
wire [7:0]  bio_wea;

wire slave_mux_in = data_addra[31:28] == 4'h6;

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
    .STATUS_LED ({LED17_b,LED17_G,LED17_R,LED16_b,LED16_G,LED16_R}),
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
    .DEPTH(512),
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
    .DEPTH(256),
    .INIT_FILE("start_data.hex")
) data_sram (
    .addra  (mem_addra),
    .clka   (clk),
    .dina   (mem_dina),
    .douta  (mem_douta),
    .ena    (mem_ena),
    .wea    (mem_wea)
);

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



endmodule