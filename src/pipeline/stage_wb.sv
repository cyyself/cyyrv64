`include "def_common.vh"
module stage_wb(
    input               clk,
    input               rst,
    input               wb_flush,
    output              wb_ready,
    input  ctrl_sign    wb_ctrl,
    input  pipe_common  wb_pipe,
    input  mem2wb       wb_in,
    output wb_reg       wb_out,
    output wb2exe_fw    wb_exe_fw
);

assign wb_ready = 1'b1;

wire [63:0] wb_result = wb_ctrl.mem_read ? wb_in.readdata : wb_in.result;

assign wb_out.rd    = wb_pipe.instr[`RD_IDX];
assign wb_out.rd_en = wb_ctrl.rd_en;
assign wb_out.result= wb_result;

assign wb_exe_fw.result = wb_result;

always_ff @(posedge clk) begin
    assert (!wb_ctrl.reversed) else begin
        $display("error");
        $stop;
    end
end

endmodule