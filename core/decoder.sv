`include "def.svh"
`include "def_csr.svh"
`include "def_decoder.svh"

module decoder (
    input               en,
    input  [31:0]       instr,
    input  rv_priv      priv_mode,
    output logic [63:0] imm,
    output decode_pack  pack,
    output logic        illegal_instr
);

wire  [63:0] imm_itype = {{52{instr[31]}},instr[31:20]};
wire  [63:0] imm_stype = {{52{instr[31]}},instr[31:25],instr[11:7]};
wire  [63:0] imm_btype = {{51{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0};
wire  [63:0] imm_utype = {{32{instr[31]}},instr[31:12],12'd0};
wire  [63:0] imm_jtype = {{43{instr[31]}},instr[31],instr[19:12],instr[20],instr[30:21],1'b0};

wire   [4:0] rs2    = instr[24:20];
wire   [4:0] rs1    = instr[19:15];
wire   [4:0] rd     = instr[11:7 ];
wire   [6:0] opcode = instr[6:0];
wire   [2:0] funct3 = instr[14:12];
wire   [6:0] funct7 = instr[31:25];
wire   [4:0] funct5 = instr[31:27]; // only used in amo

rv64i_opcode opcode;
assign opcode = instr[6:0];

always_comb begin
    pack = '{default: 0, rs1: rs1, rs2: rs2, rd: rd};
    imm = 0;
    illegal_instr = 0;
    if (en) begin
        case (opcode)
            OPCODE_LUI: begin
                pack.rs1 = 0;
                pack.alu_in2_use_imm = 1;
                pack.alu_opt = ADD;
                pack.rd_en = 1;
                pack.rd_forward_exe = 1;
                pack.rd_forward_mem = 1;
                imm = imm_utype;
            end
            OPCODE_AUIPC: begin
                pack.alu_in1_use_pc = 1;
                pack.alu_in2_use_imm = 1;
                pack.alu_opt = ADD;
                pack.rd_en = 1;
                pack.rd_forward_exe = 1;
                pack.rd_forward_mem = 1;
                imm = imm_utype;
            end
            OPCODE_JAL: begin
                pack.rd_en = |rd;
                pack.jump = 1;
                imm = imm_jtype;
            end
            OPCODE_JALR: begin
                pack.rs1_en = 1;
                pack.rd_en = 1;
                pack.jump = 1;
                imm = imm_itype;
            end
            OPCODE_BRANCH: begin
                pack.rs1_en = 1;
                pack.rs2_en = 1;
                pack.br_en = 1;
                imm = imm_btype;
                case (funct3)
                    FUNCT3_BEQ: pack.br_opt = BEQ;
                    FUNCT3_BNE: pack.br_opt = BNE;
                    FUNCT3_BLT: pack.br_opt = BLT;
                    FUNCT3_BGE: pack.br_opt = BGE;
                    FUNCT3_BLTU:pack.br_opt = BLTU;
                    FUNCT3_BGEU:pack.br_opt = BGEU;
                    default: illegal_instr = 1;
                endcase
            end
            OPCODE_LOAD: begin
                pack.rs1_en = 1;
                pack.mem_en = 1;
                pack.rd_en = 1;
                pack.rd_forward_mem = 1;
                imm = imm_itype;
                case (funct3)
                    FUNCT3_LB:  pack.mem_size = 0;
                    FUNCT3_LH:  pack.mem_size = 1;
                    FUNCT3_LW:  pack.mem_size = 2;
                    FUNCT3_LD:  pack.mem_size = 3;
                    FUNCT3_LBU: begin
                        pack.mem_size = 0;
                        pack.mem_load_uext = 1;
                    end
                    FUNCT3_LHU: begin
                        pack.mem_size = 1;
                        pack.mem_load_uext = 1;
                    end
                    FUNCT3_LWU: begin
                        pack.mem_size = 2;
                        pack.mem_load_uext = 1;
                    end
                    default: illegal_instr = 1;
                endcase
            end
            OPCODE_STORE: begin
                pack.rs1_en = 1;
                pack.rs2_en = 1;
                pack.mem_en = 1;
                pack.mem_write = 1;
                imm = imm_stype;
                case (funct3)
                    FUNCT3_SB:  pack.mem_size = 0;
                    FUNCT3_SH:  pack.mem_size = 1;
                    FUNCT3_SW:  pack.mem_size = 2;
                    FUNCT3_SD:  pack.mem_size = 3;
                    default: illegal_instr = 1;
                endcase
            end
            OPCODE_OPIMM: begin
                pack.rs1_en = 1;
                pack.rd_en = 1;
                pack.rd_forward_exe = 1;
                pack.rd_forward_mem = 1;
                pack.alu_in2_use_imm = 1;
                imm = imm_itype;
                case (funct3)
                    FUNCT3_ADD_SUB: pack.alu_opt = ADD;
                    FUNCT3_SLT:     pack.alu_opt = SLT;
                    FUNCT3_SLTU:    pack.alu_opt = SLTU;
                    FUNCT3_XOR:     pack.alu_opt = XOR;
                    FUNCT3_OR:      pack.alu_opt = OR;
                    FUNCT3_AND:     pack.alu_opt = AND;
                    FUNCT3_SLL:     pack.alu_opt = SLL;
                    FUNCT3_SRL_SRA: pack.alu_opt = instr[30] ? SRA : SRL;
                endcase
            end
            OPCODE_OPIMM32: begin
                pack.rs1_en = 1;
                pack.rd_en = 1;
                pack.rd_forward_exe = 1;
                pack.rd_forward_mem = 1;
                pack.alu_in2_use_imm = 1;
                pack.op_32 = 1;
                imm = imm_itype;
                case (funct3)
                    FUNCT3_ADD_SUB: pack.alu_opt = ADD;
                    FUNCT3_SLL:     pack.alu_opt = SLL;
                    FUNCT3_SRL_SRA: pack.alu_opt = instr[30] ? SRA : SRL;
                    default: illegal_instr = 1;
                endcase
            end
            OPCODE_OP: begin
                pack.rs1_en = 1;
                pack.rs2_en = 1;
                pack.rd_en = 1;
                pack.rd_forward_exe = 1;
                pack.rd_forward_mem = 1;
                case (funct7)
                    FUNCT7_NORMAL: begin
                        case (funct3)
                            FUNCT3_ADD_SUB: pack.alu_opt = ADD;
                            FUNCT3_SLL:     pack.alu_opt = SLL;
                            FUNCT3_SLT:     pack.alu_opt = SLT;
                            FUNCT3_SLTU:    pack.alu_opt = SLTU;
                            FUNCT3_XOR:     pack.alu_opt = XOR;
                            FUNCT3_SRL_SRA: pack.alu_opt = SRL;
                            FUNCT3_OR:      pack.alu_opt = OR;
                            FUNCT3_AND:     pack.alu_opt = AND;
                        endcase
                    end
                    FUNCT7_SUB_SRA: begin
                        case (funct3)
                            FUNCT3_ADD_SUB: pack.alu_opt = SUB;
                            FUNCT3_SRL_SRA: pack.alu_opt = SRA;
                            default: illegal_instr = 1;
                        endcase
                    end
                    FUNCT7_MUL: begin
                        case (funct3)
                            FUNCT3_MUL: begin
                                pack.mul_en = 1;
                                pack.mul_opt = MUL;
                            end
                            FUNCT3_MULH: begin
                                pack.mul_en = 1;
                                pack.mul_opt = MULH;
                            end
                            FUNCT3_MULHSU: begin
                                pack.mul_en = 1;
                                pack.mul_opt = MULHSU;
                            end
                            FUNCT3_MULHU: begin
                                pack.mul_en = 1;
                                pack.mul_opt = MULHU;
                            end
                            FUNCT3_DIV: begin
                                pack.div_en = 1;
                                pack.div_opt = DIV;
                            end
                            FUNCT3_DIVU: begin
                                pack.div_en = 1;
                                pack.div_opt = DIVU;
                            end
                            FUNCT3_REM: begin
                                pack.div_en = 1;
                                pack.div_opt = REM;
                            end
                            FUNCT3_REMU: begin
                                pack.div_en = 1;
                                pack.div_opt = REMU;
                            end
                        endcase
                    end
                    default: illegal_instr = 1;
                endcase
            end
            OPCODE_OP32: begin
                pack.rs1_en = 1;
                pack.rs2_en = 1;
                pack.rd_en = 1;
                pack.rd_forward_exe = 1;
                pack.rd_forward_mem = 1;
                pack.op_32 = 1;
                case (funct7)
                    FUNCT7_NORMAL: begin
                        case (funct3)
                            FUNCT3_ADD_SUB: pack.alu_opt = ADD;
                            FUNCT3_SLL:     pack.alu_opt = SLL;
                            FUNCT3_SRL_SRA: pack.alu_opt = SRL;
                            default: illegal_instr = 1;
                        endcase
                    end
                    FUNCT7_SUB_SRA: begin
                        case (funct3)
                            FUNCT3_ADD_SUB: pack.alu_opt = SUB;
                            FUNCT3_SRL_SRA: pack.alu_opt = SRA;
                            default: illegal_instr = 1;
                        endcase
                    end
                    FUNCT7_MUL: begin
                        case (funct3)
                            FUNCT3_MUL: begin
                                pack.mul_en = 1;
                                pack.mul_opt = MUL;
                            end
                            FUNCT3_DIV: begin
                                pack.div_en = 1;
                                pack.div_opt = DIV;
                            end
                            FUNCT3_DIVU: begin
                                pack.div_en = 1;
                                pack.div_opt = DIVU;
                            end
                            FUNCT3_REM: begin
                                pack.div_en = 1;
                                pack.div_opt = REM;
                            end
                            FUNCT3_REMU: begin
                                pack.div_en = 1;
                                pack.div_opt = REMU;
                            end
                            default: illegal_instr = 1;
                        endcase
                    end
                    default: illegal_instr = 1;
                endcase
            end
            OPCODE_FENCE: begin
                case (funct3)
                    FUNCT3_FENCE: begin
                        // for single core single issue sequence processor without Memory MSHR, fence as NOP.
                    end
                    FUNCT3_FENCE_I: begin
                        pack.fence_i = 1;       // writeback entire D-Cache and invalidate entire I-Cache.
                        pack.flush_pipe = 1;
                    end
                    default: illegal_instr = 1;
                endcase
            end
            OPCODE_SYSTEM: begin
                case (funct3)
                    FUNCT3_PRIV: begin
                        case (funct7)
                            FUNCT7_ECALL_EBREAK: begin
                                case (rs2)
                                    0: pack.ecall = 1;
                                    1: pack.ebreak = 1;
                                    default: illegal_instr = 1;
                                endcase
                            end
                            FUNCT7_SRET_WFI: begin
                                // rs2 == 5 is WFI, impl as NOP, otherwise is illegal instruction.
                                if (rs2 != 5) illegal_instr = 1;
                                // TODO: check rs1 and rd is zero
                            end
                            FUNCT7_MRET: begin
                                // rs2 == 5 is MRET, otherwise is illegal instruction.
                                // MRET can only be used in Machine Mode
                                if (rs2 != 2 || priv_mode != MACHINE_MODE) illegal_instr = 1;
                                else pack.mret = 1;
                            end
                            default: illegal_instr = 1;
                        endcase
                    end
                    // For CSRs, immediate represent CSR address, not wdata.
                    FUNCT3_CSRRW: begin
                        pack.csr_en = 1;
                        pack.csr_opt = CSR_WRITE;
                        pack.rs1_en = 1;
                        pack.rd_en = 1;
                        imm = imm_itype;
                    end
                    FUNCT3_CSRRS: begin
                        pack.csr_en = 1;
                        pack.csr_opt = |rs1 ? CSR_SETBIT : CSR_READ;
                        pack.rs1_en = 1;
                        pack.rd_en = 1;
                        imm = imm_itype;
                    end
                    FUNCT3_CSRRC: begin
                        pack.csr_en = 1;
                        pack.csr_opt = |rs1 ? CSR_CLEARBIT : CSR_READ;
                        pack.rs1_en = 1;
                        pack.rd_en = 1;
                        imm = imm_itype;
                    end
                    FUNCT3_CSRRWI: begin
                        pack.csr_en = 1;
                        pack.csr_opt = CSR_WRITE;
                        pack.rs1_en = 1;
                        pack.csr_rs1_as_imm = 1;
                        pack.rd_en = 1;
                        imm = imm_itype;
                    end
                    FUNCT3_CSRRSI: begin
                        pack.csr_en = 1;
                        pack.csr_opt = |rs1 ? CSR_SETBIT : CSR_READ;
                        pack.rs1_en = 1;
                        pack.csr_rs1_as_imm = 1;
                        pack.rd_en = 1;
                        imm = imm_itype;
                    end
                    FUNCT3_CSRRCI: begin
                        pack.csr_en = 1;
                        pack.csr_opt = |rs1 ? CSR_CLEARBIT : CSR_READ;
                        pack.rs1_en = 1;
                        pack.csr_rs1_as_imm = 1;
                        pack.rd_en = 1;
                        imm = imm_itype;
                    end
                    default: illegal_instr = 1;
                endcase
            end
`ifdef ENABLE_AMO
            OPCODE_AMO: begin
                pack.rs1_en = 1;
                pack.rs2_en = 1;
                pack.rd_en = 1;
                pack.mem_en = 1;
                pack.amo_en = 1;
                pack.mem_size = funct3[1:0];
                if (funct3 != 2 && funct3 != 3) illegal_instr = 1;
                // for single core single issue sequence processor without Memory MSHR, ignore aq/rl bits.
                case (funct5)
                    FUNCT5_AMOLR:   pack.amo_opt = LR;
                    FUNCT5_AMOSC:   pack.amo_opt = SC;
                    FUNCT5_AMOSWAP: pack.amo_opt = AMOSWAP;
                    FUNCT5_AMOADD:  pack.amo_opt = AMOADD;
                    FUNCT5_AMOXOR:  pack.amo_opt = AMOXOR;
                    FUNCT5_AMOAND:  pack.amo_opt = AMOAND;
                    FUNCT5_AMOOR:   pack.amo_opt = AMOOR;
                    FUNCT5_AMOMIN:  pack.amo_opt = AMOMIN;
                    FUNCT5_AMOMAX:  pack.amo_opt = AMOMAX;
                    FUNCT5_AMOMINU: pack.amo_opt = AMOMINU;
                    FUNCT5_AMOMAXU: pack.amo_opt = AMOMAXU;
                    default: illegal_instr = 1;
                endcase
            end
`endif
            default: illegal_instr = 1;
        endcase
    end
end

endmodule
