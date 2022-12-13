`include "def.svh"
`include "def_pipeline.svh"
`include "def_csr.svh"

module stage_mem(
    input               clock,
    input               reset,
    input exe2mem       me_data_from_ex,
    input               me_flush,
    input               me_ready,
    input               if_stall,
    output              me_stall,
    data_bus.master     d_bus,
    gpr_forward.master  me_forward,
    trap_bus.master     trap_if,
    trap_pc_bus.slave   trap_pc_if,
    output [63:0]       mem_pc,
    output              mem_pc_en,
    output              mem_pc_fence_i,
    output mem2wb       wb_data
);

exe2mem me_data;

always_ff @(posedge clock) begin
    if (reset || me_flush) begin
        me_data <= '{default: 0};
    end
    else begin
        if (!me_stall && me_ready) begin
            if (me_data_from_ex.exe_valid) me_data <= me_data_from_ex;
            else me_data <= '{default: 0};
        end
    end
end

assign me_stall = (me_data.mem_en && !d_bus.valid) || if_stall;

wire [63:0] load_result;

// d_bus {
dbus_data_to_reg dbus_data_to_reg_inst(
    .raddr  (me_data.mem_addr[2:0]),
    .waddr  (me_data_from_ex.mem_addr[2:0]),
    .rdata  (d_bus.rdata),
    .wdata  (d_bus.wdata),
    .rsize  (me_data.pack.mem_size),
    .wsize  (me_data_from_ex.pack.mem_size),
    .ruext  (me_data.pack.mem_load_uext),
    .reg_in (me_data_from_ex.rs2_value),
    .reg_out(load_result)
);


assign d_bus.en     = me_data_from_ex.mem_en && !me_stall && me_ready && !me_flush && me_data_from_ex.exe_valid;
assign d_bus.addr   = me_data_from_ex.mem_addr;
assign d_bus.size   = me_data_from_ex.pack.mem_size;
assign d_bus.write  = me_data_from_ex.pack.mem_write;
assign d_bus.fence_i= me_data_from_ex.pack.fence_i;
assign d_bus.ready  = (me_ready && !if_stall) || me_flush;
// d_bus }

// exception {
trap_info trap_info_mem_new;
assign trap_info_mem_new.trap_en = d_bus.acc_err;
assign trap_info_mem_new.trap_is_int = 0;
assign trap_info_mem_new.cause = me_data.pack.mem_write ? EXC_STORE_ACC_FAULT : EXC_LOAD_ACC_FAULT;
assign trap_info_mem_new.tval  = me_data.mem_addr;
trap_info trap_info_mem;
assign trap_info_mem = me_data.trap.trap_en ? me_data.trap : trap_info_mem_new;

assign trap_if.trap_en = trap_info_mem.trap_en && !me_stall && me_ready;
assign trap_if.mret_en = me_data.pack.mret && !me_stall && me_ready;
assign trap_if.pc = me_data.pc;
assign trap_if.cause = {trap_info_mem.trap_is_int,59'd0,trap_info_mem.cause};
assign trap_if.tval = trap_info_mem.tval;
// exception }

// mem pc to pc_gen {
assign mem_pc = trap_pc_if.trap_en ? trap_pc_if.trap_pc : me_data.ctrl_trans_addr;
assign mem_pc_en = !me_stall && (trap_pc_if.trap_en || me_data.ctrl_trans);
assign mem_pc_fence_i = !trap_pc_if.trap_en && me_data.pack.fence_i;
// mem pc to pc_gen }

// mem_gpr {
wire [63:0] mem_rd_value = me_data.pack.mem_en ? load_result : me_data.rd_value;
wire        mem_rd_en = me_data.pack.rd_en & !trap_info_mem.trap_en;

assign me_forward.rd_en = me_data.pack.rd_en; // don't care about 
assign me_forward.rd_forward = me_data.pack.rd_forward_mem;
assign me_forward.rd = me_data.pack.rd;
assign me_forward.rd_value = mem_rd_value;
// mem_gpr }

assign wb_data = '{
    mem_valid: !me_stall && me_ready && me_data.exe_valid,
    trap_int: trap_info_mem.trap_is_int,
    pc: me_data.pc,
    rd_en: mem_rd_en,
    rd_value: mem_rd_value,
    rd: me_data.pack.rd
};

endmodule
