package cyyrv64

import chisel3._
import chisel3.experimental.ChiselEnum

object ALUOpSel extends ChiselEnum {
    val nop, add, sub, sll, slt, sltu, xor, srl, sra, or, and = Value
}

object BranchOpSel extends ChiselEnum {
    val nop, beq, bne, blt, bge, bltu, bgeu = Value
}

object MulOpSel extends ChiselEnum {
    val nop, mul, mulh, mulhu, mulhsu = Value
}

object DivOpSel extends ChiselEnum {
    val nop, div, divu, rem, remu = Value
}

object IFUResp extends ChiselEnum {
    val ok, instr_misalign, instr_accfault, instr_pgfault = Value
}

object RVInstr {
    object Opcode {
        val LUI     = "b0110111".U
        val AUIPC   = "b0010111".U
        val JAL     = "b1101111".U
        val JALR    = "b1100111".U
        val BRANCH  = "b1100011".U
        val LOAD    = "b0000011".U
        val STORE   = "b0100011".U
        val OPIMM   = "b0010011".U
        val OPIMM32 = "b0011011".U
        val OP      = "b0110011".U
        val OP32    = "b0111011".U
        val FENCE   = "b0001111".U
        val SYSTEM  = "b1110011".U
        val AMO     = "b0101111".U
    }
    object Funct3 {
        object Branch {
            val BEQ     = "b000".U
            val BNE     = "b001".U
            val BLT     = "b100".U
            val BGE     = "b101".U
            val BLTU    = "b110".U
            val BGEU    = "b111".U
        }
        object Load {
            val LB      = "b000".U
            val LH      = "b001".U
            val LW      = "b010".U
            val LD      = "b011".U
            val LBU     = "b100".U
            val LHU     = "b101".U
            val LWU     = "b110".U
        }
        object Store {
            val SB      = "b000".U
            val SH      = "b001".U
            val SW      = "b010".U
            val SD      = "b011".U
        }
        object Op {
            val ADD_SUB = "b000".U
            val SLL     = "b001".U
            val SLT     = "b010".U
            val SLTU    = "b011".U
            val XOR     = "b100".U
            val SRL_SRA = "b101".U
            val OR      = "b110".U
            val AND     = "b111".U
        }
        object Mul {
            val MUL     = "b000".U
            val MULH    = "b001".U
            val MULHSU  = "b010".U
            val MULHU   = "b011".U
            val DIV     = "b100".U
            val DIVU    = "b101".U
            val REM     = "b110".U
            val REMU    = "b111".U
        }
        object System {
            val PRIV    = "b000".U
            val CSRRW   = "b001".U
            val CSRRS   = "b010".U
            val CSRRC   = "b011".U
            val HLSV    = "b100".U
            val CSRRWI  = "b101".U
            val CSRRSI  = "b110".U
            val CSRRCI  = "b111".U
        }
    }
    object Funct7 {
        object Op {
            val NORMAL  = "b0000000".U
            val SUB_SRA = "b0100000".U
            val MUL     = "b0000001".U
        }
        object Priv {
            val ECALL_EBREAK    = "b0000000".U
            val SRET_WFI        = "b0001000".U
            val MRET            = "b0011000".U
            val SFENCE_VMA      = "b0001001".U
        }
    }
    object Funct6 {
        object Op {
            val NORMAL  = "b000000".U
            val SRA     = "b010000".U
        }
    }
    object AMO_Funct {
        val AMOLR   = "b00010".U
        val AMOSC   = "b00011".U
        val AMOSWAP = "b00001".U
        val AMOADD  = "b00000".U
        val AMOXOR  = "b00100".U
        val AMOAND  = "b01100".U
        val AMOOR   = "b01000".U
        val AMOMIN  = "b10000".U
        val AMOMAX  = "b10100".U
        val AMOMINU = "b11000".U
        val AMOMAXU = "b11100".U
    }
}

object RVExcCode {
    val instr_misalign  = 0.U 
    val instr_acc_fault = 1.U 
    val illegal_instr   = 2.U 
    val breakpoint      = 3.U 
    val load_misalign   = 4.U 
    val load_acc_fault  = 5.U 
    val store_misalign  = 6.U   // including amo
    val store_acc_fault = 7.U   // including amo
    val ecall_from_u    = 8.U 
    val ecall_from_s    = 9.U 
    val ecall_from_m    = 11.U 
    val instr_pgfault   = 12.U 
    val load_pgfault    = 13.U 
    val store_pgfault   = 15.U  // including amo
}

object RVIntCode {
    val s_sw    = 1.U
    val m_sw    = 3.U
    val s_timer = 5.U
    val m_timer = 7.U
    val s_ext   = 9.U
    val m_ext   = 11.U
}

object RVPrivMode {
    val User        = 0.U
    val Supervisor  = 1.U
    val Machine     = 3.U
}