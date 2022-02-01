`include "def_config.vh"
`include "def_common.vh"

module stage_if(
    input               clk,
    input               rst,
    input               if_stall, // actually it's pc stall
    input               if_flush,
    output              if_ready,
    input  mem2if_fw    mem_if_fw,
    output pipe_common  if_out,
    output [63:0]       inst_addra,
    input  [31:0]       inst_douta,
    output              inst_ena
);

assign if_ready = 1'b1;

wire [63:0] new_pc  = 
    rst                     ? `RST_PC : 
    mem_if_fw.mem_pc_src    ? mem_if_fw.mem_new_pc : 
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


wire [31:0] instr = inst_douta;

assign inst_addra   = new_pc;
assign inst_ena     = 1;

assign if_out.instr = instr;
assign if_out.valid = 1;

endmodule