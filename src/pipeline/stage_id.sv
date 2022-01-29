`include "def_inst.vh"
`include "def_common.vh"
module stage_id(
    input               clk,
    input               rst,
    input               id_flush,
    output              id_ready,
    input  pipe_common  id_pipe,
    output ctrl_sign    id_ctrl,
    output id2exe       id_out,
    input  wb_reg       wb_id_fw
);

assign id_ready = 1;

wire   [4:0] rs2       = id_pipe.instr[24:20];
wire   [4:0] rs1       = id_pipe.instr[19:15];
wire   [4:0] rd        = id_pipe.instr[11:7 ];
wire   [6:0] opcode    = id_pipe.instr[6:0];
wire   [2:0] funct3    = id_pipe.instr[14:12];
wire   [6:0] funct7    = id_pipe.instr[31:25];
wire   [5:0] funct6    = id_pipe.instr[31:26]; // RV64

wire  [63:0] imm_itype = {{52{id_pipe.instr[31]}},id_pipe.instr[31:20]};
wire  [63:0] imm_stype = {{52{id_pipe.instr[31]}},id_pipe.instr[31:25],id_pipe.instr[11:7]};
wire  [63:0] imm_btype = {{51{id_pipe.instr[31]}},id_pipe.instr[31],id_pipe.instr[7],id_pipe.instr[30:25],id_pipe.instr[11:8],1'b0};
wire  [63:0] imm_utype = {{32{id_pipe.instr[31]}},id_pipe.instr[31:12],12'd0};
wire  [63:0] imm_jtype = {{43{id_pipe.instr[31]}},id_pipe.instr[31],id_pipe.instr[19:12],id_pipe.instr[20],id_pipe.instr[30:21],1'b0};
wire  [63:0] imm_sha32 = {59'd0,id_pipe.instr[24:20]};
wire  [63:0] imm_sha64 = {58'd0,id_pipe.instr[25:20]};

logic [63:0] imm; // 在id阶段计算所有的立即数
assign id_out.imm = imm;

always_comb begin : decoder
    id_ctrl = `CTRL_SIGN_NOP;
    imm     = 0;
    case (opcode)
        `OPCODE_LUI: begin
            id_ctrl.alu_control = `ALU_IMM;
            id_ctrl.alu_imm     = 1;
            id_ctrl.rd_en       = |rd;
            imm                 = imm_utype;
        end
        `OPCODE_AUIPC: begin
            id_ctrl.alu_control = `ALU_ADD;
            id_ctrl.alu_pc      = 1;
            id_ctrl.alu_imm     = 1;
            id_ctrl.rd_en       = |rd;
            imm                 = imm_utype;
        end
        `OPCODE_JAL: begin 
            id_ctrl.jump        = 1;
            id_ctrl.rd_en       = |rd;
            imm                 = imm_jtype;
        end
        `OPCODE_JALR: begin
            id_ctrl.rs1_en      = 1;
            id_ctrl.rd_en       = |rd;
            id_ctrl.jump        = 1;
            id_ctrl.jalr        = 1;
            imm                 = imm_itype;
        end
        `OPCODE_BRANCH: begin
            id_ctrl.alu_control = `ALU_NOP;
            id_ctrl.rs1_en      = 1;
            id_ctrl.rs2_en      = 1;
            id_ctrl.branch      = 1;
            imm                 = imm_btype;
        end
        `OPCODE_LOAD: begin
            imm                 = imm_itype;
            case (funct3)
                `FUNCT3_LB, `FUNCT3_LBU, `FUNCT3_LH, `FUNCT3_LHU, `FUNCT3_LW, `FUNCT3_LWU, `FUNCT3_LD: begin
                    id_ctrl.mem_read    = 1;
                    id_ctrl.alu_imm     = 1;
                    id_ctrl.rs1_en      = 1;
                    id_ctrl.rd_en       = |rd;
                end
                default: id_ctrl.reversed = 1;
            endcase
        end
        `OPCODE_STORE: begin
            imm                 = imm_stype;
            case (funct3)
                `FUNCT3_SB, `FUNCT3_SH, `FUNCT3_SW, `FUNCT3_SD: begin
                    id_ctrl.mem_write   = 1;
                    id_ctrl.alu_control = `ALU_NOP;
                    id_ctrl.alu_imm     = 1;
                    id_ctrl.rs1_en      = 1;
                    id_ctrl.rs2_en      = 1;
                end
                default: id_ctrl.reversed = 1;
            endcase
        end
        `OPCODE_OPIMM: begin
            id_ctrl.alu_imm     = 1;
            id_ctrl.rs1_en      = 1;
            id_ctrl.rd_en       = |rd;
            case (funct3)
                `FUNCT3_SLL: begin
                    id_ctrl.alu_control = {funct6[4],funct3};
                    imm                 = imm_sha64;
                    if (funct6 != `FUNCT6_NORMAL) id_ctrl.reversed = 1;
                end
                `FUNCT3_SRL_SRA: begin
                    id_ctrl.alu_control = {funct6[4],funct3};
                    imm                 = imm_sha64;
                    case (funct6)
                        `FUNCT6_NORMAL, `FUNCT6_SRA: begin
                        end
                        default: id_ctrl.reversed    = 1;
                    endcase
                end
                `FUNCT3_ADD_SUB, `FUNCT3_SLT, `FUNCT3_SLTU, `FUNCT3_XOR, `FUNCT3_OR, `FUNCT3_AND: begin
                    id_ctrl.alu_control = {1'b0,funct3};
                    imm                 = imm_itype;
                end
                default: id_ctrl.reversed    = 1;
            endcase
        end
        `OPCODE_OPIMM32: begin
            id_ctrl.alu_imm     = 1;
            id_ctrl.alu_32      = 1;
            id_ctrl.rs1_en      = 1;
            id_ctrl.rd_en       = |rd;
            case (funct3)
                `FUNCT3_SLL: begin
                    id_ctrl.alu_control = {funct7[5],funct3};
                    imm                 = imm_sha32;
                    if (funct7 != `FUNCT7_NORMAL) id_ctrl.reversed = 1;
                end
                `FUNCT3_SRL_SRA: begin
                    id_ctrl.alu_control = {funct7[5],funct3};
                    imm                 = imm_sha32;
                    case (funct7)
                        `FUNCT7_NORMAL, `FUNCT7_SRA: begin
                        end
                        default: id_ctrl.reversed    = 1;
                    endcase
                end
                `FUNCT3_ADD_SUB: begin
                    id_ctrl.alu_control = {1'b0,funct3};
                    imm                 = imm_itype;
                end
                default: id_ctrl.reversed    = 1;
            endcase
        end
        `OPCODE_OP: begin
            id_ctrl.alu_control = {funct7[5],funct3};
            id_ctrl.rs1_en      = 1;
            id_ctrl.rs2_en      = 1;
            id_ctrl.rd_en       = |rd;
            case (funct3)
                `FUNCT3_ADD_SUB: begin
                    case (funct7)
                        `FUNCT7_NORMAL, `FUNCT7_SUB: begin
                        end
                        default: id_ctrl.reversed = 1;
                    endcase
                end
                `FUNCT3_SRL_SRA: begin
                    case (funct7)
                        `FUNCT7_NORMAL, `FUNCT7_SRA: begin
                        end
                        default: id_ctrl.reversed = 1;
                    endcase
                end
                `FUNCT3_SLL, `FUNCT3_SLT, `FUNCT3_SLTU, `FUNCT3_XOR, `FUNCT3_OR, `FUNCT3_AND: begin
                    if (funct7 != `FUNCT7_NORMAL) id_ctrl.reversed = 1;
                end
                default: id_ctrl.reversed    = 1;
            endcase
        end
        `OPCODE_OP32: begin
            id_ctrl.alu_control = {funct7[5],funct3};
            id_ctrl.alu_32      = 1;
            id_ctrl.rs1_en      = 1;
            id_ctrl.rs2_en      = 1;
            id_ctrl.rd_en       = |rd;
            case (funct3)
                `FUNCT3_ADD_SUB: begin
                    case (funct7)
                        `FUNCT7_NORMAL, `FUNCT7_SUB: begin
                        end
                        default: id_ctrl.reversed = 1;
                    endcase
                end
                `FUNCT3_SLL: begin
                    if (funct7 != `FUNCT7_NORMAL) id_ctrl.reversed = 1;
                end
                `FUNCT3_SRL_SRA: begin
                    case (funct7)
                        `FUNCT7_NORMAL, `FUNCT7_SRA: begin
                        end
                        default: id_ctrl.reversed = 1;
                    endcase
                end
                default:
                    id_ctrl.reversed = 1;
            endcase
        end
        default: begin
            id_ctrl             = `CTRL_SIGN_RI;
            imm                 = 0;
        end
    endcase
    // if (id_ctrl.reversed) id_ctrl.rd_en = 0;
    // 好像除了增加逻辑复杂度并没有什么卵用，当出现RI即使forward了也会被flush掉不会提交
end

regfile regfile(
    .clk        (clk),
    .rst        (rst),
    // read port 1
    .read_addr1 (rs1),
    .read_data1 (id_out.reg_rs1),
    // read port 2
    .read_addr2 (rs2),
    .read_data2 (id_out.reg_rs2),
    // write port
    .write_addr (wb_id_fw.rd),
    .write_data (wb_id_fw.result),
    .write_ena  (wb_id_fw.rd_en)
);

endmodule
