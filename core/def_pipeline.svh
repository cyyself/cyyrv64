`ifndef DEF_PIPELINE
`define DEF_PIPELINE

`include "def.svh"

typedef struct packed {
    logic       if_valid;
    logic [63:0]pc;
    logic [31:0]instr;
    logic       if_misaligned;
    logic       if_acc_fault;
    logic       if_inst_valid;
} if2id;

typedef struct packed {
    logic       trap_en;
    logic       trap_is_int;
    logic [3:0] cause;
    logic[63:0] tval;
} trap_info;

typedef struct packed {
    logic       id_valid;
    decode_pack pack;
    trap_info   trap;
    rv_priv     priv_mode;
    logic [63:0]pc;
    logic [63:0]rs1;
    logic [63:0]rs2;
    logic [63:0]imm;
} id2exe;

typedef struct packed {
    logic       exe_valid;
    decode_pack pack;
    trap_info   trap;
    logic [63:0]pc;
    logic [63:0]rd_value;
    logic [63:0]rs2_value;
    logic       mem_en;
    logic [63:0]mem_addr;
    logic       ctrl_trans;
    logic [63:0]ctrl_trans_addr;
} exe2mem;

typedef struct packed {
    logic       mem_valid;
    logic       trap_int;
    logic [63:0]pc;
    logic       rd_en;
    logic [63:0]rd_value;
    logic  [4:0]rd;
} mem2wb;

`endif
