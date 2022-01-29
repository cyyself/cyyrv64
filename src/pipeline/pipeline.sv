`include "def_common.vh"
module pipeline(
    input   clk,
    input   rst
);

// stall forward
pipe_ready_s    pipe_ready;
pipe_stall_s    pipe_stall;
pipe_flush_s    pipe_flush;

// forward signal
exe_data_fw exe_data;
exe2if_fw   exe_if_fw;
mem2exe_fw  mem_exe_fw;
wb2exe_fw   wb_exe_fw;
wb_reg      wb_id_fw;
exe2mem_fw  exe_mem_fw;

// pipeline signal
pipe_common     if_pipe;
pipe_common     id_pipe;
pipe_common     exe_pipe;
pipe_common     mem_pipe;
pipe_common     wb_pipe;
ctrl_sign       id_ctrl;
ctrl_sign       exe_ctrl;
ctrl_sign       mem_ctrl;
ctrl_sign       wb_ctrl;
id2exe          id2exe_id;
id2exe          id2exe_exe;
exe2mem         exe2mem_exe;
exe2mem         exe2mem_mem;
mem2wb          mem2wb_mem;
mem2wb          mem2wb_wb;

// flip-flops
ff #(.WIDTH($bits(if_pipe))) if2id_ff(
    .clk        (clk),
    .rst        (rst),
    .flush      (pipe_flush.ID),
    .stall      (pipe_stall.ID),
    .data_in    (if_pipe),
    .data_out   (id_pipe)
);
ff #(.WIDTH($bits({id_pipe,id_ctrl,id2exe_id}))) id2exe_ff(
    .clk        (clk),
    .rst        (rst),
    .flush      (pipe_flush.EXE),
    .stall      (pipe_stall.EXE),
    .data_in    ({ id_pipe, id_ctrl,id2exe_id }),
    .data_out   ({exe_pipe,exe_ctrl,id2exe_exe})
);
ff #(.WIDTH($bits({exe_pipe,exe_ctrl,exe2mem_exe}))) exe2mem_ff(
    .clk        (clk),
    .rst        (rst),
    .flush      (pipe_flush.MEM),
    .stall      (pipe_stall.MEM),
    .data_in    ({exe_pipe,exe_ctrl,exe2mem_exe}),
    .data_out   ({mem_pipe,mem_ctrl,exe2mem_mem})
);
ff #(.WIDTH($bits({mem_pipe,mem_ctrl,mem2wb_mem}))) mem2wb_ff(
    .clk        (clk),
    .rst        (rst),
    .flush      (pipe_flush.WB),
    .stall      (pipe_stall.WB),
    .data_in    ({mem_pipe,mem_ctrl,mem2wb_mem}),
    .data_out   ({ wb_pipe, wb_ctrl,mem2wb_wb })
);

// helper modules
forward_ctrl forward_ctrl(
    .clk        (clk),
    .rst        (rst),
    .exe_ready  (pipe_ready.EXE),
    .exe_flush  (pipe_flush.EXE),
    .exe_in     (id2exe_exe),
    .mem_result (mem_exe_fw.result),
    .wb_result  (wb_exe_fw.result),
    .exe_pipe   (exe_pipe),
    .mem_pipe   (mem_pipe),
    .wb_pipe    (wb_pipe),
    .exe_ctrl   (exe_ctrl),
    .mem_ctrl   (mem_ctrl),
    .wb_ctrl    (wb_ctrl),
    .out        (exe_data)
);

// Note: regfile was placed in the ID stage.


// each stage
stage_if stage_if(
    .clk        (clk),
    .rst        (rst),
    .if_stall   (pipe_stall.IF),
    .if_flush   (pipe_flush.IF),
    .if_ready   (pipe_ready.IF),
    .exe_if_fw  (exe_if_fw),
    .if_out     (if_pipe)
);

stage_id stage_id(
    .clk        (clk),
    .rst        (rst),
    .id_flush   (pipe_flush.ID),
    .id_ready   (pipe_ready.ID),
    .id_pipe    (id_pipe),
    .id_ctrl    (id_ctrl),
    .id_out     (id2exe_id),
    .wb_id_fw   (wb_id_fw)
);

stage_exe stage_exe(
    .clk        (clk),
    .rst        (rst),
    .exe_flush  (pipe_flush.EXE),
    .exe_ready  (pipe_ready.EXE),
    .exe_pipe   (exe_pipe),
    .exe_ctrl   (exe_ctrl),
    .exe_data   (exe_data),
    .exe_in     (id2exe_exe),
    .exe_out    (exe2mem_exe),
    .exe_if     (exe_if_fw),
    .exe_mem_fw (exe_mem_fw)
);

stage_mem stage_mem(
    .clk        (clk),
    .rst        (rst),
    .mem_flush  (pipe_flush.MEM),
    .mem_ready  (pipe_ready.MEM),
    .mem_ctrl   (mem_ctrl),
    .mem_pipe   (mem_pipe),
    .mem_in     (exe2mem_mem),
    .mem_out    (mem2wb_mem),
    .exe_mem_fw (exe_mem_fw),
    .mem_exe_fw (mem_exe_fw)
);

stage_wb stage_wb(
    .clk        (clk),
    .rst        (rst),
    .wb_flush   (pipe_flush.WB),
    .wb_ready   (pipe_ready.WB),
    .wb_ctrl    (wb_ctrl),
    .wb_pipe    (wb_pipe),
    .wb_in      (mem2wb_wb),
    .wb_out     (wb_id_fw),
    .wb_exe_fw  (wb_exe_fw)
);

// pipeline controller
wire ctrl_trans_flush = exe_if_fw.exe_pc_src;

assign pipe_flush.IF    = 1'b0;
assign pipe_flush.ID    = (pipe_stall.IF && !pipe_stall.ID ) || ctrl_trans_flush;
assign pipe_flush.EXE   = (pipe_stall.ID && !pipe_stall.EXE) || ctrl_trans_flush;
assign pipe_flush.MEM   = (pipe_stall.EXE && !pipe_stall.MEM);
assign pipe_flush.WB    = (pipe_stall.MEM && !pipe_stall.WB);

assign pipe_stall.WB    = !pipe_ready.WB;
assign pipe_stall.MEM   = pipe_stall.WB  || !pipe_ready.MEM;
assign pipe_stall.EXE   = pipe_stall.MEM || !pipe_ready.EXE;
assign pipe_stall.ID    = pipe_stall.EXE || !pipe_ready.ID;
assign pipe_stall.IF    = pipe_stall.ID  || !pipe_ready.IF;

endmodule