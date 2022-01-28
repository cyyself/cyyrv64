`include "def_common.vh"

module forward_ctrl(
    input               clk,
    input               rst,
    input               exe_ready,
    input               exe_flush,
    input  id2exe       exe_in, 
    input  [63:0]       mem_result,
    input  [63:0]       wb_result,
    input  pipe_common  exe_pipe,
    input  pipe_common  mem_pipe,
    input  pipe_common  wb_pipe,
    input  ctrl_sign    exe_ctrl,
    input  ctrl_sign    mem_ctrl,
    input  ctrl_sign    wb_ctrl,
    output exe_data_fw  out
);

logic exe_rs1_en    = exe_ctrl.rs1_en;
logic exe_rs2_en    = exe_ctrl.rs2_en;
logic mem_rd_en     = mem_ctrl.rd_en;
logic wb_rd_en      = wb_ctrl.rd_en;

logic [4:0] exe_rs1 = exe_pipe.instr[`RS1_IDX];
logic [4:0] exe_rs2 = exe_pipe.instr[`RS2_IDX];
logic [4:0] mem_rd  = mem_pipe.instr[`RD_IDX];
logic [4:0] wb_rd   = wb_pipe.instr[`RD_IDX];

logic rs1_mem       = exe_rs1_en && mem_rd_en && exe_rs1 == mem_rd;
logic rs2_mem       = exe_rs2_en && mem_rd_en && exe_rs2 == mem_rd;
logic rs1_wb        = exe_rs1_en &&  wb_rd_en && exe_rs1 ==  wb_rd;
logic rs2_wb        = exe_rs2_en &&  wb_rd_en && exe_rs2 ==  wb_rd;

// should not forward during memory reading
logic tmp_rs1_valid = !(exe_rs1_en && mem_rd_en && exe_rs1 == mem_rd && mem_ctrl.mem_read);
logic tmp_rs2_valid = !(exe_rs2_en && mem_rd_en && exe_rs1 == mem_rd && mem_ctrl.mem_read);
logic tmp_valid     = tmp_rs1_valid & tmp_rs2_valid;

logic [63:0] tmp_rs1    = 
    rs1_mem ? mem_result :
    rs1_wb  ? wb_result  :
    exe_in.reg_rs1;

logic [63:0] tmp_rs2    = 
    rs2_mem ? mem_result :
    rs2_wb  ? wb_result  :
    exe_in.reg_rs2;

// reserve station
logic reserve_flag          = 0;
logic [63:0] reserve_rs1    = 0;
logic [63:0] reserve_rs2    = 0;

always_ff @(posedge clk) begin
    if (rst | exe_ready | exe_flush) begin
        reserve_flag <= 0;
        reserve_rs1  <= 0;
        reserve_rs2  <= 0;
    end
    else if (tmp_valid)  begin // !exe_ready & tmp_valid means some module in exe stage didn't finished
        reserve_flag <= 1;
        reserve_rs1  <= tmp_rs1;
        reserve_rs2  <= tmp_rs2;
    end
end

assign out.valid = reserve_flag | tmp_valid;
assign out.rs1   = reserve_flag ? reserve_rs1 : tmp_rs1;
assign out.rs2   = reserve_flag ? reserve_rs2 : tmp_rs2;

endmodule