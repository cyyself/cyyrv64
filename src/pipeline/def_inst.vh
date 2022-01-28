`ifndef DEF_INST
`define DEF_INST

// RV64I {
`define OPCODE_LUI      7'b0110111
`define OPCODE_AUIPC    7'b0010111
`define OPCODE_JAL      7'b1101111
`define OPCODE_JALR     7'b1100111
`define OPCODE_BRANCH   7'b1100011 // All branch
    // Branch Funct3 {
    `define FUNCT3_BEQ      3'b000
    `define FUNCT3_BNE      3'b001
    `define FUNCT3_BLT      3'b100
    `define FUNCT3_BGE      3'b101
    `define FUNCT3_BLTU     3'b110
    `define FUNCT3_BGEU     3'b111
    // Branch Funct3 }
`define OPCODE_LOAD     7'b0000011
    // Load Funct3 {
    `define FUNCT3_LB   3'b000
    `define FUNCT3_LBU  3'b100
    `define FUNCT3_LH   3'b001
    `define FUNCT3_LHU  3'b101
    `define FUNCT3_LW   3'b010
    `define FUNCT3_LWU  3'b110 // RV64I
    `define FUNCT3_LD   3'b011 // RV64I
    // Load Funct3 }
`define OPCODE_STORE    7'b0100011
    // Store Funct3 {
    `define FUNCT3_SB   3'b000
    `define FUNCT3_SH   3'b001
    `define FUNCT3_SW   3'b010
    `define FUNCT3_SD   3'b011 // RV64I
    // Store Funct3 }
`define OPCODE_OPIMM    7'b0010011
`define OPCODE_OP       7'b0110011
`define OPCODE_OPIMM32  7'b0011011 // RV64I: ADDIW,SLLIW,SRLIW,SRAIW
`define OPCODE_OP32     7'b0111011 // RV64I: ADDW,SUBW,SLLW,SRLW,SRAW
    // ALU_Funct3 {
    `define FUNCT3_ADD_SUB  3'b000
    `define FUNCT3_SLL      3'b001
    `define FUNCT3_SLT      3'b010
    `define FUNCT3_SLTU     3'b011
    `define FUNCT3_XOR      3'b100
    `define FUNCT3_SRL_SRA  3'b101
    `define FUNCT3_OR       3'b110
    `define FUNCT3_AND      3'b111
    // ALU_funct3 }
    // ALU_Funct7 {
    `define FUNCT7_NORMAL   7'd0
    `define FUNCT7_SUB      7'b0100000
    `define FUNCT7_SRA      7'b0100000
    // ALU_Funct7 }
    // ALU_Funct6 {
    `define FUNCT6_NORMAL   6'd0
    `define FUNCT6_SRA      6'b010000
    // ALU_Funct7 }
`define OPCODE_FENCE        7'b0010111
`define OPCODE_EEI          7'b1110011
// RV32I }

`endif