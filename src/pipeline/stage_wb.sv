`include "def_common.vh"
module stage_wb(
    input               clk,
    input               rst,
    input               wb_flush,
    output              wb_ready,
    input  ctrl_sign    wb_ctrl,
    input  pipe_common  wb_pipe,
    input  mem2wb       wb_in,
    output wb_reg       wb_out
);

assign wb_ready = 1'b1;

logic [63:0] wb_result = wb_ctrl.mem_read ? wb_in.readdata : wb_in.result;

assign wb_out.rd    = wb_pipe.instr[`RD_IDX];
assign wb_out.rd_en = wb_ctrl.rd_en;
assign wb_out.result= wb_result;

endmodule