`include "def_inst.vh"
`include "def_common.vh"
module stage_mem(
    input               clk,
    input               rst,
    input               mem_flush,
    output              mem_ready,
    input  ctrl_sign    mem_ctrl,
    input  pipe_common  mem_pipe,
    input  exe2mem      mem_in,
    output mem2wb       mem_out,
    input  exe2mem_fw   exe_mem_fw,
    output mem2exe_fw   mem_exe_fw,
    output mem2if_fw    mem_if_fw,
    output [63:0]       data_addra,
    output [63:0]       data_dina,
    input  [63:0]       data_douta,
    output              data_ena,
    output [7:0]        data_wea
);

assign mem_out.result   = mem_ctrl.jump ? (mem_pipe.pc + 4) : mem_in.alu_out;
assign mem_exe_fw.result= mem_out.result;
assign mem_if_fw        = mem_in.branch;

sram64_trans sram64_trans(
    .funct3_read    (mem_pipe.instr[`FUNCT3_IDX]),
    .funct3_write   (exe_mem_fw.funct3),
    .writedata      (exe_mem_fw.rs2_data),
    .readdata       (mem_out.readdata),
    .memaddr_read   (mem_in.memaddr),
    .memaddr_write  (exe_mem_fw.memaddr),
    .mem_write      (exe_mem_fw.mem_write),
    .sram_wea       (data_wea),
    .sram_dina      (data_dina),
    .sram_douta     (data_douta)
);

assign data_addra   = exe_mem_fw.memaddr;
assign data_ena     = exe_mem_fw.mem_en;
assign mem_ready    = 1'b1;

endmodule