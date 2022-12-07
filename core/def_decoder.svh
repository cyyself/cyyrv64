`ifndef DECODER_DEF
`define DECODER_DEF

typedef enum logic [6:0] {
    OPCODE_LUI      = 7'b0110111,
    OPCODE_AUIPC    = 7'b0010111,
    OPCODE_JAL      = 7'b1101111,
    OPCODE_JALR     = 7'b1100111,
    OPCODE_BRANCH   = 7'b1100011,
    OPCODE_LOAD     = 7'b0000011,
    OPCODE_STORE    = 7'b0100011,
    OPCODE_OPIMM    = 7'b0010011,
    OPCODE_OPIMM32  = 7'b0011011,
    OPCODE_OP       = 7'b0110011,
    OPCODE_OP32     = 7'b0111011,
    OPCODE_FENCE    = 7'b0001111,
    OPCODE_SYSTEM   = 7'b1110011,
    OPCODE_AMO      = 7'b0101111
} rv64i_opcode;

typedef enum logic [2:0] {
    FUNCT3_BEQ  = 3'b000,
    FUNCT3_BNE  = 3'b001,
    FUNCT3_BLT  = 3'b100,
    FUNCT3_BGE  = 3'b101,
    FUNCT3_BLTU = 3'b110,
    FUNCT3_BGEU = 3'b111
} funct3_branch;

typedef enum logic [2:0] {
    FUNCT3_LB   = 3'b000,
    FUNCT3_LH   = 3'b001,
    FUNCT3_LW   = 3'b010,
    FUNCT3_LD   = 3'b011,
    FUNCT3_LBU  = 3'b100,
    FUNCT3_LHU  = 3'b101,
    FUNCT3_LWU  = 3'b110
} funct3_load;

typedef enum logic [2:0] {
    FUNCT3_SB   = 3'b000,
    FUNCT3_SH   = 3'b001,
    FUNCT3_SW   = 3'b010,
    FUNCT3_SD   = 3'b011
} funct3_store;

typedef enum logic [2:0] {
    FUNCT3_ADD_SUB  = 3'b000,
    FUNCT3_SLL      = 3'b001,
    FUNCT3_SLT      = 3'b010,
    FUNCT3_SLTU     = 3'b011,
    FUNCT3_XOR      = 3'b100,
    FUNCT3_SRL_SRA  = 3'b101,
    FUNCT3_OR       = 3'b110,
    FUNCT3_AND      = 3'b111
} funct3_op;

typedef enum logic [2:0] {
    FUNCT3_MUL      = 3'b000,
    FUNCT3_MULH     = 3'b001,
    FUNCT3_MULHSU   = 3'b010,
    FUNCT3_MULHU    = 3'b011,
    FUNCT3_DIV      = 3'b100,
    FUNCT3_DIVU     = 3'b101,
    FUNCT3_REM      = 3'b110,
    FUNCT3_REMU     = 3'b111
} funct3_m;

typedef enum logic [2:0] {
    FUNCT3_PRIV     = 3'b000,
    FUNCT3_CSRRW    = 3'b001,
    FUNCT3_CSRRS    = 3'b010,
    FUNCT3_CSRRC    = 3'b011,
    FUNCT3_HLSV     = 3'b100,
    FUNCT3_CSRRWI   = 3'b101,
    FUNCT3_CSRRSI   = 3'b110,
    FUNCT3_CSRRCI   = 3'b111
} funct3_system;

typedef enum logic [2:0] {
    FUNCT3_FENCE    = 3'b000,
    FUNCT3_FENCE_I  = 3'b001
} funct3_fence;

typedef enum logic [6:0] {
    FUNCT7_ECALL_EBREAK = 7'b0000000,
    FUNCT7_SRET_WFI     = 7'b0001000,
    FUNCT7_MRET         = 7'b0011000
} funct7_priv;

typedef enum logic [6:0] {
    FUNCT7_NORMAL   = 7'b0000000,
    FUNCT7_SUB_SRA  = 7'b0100000,
    FUNCT7_MUL      = 7'b0000001
} funct7_op;

typedef enum logic [4:0] {
    FUNCT5_AMOLR    = 5'b00010,
    FUNCT5_AMOSC    = 5'b00011,
    FUNCT5_AMOSWAP  = 5'b00001,
    FUNCT5_AMOADD   = 5'b00000,
    FUNCT5_AMOXOR   = 5'b00100,
    FUNCT5_AMOAND   = 5'b01100,
    FUNCT5_AMOOR    = 5'b01000,
    FUNCT5_AMOMIN   = 5'b10000,
    FUNCT5_AMOMAX   = 5'b10100,
    FUNCT5_AMOMINU  = 5'b11000,
    FUNCT5_AMOMAXU  = 5'b11100
} funct5_amo;

`endif
