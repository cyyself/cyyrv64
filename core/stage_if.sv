`include "def.svh"
`include "def_pipeline.svh"

module stage_if(
    input               clock,
    input               reset,
    input  [63:0]       next_pc,
    input               pc_en,
    input               next_fence_i,
    output              if_stall,
    input               if_ready,
    output logic [63:0] if_pc,
    inst_bus.master     i_bus,
    output if2id        id_data
);

assign i_bus.addr   = next_pc;
assign i_bus.en     = pc_en;
assign i_bus.ready  = if_ready;
assign i_bus.fence_i= next_fence_i;

reg if_en;

assign if_stall = if_en && !i_bus.valid;

wire if_valid = if_en && i_bus.valid && !if_stall && if_ready;
wire if_misaligned = |if_pc[1:0];
wire if_acc_fault = i_bus.acc_err;
assign id_data.if_valid = if_valid;
assign id_data.pc       = if_pc;
assign id_data.instr    = i_bus.rdata;
assign id_data.if_misaligned = if_misaligned;
assign id_data.if_acc_fault = if_acc_fault;
assign id_data.if_inst_valid = if_valid && !if_misaligned && !if_acc_fault;

always_ff @(posedge clock) begin
    if (reset) begin
        if_en <= 0;
        if_pc <= 0;
    end
    else begin
        if (!if_stall && if_ready) begin
            if_en <= pc_en;
            if_pc <= next_pc;
        end
    end
end

endmodule
