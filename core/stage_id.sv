`include "def.svh"
`include "def_pipeline.svh"

module stage_id(
    input               clock,
    input               reset,
    input if2id         id_data_from_if,
    input               id_flush,
    input               id_ready,
    output              id_stall,
    gpr_read.master     gpr_if,
    async_irq.slave     irq_if,
    input rv_priv       priv_mode,
    output id2exe       exe_data
);

if2id id_data;
logic id_irq;
logic [3:0] id_irq_type;

always_ff @(posedge clock) begin
    if (reset || id_flush) begin
        id_data <= '{default: 0};
        id_irq <= 0;
        id_irq_type <= 0;
    end
    else begin
        if (!id_stall && id_ready) begin
            if (id_data_from_if.if_valid) begin
                id_data <= id_data_from_if;
                id_irq <= irq_if.irq;
                id_irq_type <= irq_if.irq_type;
            end
            else begin
                id_data <= '{default: 0};
                id_irq <= 0;
                id_irq_type <= 0;
            end
        end
    end
end

wire illegal_instr;

trap_info trap_info_id;

assign trap_info_id.trap_en = id_data.if_valid && 
    (id_data.if_misaligned || id_data.if_acc_fault || illegal_instr || id_irq);
assign trap_info_id.trap_is_int = id_data.if_valid && id_irq;
assign trap_info_id.cause = 
    id_irq                  ? id_irq_type           :
    id_data.if_misaligned   ? EXC_INSTR_MISALIGN    :
    id_data.if_acc_fault    ? EXC_INSTR_ACC_FAULT   :
    illegal_instr           ? EXC_ILLEGAL_INSTR     : 0;
assign trap_info_id.tval  = 
    id_irq                  ? 64'd0         :
    id_data.if_misaligned   ? id_data.pc    :
    id_data.if_acc_fault    ? id_data.pc    :
    illegal_instr           ? 64'd0         : 64'd0;

wire [63:0] imm;
decode_pack pack;

decoder decoder_inst(
    .en             (id_data.if_inst_valid),
    .instr          (id_data.instr),
    .priv_mode      (priv_mode),
    .imm            (imm),
    .pack           (pack),
    .illegal_instr  (illegal_instr)
);

assign gpr_if.rs1_en = pack.rs1_en;
assign gpr_if.rs1    = pack.rs1;
assign gpr_if.rs2_en = pack.rs2_en;
assign gpr_if.rs2    = pack.rs2;
assign id_stall = gpr_if.reg_read_busy;

assign exe_data = '{
    id_valid: !id_stall && id_ready && id_data.if_valid,
    pack: pack,
    trap: trap_info_id,
    priv_mode: priv_mode,
    pc: id_data.pc,
    rs1: gpr_if.rs1_value,
    rs2: gpr_if.rs2_value,
    imm: imm
};

endmodule
