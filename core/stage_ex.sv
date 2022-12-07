`include "def_pipeline.svh"
`include "def_csr.svh"

module stage_ex(
    input               clock,
    input               reset,
    input id2exe        ex_data_from_id,
    input               ex_flush,
    input               ex_ready,
    output              ex_stall,
    gpr_forward.master  ex_forward,
    csr_bus.master      csr_if,
    output exe2mem      mem_data
);

id2exe ex_data;

always_ff @(posedge clock) begin
    if (reset || ex_flush) begin
        ex_data <= '{default: 0};
    end
    else begin
        if (!ex_stall && ex_ready) begin
            if (ex_data_from_id.id_valid) ex_data <= ex_data_from_id;
            else ex_data <= '{default: 0};
        end
    end
end

// alu {
wire [63:0] alu_in1 = ex_data.pack.alu_in1_use_pc   ? ex_data.pc    : ex_data.rs1;
wire [63:0] alu_in2 = ex_data.pack.alu_in2_use_imm  ? ex_data.imm   : ex_data.rs2;
wire [63:0] alu_out;

alu alu_inst(
    .in1    (alu_in1),
    .in2    (alu_in2),
    .is_word(ex_data.pack.op_32),
    .op     (ex_data.pack.alu_opt),
    .out    (alu_out)
);
// alu }

// mul {
wire [63:0] mul_out;
wire mul_valid;
wire mul_stall = ex_data.pack.mul_en && !mul_valid;
mul mul_inst(
    .clock      (clock),
    .reset      (reset | ex_flush),
    .in1        (ex_data.rs1),
    .in2        (ex_data.rs2),
    .mul_word   (ex_data.pack.op_32),
    .en         (ex_data.pack.mul_en),
    .op         (ex_data.pack.mul_opt),
    .out        (mul_out),
    .out_valid  (mul_valid),
    .out_ready  (ex_ready)
);
// mul }

// div {
wire [63:0] div_out;
wire div_valid;
wire div_stall = ex_data.pack.div_en && !div_valid;
div div_inst(
    .clock      (clock),
    .reset      (reset | ex_flush),
    .in1        (ex_data.rs1),
    .in2        (ex_data.rs2),
    .div_word   (ex_data.pack.op_32),
    .en         (ex_data.pack.div_en),
    .op         (ex_data.pack.div_opt),
    .out        (div_out),
    .out_valid  (div_valid),
    .out_ready  (ex_ready)
);
// div }

// op result and forward {
assign ex_stall = mul_stall || div_stall;
wire [63:0] op_result = 
    ex_data.pack.mul_en ? mul_out : 
    ex_data.pack.div_en ? div_out : alu_out;

assign ex_forward.rd_en = ex_data.pack.rd_en;
assign ex_forward.rd_forward = ex_data.pack.rd_forward_exe;
assign ex_forward.rd = ex_data.pack.rd;
assign ex_forward.rd_value = op_result;


// op result and forward }

// branch & jump {
wire branch_taken;
bru bru_inst(
    .in1        (ex_data.rs1),
    .in2        (ex_data.rs2),
    .op         (ex_data.pack.br_opt),
    .is_taken   (branch_taken)
);

wire [63:0] branch_jal_addr = ex_data.pc + ex_data.imm;
wire [63:0] jalr_addr = ex_data.rs1 + ex_data.imm;

wire ex_ctrl_trans = (ex_data.pack.br_en && branch_taken) || ex_data.pack.jump || ex_data.pack.flush_pipe;
wire [63:0] ex_ctrl_trans_addr = 
    ex_data.pack.flush_pipe ? ex_data.pc + 4 : 
    ((ex_data.pack.br_en && branch_taken) || !ex_data.pack.rs1_en) ? branch_jal_addr : jalr_addr;
wire ex_ctrl_trans_misaligned = (|ex_ctrl_trans_addr[1:0]) && ex_ctrl_trans;
// branch & jump }

// memory access {
wire [63:0] memory_addr = ex_data.rs1 + ex_data.imm;
wire memory_addr_misaligned = 
    ex_data.pack.mem_size == 1 ?  memory_addr[0]     :
    ex_data.pack.mem_size == 2 ? |memory_addr[1:0]   :
    ex_data.pack.mem_size == 3 ? |memory_addr[2:0]   : 1'b0;
wire memory_en = ex_data.pack.mem_en && !memory_addr_misaligned;
// memory access }

// csr {
assign csr_if.csr_en = ex_data.pack.csr_en && ex_ready && !ex_flush;
assign csr_if.op = ex_data.pack.csr_opt;
assign csr_if.csr_addr = ex_data.imm[11:0];
assign csr_if.wdata = ex_data.pack.csr_rs1_as_imm ? {59'd0,ex_data.pack.rs1} : ex_data.rs1;
// csr }

// generate rd (Note: ex forward comes from op_result)
wire [63:0] ex_rd_value = 
    csr_if.csr_en       ? csr_if.rdata : 
    ex_data.pack.jump   ? ex_data.pc + 4 : op_result;
    

// exceptions {
wire memory_misaligned_trap = ex_data.pack.mem_en && memory_addr_misaligned;
wire csr_trap = ex_data.pack.csr_en && csr_if.trap_ill;

trap_info trap_info_ex_new;
assign trap_info_ex_new.trap_en = memory_misaligned_trap || csr_trap;
assign trap_info_ex_new.trap_is_int = 0;
// TODO: ecall, ebreak
assign trap_info_ex_new.cause = 
    ({4{memory_misaligned_trap}}    & (ex_data.pack.mem_write ? EXC_STORE_MISALIGN : EXC_LOAD_MISALIGNED) ) |
    ({4{ex_ctrl_trans_misaligned}}  & EXC_INSTR_MISALIGN ) |
    ({4{ex_data.pack.ebreak}})      & EXC_BREAKPOINT       |
    ({4{ex_data.pack.ecall}})       & (ex_data.priv_mode == USER_MODE ? EXC_ECALL_FROM_USER : EXC_ECALL_FROM_MACHINE) | 
    ({4{csr_trap}}                  & EXC_ILLEGAL_INSTR);
assign trap_info_ex_new.tval  = 
    ({64{memory_misaligned_trap}}   & memory_addr ) |
    ({64{ex_ctrl_trans_misaligned}} & ex_ctrl_trans_addr );

trap_info trap_info_ex = ex_data.trap.trap_en ? ex_data.trap : trap_info_ex_new;
// exceptions }

assign mem_data = '{
    exe_valid: !ex_stall && ex_ready && ex_data.id_valid,
    pack: ex_data.pack,
    trap: trap_info_ex,
    pc: ex_data.pc,
    rd_value: ex_rd_value,
    rs2_value: ex_data.rs2,
    mem_en: memory_en,
    mem_addr: memory_addr,
    ctrl_trans: ex_ctrl_trans,
    ctrl_trans_addr: ex_ctrl_trans_addr
};

endmodule
