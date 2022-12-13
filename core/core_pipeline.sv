`include "def.svh"
`include "def_pipeline.svh"
`include "def_csr.svh"

module core_pipeline(
    input               clock,
    input               reset,
    input  hart_int     ext_int,
    inst_bus.master     i_bus,
    data_bus.master     d_bus,
    debug_bus.master    debug
);

// ctrl trans
wire [63:0] mem_pc;
wire        mem_pc_en;

// pipeline control
wire if_stall;
wire id_stall;
wire ex_stall;
wire me_stall;

wire id_flush = mem_pc_en;
wire ex_flush = mem_pc_en;
wire me_flush = mem_pc_en;

wire id_stall_real = id_stall && !id_flush;
wire ex_stall_real = ex_stall && !ex_flush;

wire if_ready = !id_stall_real && !ex_stall_real && !me_stall;
wire id_ready = !ex_stall_real && !me_stall;
wire ex_ready = !me_stall;
wire me_ready = 1'b1;

// GPR
gpr_forward ex_forward;
gpr_forward me_forward;
gpr_commit  wb_commit;
gpr_read gpr_if;

regfile regfile_inst(
    .clock  (clock),
    .reset  (reset),
    .gpr_if (gpr_if),
    .ex     (ex_forward),
    .me     (me_forward),
    .wb     (wb_commit)
);

// CSR
csr_bus csr_if;
trap_bus trap_if;
trap_pc_bus trap_pc_if;
rv_priv priv_mode;
async_irq   irq_if;

csr csr_inst(
    .clock          (clock),
    .reset          (reset),
    .ext_int        (ext_int),
    .ready_instret  (debug.commit),
    .cur_priv_mode  (priv_mode),
    .trap_if        (trap_if),
    .csr_if         (csr_if),
    .trap_pc_if     (trap_pc_if),
    .async_irq_if   (irq_if)
);

// stage: Instruction Fetch

wire [63:0] if_pc;
wire [63:0] pc_next;

pc_gen_stage pc_gen_inst(
    .clock      (clock),
    .reset      (reset),
    .if_pc      (if_pc),
    .mem_pc     (mem_pc),
    .mem_pc_en  (mem_pc_en),
    .pc_next    (pc_next)
);

wire if_pc_en = !if_stall && if_ready;
wire if_fence_i;
if2id       id_data;

stage_if stage_if_inst(
    .clock          (clock),
    .reset          (reset),
    .next_pc        (pc_next),
    .pc_en          (if_pc_en),
    .next_fence_i   (if_fence_i),
    .if_stall       (if_stall),
    .if_ready       (if_ready),
    .if_pc          (if_pc),
    .i_bus          (i_bus),
    .id_data        (id_data)
);

// stage: Instruction Decode

wire id_stall;
wire id_flush = if_stall || !if_ready;
id2exe exe_data;

stage_id stage_id_inst(
    .clock          (clock),
    .reset          (reset),
    .id_data_from_if(id_data),
    .id_flush       (id_flush),
    .id_ready       (id_ready),
    .id_stall       (id_stall),
    .gpr_if         (gpr_if),
    .irq_if         (irq_if),
    .priv_mode      (priv_mode),
    .exe_data       (exe_data)
);

// stage: Execute

exe2mem mem_data;

stage_ex stage_ex_inst(
    .clock          (clock),
    .reset          (reset),
    .ex_data_from_id(exe_data),
    .ex_flush       (ex_flush),
    .ex_ready       (ex_ready),
    .ex_stall       (ex_stall),
    .ex_forward     (ex_forward),
    .csr_if         (csr_if),
    .mem_data       (mem_data)
);

// stage: Memory

mem2wb wb_data;

stage_mem stage_mem_inst(
    .clock          (clock),
    .reset          (reset),
    .me_data_from_ex(mem_data),
    .me_flush       (me_flush),
    .me_ready       (me_ready),
    .if_stall       (if_stall),
    .me_stall       (me_stall),
    .d_bus          (d_bus),
    .me_forward     (me_forward),
    .trap_if        (trap_if),
    .trap_pc_if     (trap_pc_if),
    .mem_pc         (mem_pc),
    .mem_pc_en      (mem_pc_en),
    .mem_pc_fence_i (if_fence_i),
    .wb_data        (wb_data)
);

// stage: Write Back

stage_wb stage_wb_inst(
    .clock              (clock),
    .reset              (reset),
    .wb_data_from_mem   (wb_data),
    .commit             (wb_commit),
    .debug              (debug)
);

endmodule
