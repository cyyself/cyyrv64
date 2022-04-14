package cyyrv64

import chisel3._
import chisel3.util._

class ALUPort extends Bundle {
    val in1 = Input(SInt(64.W))
    val in2 = Input(SInt(64.W))
    val aluOp = Input(ALUOpSel())
    val mode32 = Input(Bool())
    val out = Output(SInt(64.W))
}

class ALU extends Module {
    val io = IO(new ALUPort)

    val in1 = Wire(SInt(64.W))
    in1 := Mux(io.mode32,io.in1(31,0).asSInt,io.in1)
    val in2 = Wire(SInt(64.W))
    in2 := Mux(io.mode32,io.in2(31,0).asSInt,io.in2)

    val shift = Mux(io.mode32,Cat("b0".U,io.in2(4,0)),io.in2(5,0))

    val result = Wire(SInt(64.W))
    result := 0.S // init with 0

    switch (io.aluOp) {
        is (ALUOpSel.add) {
            result := in1 + in2
        }
        is (ALUOpSel.sub) {
            result := in1 - in2
        }
        is (ALUOpSel.sll) {
            result := in1 << shift
        }
        is (ALUOpSel.slt) {
            result := (in1 < in2).asSInt
        }
        is (ALUOpSel.sltu) {
            result := (in1.asUInt < in2.asUInt).asSInt
        }
        is (ALUOpSel.xor) {
            result := in1 ^ in2
        }
        is (ALUOpSel.srl) {
            result := (in1.asUInt >> shift).asSInt
        }
        is (ALUOpSel.sra) {
            result := in1 >> shift
        }
        is (ALUOpSel.or) {
            result := in1 | in2
        }
        is (ALUOpSel.and) {
            result := in1 & in2
        }
    }

    io.out := Mux(io.mode32,result(31,0).asSInt, result)
}