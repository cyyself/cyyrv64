`include "def_config.vh"
`include "def_common.vh"

module stage_if(
    input               clk,
    input               rst,
    input               if_stall, // actually it's pc stall
    input               if_flush,
    output              if_ready,
    input  exe2if_fw    exe_if_fw,
    output pipe_common  if_out
);

assign if_ready = 1'b1;

wire [63:0] new_pc  = 
    rst                     ? `RST_PC : 
    exe_if_fw.exe_pc_src    ? exe_if_fw.exe_new_pc : 
    if_stall                ? if_out.pc :
    if_out.pc + 4;

ff #(.WIDTH(64)) pcreg(
    .clk     (clk),
    .rst     (rst),
    .flush   (0),
    .stall   (0),
    .data_in (new_pc),
    .data_out(if_out.pc)
);


wire [31:0] instr;

sram #(
    .LEN_ADDR(64),
    .DEPTH(1024),
    .INIT_FILE("start.hex")
) sram (
    .addra  (new_pc),
    .clka   (clk),
    .dina   (0),
    .douta  (instr),
    .ena    (1'b1),
    .wea    (4'd0)
);

assign if_out.instr = instr;

endmodule