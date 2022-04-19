package cyyrv64

import chisel3._
import chisel3.util._

class DivPort extends Bundle {
    val in1 = Input(SInt(64.W))
    val in2 = Input(SInt(64.W))
    val en = Input(Bool())
    val divOp = Input(DivOpSel())
    val mode32 = Input(Bool())
    val out_valid = Output(Bool())
    val out_ready = Input(Bool())
    val out = Output(SInt(64.W))
}

class Div extends Module {
    val io = IO(new DivPort)

    val sIDLE :: sCAL :: sFINAL :: Nil = Enum(3)
    val state = RegInit(sIDLE)
    val out32 = Reg(Bool())
    val op1_cmp = Reg(UInt(64.W))   // bits to compare with divisor(op2)
    val op1_rem = Reg(UInt(63.W))   // bits lower than compare. i.e. remain binary to shift to op1_cmp to try to divide
    val op2 = Reg(UInt(64.W))       // divisor
    val resultu = Reg(UInt(64.W))   // div result unsigned
    val rem_bits = Reg(UInt(6.W))   // rem bits (to shift)
    val ressign = Reg(Bool())
    val remsign = Reg(Bool())
    val outrem = Reg(Bool())
    val out = RegInit(0.S(64.W))
    val valid = RegInit(false.B)
    
    io.out_valid := valid
    io.out := out

    when (io.en) {
        switch (state) {
            is (sIDLE) {
                when (!valid || io.out_ready) {
                    val in1_min = Mux(io.mode32, io.in1(31,0) === "h80000000".U, io.in1.asUInt === "h8000_0000_0000_0000".U)
                    val in2_neg_one = Mux(io.mode32, io.in1(31,0) === "hffffffff".U, io.in1.asUInt === "hffff_ffff_ffff_ffff".U)
                    // Used for check -inf/-1 overflow

                    val in1_sign = Mux(io.mode32,io.in1(31),io.in1(63))
                    val in2_sign = Mux(io.mode32,io.in2(31),io.in2(63))
                    // Read sign
                    
                    val in1_abs32 = Mux(io.in1(31), (~io.in1(31,0)) +% 1.U, io.in1(31,0))
                    val in2_abs32 = Mux(io.in2(31), (~io.in2(31,0)) +% 1.U, io.in2(31,0))
                    // abs in 32bit mode

                    val in1_abs64 = Mux(io.in1(63), (~io.in1(63,0)) +% 1.U, io.in1(63,0))
                    val in2_abs64 = Mux(io.in2(63), (~io.in2(63,0)) +% 1.U, io.in2(63,0))
                    // abs in 64bit mode

                    val in1_abs = Mux(io.mode32, in1_abs32, in1_abs64)
                    val in2_abs = Mux(io.mode32, in2_abs32, in2_abs64)
                    // get abs

                    val in1_uext = Mux(io.mode32,io.in1(31,0),io.in1.asUInt)
                    val in2_uext = Mux(io.mode32,io.in2(31,0),io.in2.asUInt)
                    // Unsigned Extend

                    val unsigned_op = (io.divOp === DivOpSel.divu || io.divOp === DivOpSel.remu)
                    val rem_op = (io.divOp === DivOpSel.rem || io.divOp === DivOpSel.remu)
                    // Read Op Type
                    
                    val new_in1 = Mux(unsigned_op,in1_uext,in1_abs)
                    val new_in2 = Mux(unsigned_op,in2_uext,in2_abs)
                    // After pre process (We did abs for signed div)
                    // printf("new_in1 = %x, new_in2 = %x\n",new_in1,new_in2)
                    val in1_highbit_pos = Log2(new_in1)
                    // printf("in1_highbit_pos = %x\n",in1_highbit_pos)
                    // get initshift
                    val shift_bits = (64.U -% in1_highbit_pos)(6,0)
                    // printf("shift_bits = %x\n",shift_bits)
                    val in1_shifted = new_in1 << shift_bits
                    // printf("in1_shifted = %x\n",in1_shifted)
                    op1_cmp := in1_shifted(127,64)
                    op1_rem := in1_shifted(63,1)

                    rem_bits := in1_highbit_pos

                    op2 := new_in2

                    // Save information need for output
                    ressign := Mux(unsigned_op,false.B,in1_sign ^ in2_sign)
                    remsign := Mux(unsigned_op,false.B,in1_sign)
                    outrem := rem_op

                    out32 := io.mode32

                    resultu := 0.U

                    when (new_in2 === 0.U) {
                        valid := true.B
                        out := Mux(!rem_op, -1.S, Mux(io.mode32, io.in1(31,0).asSInt, io.in1))
                    }.elsewhen (!unsigned_op && in1_min && in2_neg_one) {
                        valid := true.B
                        out := Mux(io.divOp === DivOpSel.div, Mux(io.mode32,"hffff_ffff_8000_0000".U,"h8000_0000_0000_0000".U).asSInt, 0.S)
                    }.elsewhen (new_in1 === 0.U) {
                        valid := true.B
                        out := 0.S
                    }.otherwise {
                        valid := false.B
                        state := sCAL
                    }
                }
            }
            is (sCAL) {
                // Booth's Algorithm
                // printf("op1_cmp = %x\n",op1_cmp)
                // printf("op1_rem = %x\n",op1_rem)
                // printf("op2 = %x\n",op2)
                val try_result = Cat(false.B,op1_cmp) - op2
                // printf("try_result = %x\n",try_result)
                // printf("rem_bits = %x\n",rem_bits)
                resultu := Cat(resultu(62,0),~try_result(64))
                // It's easy to proof try_result(63) will be zero if the result is postive.

                when (rem_bits === 0.U) {
                    op1_cmp := Mux(try_result(64),op1_cmp(63,0),try_result(63,0))
                    state := sFINAL
                }.otherwise {
                    op1_cmp := Cat(Mux(try_result(64),op1_cmp(62,0),try_result(62,0)),op1_rem(62))
                    op1_rem := Cat(op1_rem(61,0),0.U(1.W))
                    rem_bits := rem_bits -% 1.U
                }
            }
            is (sFINAL) {
                val result_s = Mux(ressign,-(resultu.asSInt),resultu.asSInt)
                val res = Mux(out32,result_s(31,0).asSInt,result_s)
                val rem_s = Mux(remsign,-(op1_cmp.asSInt),op1_cmp.asSInt)
                val rem = Mux(out32,rem_s(31,0).asSInt,rem_s)
                out := Mux(outrem,rem,res)
                valid := true.B
                state := sIDLE
                // printf("Final!")
            }
        }
    }.otherwise {
        state := sIDLE
        valid := false.B
    }
}
