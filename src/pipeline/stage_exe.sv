`include "def_common.vh"
module stage_exe(
    input               clk,
    input               rst,
    input               exe_flush,
    output              exe_ready,
    input  pipe_common  exe_pipe,
    input  ctrl_sign    exe_ctrl,
    input  exe_data_fw  exe_data,
    input  id2exe       exe_in,
    output exe2mem      exe_out,
    output exe2if_fw    exe_if,
    output exe2mem_fw   exe_mem_fw
);

assign exe_ready        = exe_data.valid;

wire  [63:0] alu_a      = exe_ctrl.alu_pc  ? exe_pipe.pc :   exe_data.rs1;   // for auipc only
wire  [63:0] alu_b      = exe_ctrl.alu_imm ? exe_in.imm  :   exe_data.rs2;

assign exe_mem_fw.mem_en   = exe_ctrl.mem_read | exe_ctrl.mem_write;
assign exe_mem_fw.mem_write= exe_ctrl.mem_write;
assign exe_mem_fw.rs2_data = exe_data.rs2;
assign exe_mem_fw.funct3   = exe_pipe.instr[`FUNCT3_IDX];
// bypass alu to d_cache to get better timing
assign exe_mem_fw.memaddr  = exe_data.rs1  + exe_in.imm;
// bypass alu to i_cache to get better timing
assign exe_if.exe_new_pc    = 
    exe_ctrl.branch ? (exe_pipe.pc + exe_in.imm) : 
    exe_ctrl.jalr   ? (exe_data.rs1 + exe_in.imm) :
                      (exe_pipe.pc + exe_in.imm);

alu alu(
    .in_a   (alu_a),
    .in_b   (alu_b),
    .word32 (exe_ctrl.alu_32),
    .aluctrl(exe_ctrl.alu_control),
    .result (exe_out.alu_out)
);

logic   branch_taken;

blu blu(
    .in_a   (exe_data.rs1),
    .in_b   (exe_data.rs2),
    .funct3 (exe_pipe.instr[`FUNCT3_IDX]),
    .taken  (branch_taken)
);

assign exe_if.exe_pc_src = ( (exe_ctrl.branch && branch_taken) || exe_ctrl.jump) && exe_data.valid;

endmodule