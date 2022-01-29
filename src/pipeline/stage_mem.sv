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
    output mem2exe_fw   mem_exe_fw
);

assign mem_out.result   = mem_ctrl.jump ? (mem_pipe.pc + 4) : mem_in.alu_out;
assign mem_exe_fw.result = mem_out.result;

wire  [7:0] sram_wea;
wire [63:0] sram_dina;
wire [63:0] sram_douta;

sram64_trans sram64_trans(
    .funct3     (exe_mem_fw.funct3),
    .writedata  (exe_mem_fw.rs2_data),
    .readdata   (mem_out.readdata),
    .memaddr    (exe_mem_fw.memaddr),
    .mem_write  (exe_mem_fw.mem_write),
    .sram_wea   (sram_wea),
    .sram_dina  (sram_dina),
    .sram_douta (sram_douta)
);

sram #(
    .LEN_ADDR(64),
    .LEN_DATA(64),
    .DEPTH(1024)
) sram (
    .addra  (exe_mem_fw.memaddr),
    .clka   (clk),
    .dina   (sram_dina),
    .douta  (sram_douta),
    .ena    (exe_mem_fw.mem_en),
    .wea    (sram_wea)
);

assign mem_ready = 1'b1;

endmodule