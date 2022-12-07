`include "def.svh"
`include "def_pipeline.svh"

module stage_wb(
    input               clock,
    input               reset,
    input mem2wb        wb_data_from_mem,
    gpr_commit.master   commit,
    debug_bus.master    debug
);

mem2wb wb_data;

always_ff @(posedge clock) begin
    if (reset) begin
        wb_data <= '{default: 0};
    end
    else begin
        if (wb_data_from_mem.mem_valid) wb_data <= wb_data_from_mem;
        else wb_data <= '{default: 0};
    end
end

assign commit.rd_en     = wb_data.rd_en;
assign commit.rd        = wb_data.rd;
assign commit.rd_value  = wb_data.rd_value;

assign debug.commit     = wb_data.mem_valid;
assign debug.pc         = wb_data.pc;
assign debug.reg_num    = {5{wb_data.rd_en}} & wb_data.rd;
assign debug.wdata      = wb_data.rd_value;

endmodule
