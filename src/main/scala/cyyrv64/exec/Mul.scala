package cyyrv64

import chisel3._
import chisel3.util._

class MulPort extends Bundle {
    val in1 = Input(SInt(64.W))
    val in2 = Input(SInt(64.W))
    val en = Input(Bool())
    val mulOp = Input(MulOpSel())
    val mode32 = Input(Bool())
    val out_valid = Output(Bool())
    val out = Output(SInt(64.W))
}


class Mul extends Module {
    val io = IO(new MulPort)

    val sIDLE :: sCAL :: sFINAL :: Nil = Enum(3)
    val state = RegInit(sIDLE)
    val out32 = Reg(Bool())
    val op1 = Reg(UInt(64.W))
    val op2 = Reg(UInt(64.W))
    val outsign = Reg(Bool())
    val outhigh = Reg(Bool())
    val mid_result = Reg(Vec(4, UInt(64.W)))
    val out = RegInit(0.S(64.W))
    val valid = RegInit(false.B)

    io.out_valid := valid
    io.out := out

    when(io.en) {
        switch (state) {
            is (sIDLE) {
                val new_in1 = Mux(io.mode32,io.in1(31,0).asSInt,io.in1)
                val new_in2 = Mux(io.mode32,io.in2(31,0).asSInt,io.in2)
                val in1_sign = new_in1(63)
                val in2_sign = new_in2(63)
                switch (io.mulOp) {
                    is (MulOpSel.mul) {
                        outsign := false.B
                        outhigh := false.B
                        op1 := new_in1.asUInt
                        op2 := new_in2.asUInt
                    }
                    is (MulOpSel.mulh) {
                        outsign := in1_sign ^ in2_sign
                        outhigh := true.B
                        op1 := new_in1.abs.asUInt
                        op2 := new_in2.abs.asUInt
                    }
                    is (MulOpSel.mulhu) {
                        outsign := false.B
                        outhigh := true.B
                        op1 := new_in1.asUInt
                        op2 := new_in2.asUInt
                    }
                    is (MulOpSel.mulhsu) {
                        outsign := in1_sign
                        outhigh := true.B
                        op1 := new_in1.abs.asUInt
                        op2 := new_in2.asUInt
                    }
                }
                out32 := io.mode32
                state := sCAL
                valid := false.B
            }
            is (sCAL) {
                mid_result(0) := op1(31, 0) * op2(31, 0)
                mid_result(1) := op1(63,32) * op2(31, 0)
                mid_result(2) := op1(31, 0) * op2(63,32)
                mid_result(3) := op1(63,32) * op2(63,32)
                state := sFINAL
                valid := false.B
            }
            is (sFINAL) {
                val final_u = (mid_result(3) << 64) + (mid_result(2) << 32) + (mid_result(1) << 32) + mid_result(0)
                var final_s = Mux(outsign,-(final_u.asSInt),final_u.asSInt)
                out := Mux(out32, Mux(outhigh,final_s(63,32),final_s(32,0)) , Mux(outhigh,final_s(127,64),final_s(63,0)) ).asSInt
                valid := true.B
                state := sIDLE
            }
        }
    }.otherwise {
        state := sIDLE
        valid := false.B
    }
}