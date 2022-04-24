package cyyrv64

import chisel3._
import chisel3.util._
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
    object Opcode extends ChiselEnum {
        val LOAD    = Value("b0000011".U)
        val FENCE   = Value("b0001111".U)
        val OPIMM   = Value("b0010011".U)
        val AUIPC   = Value("b0010111".U)
        val OPIMM32 = Value("b0011011".U)
        val STORE   = Value("b0100011".U)
        val AMO     = Value("b0101111".U)
        val OP      = Value("b0110011".U)
        val LUI     = Value("b0110111".U)
        val OP32    = Value("b0111011".U)
        val BRANCH  = Value("b1100011".U)
        val JALR    = Value("b1100111".U)
        val JAL     = Value("b1101111".U)
        val SYSTEM  = Value("b1110011".U)
    }
    object Funct3 {
        object Branch extends ChiselEnum {
            val BEQ     = Value("b000".U)
            val BNE     = Value("b001".U)
            val BLT     = Value("b100".U)
            val BGE     = Value("b101".U)
            val BLTU    = Value("b110".U)
            val BGEU    = Value("b111".U)
        }
        object Load extends ChiselEnum {
            val LB      = Value("b000".U)
            val LH      = Value("b001".U)
            val LW      = Value("b010".U)
            val LD      = Value("b011".U)
            val LBU     = Value("b100".U)
            val LHU     = Value("b101".U)
            val LWU     = Value("b110".U)
        }
        object Store extends ChiselEnum {
            val SB      = Value("b000".U)
            val SH      = Value("b001".U)
            val SW      = Value("b010".U)
            val SD      = Value("b011".U)
        }
        object Op extends ChiselEnum {
            val ADD_SUB = Value("b000".U)
            val SLL     = Value("b001".U)
            val SLT     = Value("b010".U)
            val SLTU    = Value("b011".U)
            val XOR     = Value("b100".U)
            val SRL_SRA = Value("b101".U)
            val OR      = Value("b110".U)
            val AND     = Value("b111".U)
        }
        object Mul extends ChiselEnum {
            val MUL     = Value("b000".U)
            val MULH    = Value("b001".U)
            val MULHSU  = Value("b010".U)
            val MULHU   = Value("b011".U)
            val DIV     = Value("b100".U)
            val DIVU    = Value("b101".U)
            val REM     = Value("b110".U)
            val REMU    = Value("b111".U)
        }
        object System extends ChiselEnum {
            val PRIV    = Value("b000".U)
            val CSRRW   = Value("b001".U)
            val CSRRS   = Value("b010".U)
            val CSRRC   = Value("b011".U)
            val HLSV    = Value("b100".U)
            val CSRRWI  = Value("b101".U)
            val CSRRSI  = Value("b110".U)
            val CSRRCI  = Value("b111".U)
        }
    }
    object Funct7 {
        object Op extends ChiselEnum {
            val NORMAL  = Value("b0000000".U)
            val MUL     = Value("b0000001".U)
            val SUB_SRA = Value("b0100000".U)
        }
        object Priv extends ChiselEnum {
            val ECALL_EBREAK    = Value("b0000000".U)
            val SRET_WFI        = Value("b0001000".U)
            val SFENCE_VMA      = Value("b0001001".U)
            val MRET            = Value("b0011000".U)
        }
    }
    object Funct6 {
        object Op extends ChiselEnum {
            val NORMAL  = Value("b000000".U)
            val SRA     = Value("b010000".U)
        }
    }
    object AMO_Funct extends ChiselEnum {
        val AMOADD  = Value("b00000".U)
        val AMOSWAP = Value("b00001".U)
        val AMOLR   = Value("b00010".U)
        val AMOSC   = Value("b00011".U)
        val AMOXOR  = Value("b00100".U)
        val AMOOR   = Value("b01000".U)
        val AMOAND  = Value("b01100".U)
        val AMOMIN  = Value("b10000".U)
        val AMOMAX  = Value("b10100".U)
        val AMOMINU = Value("b11000".U)
        val AMOMAXU = Value("b11100".U)
    }
}

object RVExcCode extends ChiselEnum {
    val instr_misalign  = Value(0.U) 
    val instr_acc_fault = Value(1.U) 
    val illegal_instr   = Value(2.U) 
    val breakpoint      = Value(3.U) 
    val load_misalign   = Value(4.U) 
    val load_acc_fault  = Value(5.U) 
    val store_misalign  = Value(6.U)    // including amo
    val store_acc_fault = Value(7.U)    // including amo
    val ecall_from_u    = Value(8.U) 
    val ecall_from_s    = Value(9.U) 
    val ecall_from_m    = Value(11.U) 
    val instr_pgfault   = Value(12.U) 
    val load_pgfault    = Value(13.U) 
    val store_pgfault   = Value(15.U)   // including amo
}

object RVIntCode extends ChiselEnum {
    val s_soft  = Value(1.U)
    val m_soft  = Value(3.U)
    val s_timer = Value(5.U)
    val m_timer = Value(7.U)
    val s_ext   = Value(9.U)
    val m_ext   = Value(11.U)
}

object RVPrivMode extends ChiselEnum {
    val User        = Value(0.U)
    val Supervisor  = Value(1.U)
    val Machine     = Value(3.U)
}

object RVSAMode extends ChiselEnum {
    val Bare    = Value(0.U)
    val Sv39    = Value(8.U)
}

object RVCSR {
    class status extends Bundle {
        val sie  = Bool();  // supervisor interrupt enable
        val mie  = Bool();  // machine interrupt enable
        val spie = Bool();  // sie prior to trapping
        val mpie = Bool();  // sie prior to trapping
        val spp  = UInt(1.W);   // supervisor previous privilege mode.
        val mpp  = UInt(2.W);   // machine previous privilege mode.
        val mprv = Bool();  // Modify PRiVilege (Turn on virtual memory and protection for load/store in M-Mode) when mpp is not M-Mode
        val sum  = Bool();  // permit Supervisor User Memory access
        val mxr  = Bool();  // Make eXecutable Readable
        val tvm  = Bool();  // Trap Virtual Memory (raise trap when sfence.vma and sinval.vma executing in S-Mode)
        val tw   = Bool();  // Timeout Wait for WFI
        val tsr  = Bool();  // Trap SRET

        def fromMStatus(toWrite : UInt): Unit = {
            sie  := toWrite(1)
            mie  := toWrite(3)
            spie := toWrite(5)
            mpie := toWrite(7)
            spp  := toWrite(8)
            mpp  := toWrite(12,11)
            mprv := toWrite(17)
            sum  := toWrite(18)
            mxr  := toWrite(19)
            tvm  := toWrite(20)
            tw   := toWrite(21)
            tsr  := toWrite(22)
        }

        def fromSStatus(toWrite : UInt): Unit = {
            sie  := toWrite(1)
            spie := toWrite(5)
            spp  := toWrite(8)
            sum  := toWrite(18)
            mxr  := toWrite(19)
        }

        def toMStatus(): UInt = {
            Seq(
                ( 1, sie),
                ( 3, mie),
                ( 5, spie),
                ( 7, mpie),
                ( 8, spp),
                (11, mpp),
                (17, mprv),
                (18, sum),
                (19, mxr),
                (20, tvm),
                (21, tw),
                (22, tsr),
                (32, 2.U),
                (34, 2.U)
            ).foldLeft(0.U)( (result, field) => result | (field._1.asUInt << field._2).asUInt )
        }

        def toSStatus(): UInt = {
            Seq(
                ( 1, sie),
                ( 5, spie),
                ( 8, spp),
                (18, sum),
                (19, mxr),
                (32, 2.U),
            ).foldLeft(0.U)( (result, field) => result | (field._1.asUInt << field._2).asUInt )
        }
    };

    class satp extends Bundle {
        val mode = RVSAMode()
        val ppn  = UInt(44.W)

        def getAddr(): UInt = {
            (ppn << 12).asUInt
        }

        def getMode(): RVSAMode.Type = {
            mode
        }

        def read(): UInt = {
            val res = ppn
            switch (mode) {
                is (RVSAMode.Sv39) {
                    res := res | (8.U << 60).asUInt
                }
            }
            res
        }

        def write(toWrite: UInt): Unit = {
            ppn := toWrite(43, 0)
            when(toWrite(63, 60) === 8.U) {
                mode := RVSAMode.Sv39
            }.otherwise {
                mode := RVSAMode.Bare
            }
        }
    }

    class ip extends Bundle {
        // ext ip
        val meip = Bool()
        val msip = Bool()
        val mtip = Bool()
        val seip = Bool()
        // sbi write ip
        val ssip = Bool()
        val stip = Bool()

        // Since all ip to write is s*ip, and it can be write from s mode, one function is enough
        def fromIP(toWrite: UInt): Unit = {
            ssip := toWrite(1)
            stip := toWrite(5)
        }

        def toMIP(): UInt = {
            Seq(
                ( 1.U, ssip),
                ( 3.U, msip),
                ( 5.U, stip),
                ( 7.U, mtip),
                ( 9.U, seip),
                (11.U, meip)
            ).foldLeft(0.U)( (result, field) => result | (field._1 << field._2).asUInt )
        }

        def toSIP(): UInt = {
            Seq(
                ( 1.U, ssip),
                ( 5.U, stip),
                ( 9.U, seip)
            ).foldLeft(0.U)( (result, field) => result | (field._1 << field._2).asUInt )
        }
    }

    class ie extends Bundle {
        val meie = Bool()
        val msie = Bool()
        val mtie = Bool()
        val seie = Bool()
        val ssie = Bool()
        val stie = Bool()

        def fromMIE(toWrite: UInt): Unit = {
            ssie := toWrite(1)
            msie := toWrite(3)
            stie := toWrite(5)
            mtie := toWrite(7)
            seie := toWrite(9)
            meie := toWrite(11)
        }

        def fromSIE(toWrite: UInt): Unit = {
            ssie := toWrite(1)
            stie := toWrite(5)
            seie := toWrite(9)
        }

        def toMIE(): UInt = {
            Seq(
                ( 1.U, ssie),
                ( 3.U, msie),
                ( 5.U, stie),
                ( 7.U, mtie),
                ( 9.U, seie),
                (11.U, meie)
            ).foldLeft(0.U)( (result, field) => result | (field._1 << field._2).asUInt )
        }

        def toSIE(): UInt = {
            Seq(
                ( 1.U, ssie),
                ( 5.U, stie),
                ( 9.U, seie)
            ).foldLeft(0.U)( (result, field) => result | (field._1 << field._2).asUInt )
        }
    }

    class mideleg extends Bundle {
        val seid = Bool()
        val ssid = Bool()
        val stid = Bool()

        def read(): UInt = {
            Seq(
                (1.U, ssid),
                (5.U, stid),
                (9.U, seid)
            ).foldLeft(0.U)((result, field) => result | (field._1 << field._2).asUInt)
        }

        def write(toWrite: UInt): Unit = {
            ssid := toWrite(1)
            stid := toWrite(5)
            seid := toWrite(9)
        }
    }

    class medeleg extends Bundle {
        val stor = UInt(16.W)

        def read(): UInt = {
            stor
        }

        def write(toWrite: UInt): Unit = {
            stor := Cat(toWrite(15,12),false.B,toWrite(10,0))
        }
    }
}

class MMUInfo extends Bundle {
    val cur_priv = RVPrivMode()
    val satp = new RVCSR.satp
    val mxr = Bool()
    val sum = Bool()
    def default(): MMUInfo = {
        val res = new MMUInfo
        res.cur_priv := RVPrivMode.Machine
        res.satp := 0.U.asTypeOf(new RVCSR.satp)
        res.mxr := false.B
        res.sum := false.B
        res
    }
}