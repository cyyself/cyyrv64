`ifndef DEF_SVH
`define DEF_SVH

typedef enum {
    ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
} alu_op;

typedef enum {
    BEQ, BNE, BLT, BGE, BLTU, BGEU
} branch_op;

typedef enum {
    MUL, MULH, MULHU, MULHSU
} mul_op;

typedef enum {
    DIV, DIVU, REM, REMU
} div_op;

typedef enum {
    AMOSWAP, AMOADD, AMOXOR, AMOAND, AMOOR, AMOMIN, AMOMAX, AMOMINU, AMOMAXU, LR, SC
} amo_op;

typedef enum {
    CSR_READ, CSR_WRITE, CSR_SETBIT, CSR_CLEARBIT
} csr_op; // read only instruction should be handled in decoder

typedef struct packed {
    // reg forward
    logic       rs1_en;
    logic [4:0] rs1;
    logic       rs2_en;
    logic [4:0] rs2;
    logic       rd_en;
    logic [4:0] rd;
    logic       rd_forward_exe; // allow rd forward from exe
    logic       rd_forward_mem; // allow rd forward from mem
    // alu mul div
    alu_op      alu_opt;
    logic       alu_in1_use_pc; // 0: rs1, 1: pc
    logic       alu_in2_use_imm;// 0: rs2, 1: imm
    logic       op_32;
    mul_op      mul_opt;
    logic       mul_en;
    div_op      div_opt;
    logic       div_en;
    // memory access
    logic       mem_en;
    logic       mem_write;
    logic       mem_load_uext;
    logic [1:0] mem_size;        // 0: 1Bytes, 1: 2Bytes, 2: 4Bytes, 3: 8Bytes
    logic       amo_en;
    amo_op      amo_opt;
    // branch jump
    logic       br_en;
    branch_op   br_opt;
    logic       jump;           // jal or jalr is determined by rs1_en
    // csr
    logic       csr_en;
    csr_op      csr_opt;
    logic       csr_rs1_as_imm; // 0: wdata=regfile[rs1], 1: wdata=rs1
    // misc
    logic       flush_pipe;
    logic       fence_i;
    logic       mret;
    logic       ecall;
    logic       ebreak;
} decode_pack;

typedef struct packed {
    logic MEI; // PLIC,  Machine External Interrupt
    logic MSI; // CLINT, Machine Software Interrupt
    logic MTI; // CLINT, Machine Timer Interrupt
} hart_int;

typedef enum logic [1:0] {
    MACHINE_MODE = 3,
    USER_MODE = 0
} rv_priv;

typedef enum logic [3:0] {
    EXC_INSTR_MISALIGN  = 0,
    EXC_INSTR_ACC_FAULT = 1,
    EXC_ILLEGAL_INSTR   = 2,
    EXC_BREAKPOINT      = 3,
    EXC_LOAD_MISALIGNED = 4,
    EXC_LOAD_ACC_FAULT  = 5,
    EXC_STORE_MISALIGN  = 6,    // including amo
    EXC_STORE_ACC_FAULT = 7,    // including amo
    EXC_ECALL_FROM_USER = 8,
    EXC_ECALL_FROM_MACHINE      = 11
} exc_code;

typedef enum logic [3:0] {
    INT_MSI = 3,    // Machine Software
    INT_MTI = 7,    // Machine Timer
    INT_MEI = 11    // Machine External
} int_code;

interface inst_bus;
    logic [63:0]    addr;   // note: The addr must be 4-bytes aligned. If RVC needs implemented, you should add a buffer after inst_bus.
    logic           en;     // note: The address handshake can only be done when en & rvalid & rready, or else you should keep en high.
    logic [31:0]    rdata;  // note: If you need to implement a super-scalar processor that fetches multiple instructions in a single cycle, you can expand this signal. But keep in mind cacheline boundary and page boundary.
    logic           valid;  // tell the core this transfer is done or not busy
    logic           ready;  // tell the cache this transfer is done
    logic           fence_i;// invalidate i cache
    logic           acc_err;// access fault
    // Note: You should change the ibus if virtual memory needed.
    modport slave (input  addr, en, ready, fence_i, output rdata, valid, acc_err);
    modport master(output addr, en, ready, fence_i, acc_err, input  rdata, valid);
endinterface

interface data_bus;
    logic [63:0]    addr;
    logic [1:0]     size; // 0: 1B, 1: 2B, 2: 4B, 3: 8B
    logic           en;
    logic           write;
`ifdef ENABLE_AMO
    logic           amo_32;
    logic           amo_en;
    amo_op          amo_type;
`endif
    logic [63:0]    rdata;
    logic [63:0]    wdata;
    logic           valid;  // tell the core this transfer is done or not busy
    logic           ready;  // tell the cache this transfer is done
    logic           fence_i;// write back all dcache. (Note: fence_i can only asserted when en is 0.)
    logic           acc_err;// access fault
`ifdef ENABLE_AMO
    modport slave (input  addr, size, en, write, amo_32, amo_en, amo_type, wdata, ready, fence_i, output rdata, valid, acc_err);
    modport master(output addr, size, en, write, amo_32, amo_en, amo_type, wdata, ready, fence_i, acc_err, input  rdata, valid);    
`else
    modport slave (input  addr, size, en, write, wdata, ready, fence_i, output rdata, valid, acc_err);
    modport master(output addr, size, en, write, wdata, ready, fence_i, acc_err, input  rdata, valid);    
`endif
endinterface

interface trap_bus;
    logic           trap_en;
    logic           mret_en;
    logic [63:0]    pc;
    logic [63:0]    cause;
    logic [63:0]    tval;
    modport master(output trap_en, mret_en, pc, cause, tval);
    modport slave (input trap_en, mret_en, pc, cause, tval);
endinterface

interface trap_pc_bus;
    logic           trap_en;
    logic [63:0]    trap_pc;
    modport master(output trap_en, trap_pc);
    modport slave (input trap_en, trap_pc);
endinterface

interface async_irq;
    logic           irq;
    logic [3:0]     irq_type;
    modport master(output irq, irq_type);
    modport slave (input irq, irq_type);
endinterface

interface debug_bus;
    logic           commit;
    logic [63:0]    pc;
    logic [4:0]     reg_num;
    logic [63:0]    wdata;
    modport master(output commit, pc, reg_num, wdata);
    modport slave (input  commit, pc, reg_num, wdata);
endinterface

interface gpr_read;
    logic [4:0]     rs1;
    logic           rs1_en;
    logic [63:0]    rs1_value;
    logic [4:0]     rs2;
    logic           rs2_en;
    logic [63:0]    rs2_value;
    logic           reg_read_busy;
    modport master(output rs1, rs1_en, rs2, rs2_en, input rs1_value, rs2_value, reg_read_busy);
    modport slave(input rs1, rs1_en, rs2, rs2_en, output rs1_value, rs2_value, reg_read_busy);
endinterface

interface gpr_forward;
    logic           rd_en;
    logic           rd_forward;
    logic [4:0]     rd;
    logic [63:0]    rd_value;
    modport master(output rd_en, rd_forward, rd, rd_value);
    modport slave(input rd_en, rd_forward, rd, rd_value);
endinterface

interface gpr_commit;
    logic           rd_en;
    logic [4:0]     rd;
    logic [63:0]    rd_value;
    modport master(output rd_en, rd, rd_value);
    modport slave(input rd_en, rd, rd_value);
endinterface

`endif
