`ifndef DEF_COMMON
`define DEF_COMMON

// funct7[-2] or funct6[-2] concat funct3
`define ALU_ADD     4'b0000
`define ALU_SUB     4'b1000
`define ALU_SLL     4'b0001
`define ALU_SLT     4'b0010
`define ALU_SLTU    4'b0011
`define ALU_XOR     4'b0100
`define ALU_SRL     4'b0101
`define ALU_SRA     4'b1101
`define ALU_OR      4'b0110
`define ALU_AND     4'b0111
// custom
`define ALU_IMM     4'b1001
`define ALU_NOP     4'b1111 // not defined in ALU

typedef struct packed {
    logic       mem_read;   // for memory enable and forward logic
    logic       mem_write;  // for result mux at wb stage
    logic [3:0] alu_control;
    logic       alu_32;     // alu sign ext 32
    logic       alu_pc;     // alu port a. 1: pc  0: rs1
    logic       alu_imm;    // alu port b. 1: imm 0: rs2
    logic       rs1_en;     // enable rs1 for forwading control
    logic       rs2_en;     // enable rs2 for forwading control
    logic       rd_en;      // enable rd  for forwading control and enable reg write
    // Note: if rd is 0, then rd_en is set to 0 during ID stage.
    logic       branch;     // for next pc mux
    logic       jump;       // for next pc mux and result mux at mem stage
    logic       jalr;       // select jump adder source from pc or rs1
    logic       reversed;   // reversed instr
} ctrl_sign;

//                    {m_rd m_wr alu_ctrl a32  apc  aimm rs1  rs2   rd   br  jump jalr rev }
`define CTRL_SIGN_NOP {1'd0,1'd0,`ALU_NOP,1'd0,1'd0,1'd0,1'd0,1'd0,1'd0,1'd0,1'd0,1'd0,1'd0}
`define CTRL_SIGN_RI  {1'd0,1'd0,`ALU_NOP,1'd0,1'd0,1'd0,1'd0,1'd0,1'd0,1'd0,1'd0,1'd0,1'd1}

typedef struct packed {
    logic [63:0]    pc;
    logic [31:0]    instr;
} pipe_common; // TODO: IF error signal

`define FUNCT3_IDX  14:12
`define RS1_IDX     19:15
`define RS2_IDX     24:20
`define RD_IDX       11:7

typedef struct packed {
    logic [63:0]    rs1;
    logic [63:0]    rs2;
    logic           valid;
} exe_data_fw;

typedef struct packed {
    logic [63:0]    imm;
    logic [63:0]    reg_rs1;
    logic [63:0]    reg_rs2;
} id2exe;

typedef struct packed {
    logic [63:0]    alu_out;
} exe2mem;

typedef struct packed {
    logic           mem_en;      // exe_fwd.valid & (mem_read | mem_write)
    logic           mem_write;
    logic  [2:0]    funct3;
    logic [63:0]    memaddr;
    logic [63:0]    rs2_data;
} exe2mem_fw;

typedef struct packed {
    logic [63:0]    result;
} mem2exe_fw;

typedef struct packed {
    logic [63:0]    result;
} wb2exe_fw;

typedef struct packed {
    logic           exe_pc_src;
    logic [63:0]    exe_new_pc;
} exe2if_fw;

typedef struct packed {
    logic [63:0]    readdata;
    logic [63:0]    result;     // exe result
} mem2wb;

typedef struct packed {
    logic           rd_en;
    logic  [4:0]    rd;
    logic [63:0]    result;
} wb_reg;

typedef struct packed {
    logic   IF;
    logic   ID;
    logic   EXE;
    logic   MEM;
    logic   WB;
} pipe_ready_s;

typedef struct packed {
    logic   IF;
    logic   ID;
    logic   EXE;
    logic   MEM;
    logic   WB;
} pipe_stall_s;

typedef struct packed {
    logic   IF;
    logic   ID;
    logic   EXE;
    logic   MEM;
    logic   WB;
} pipe_flush_s;

`endif