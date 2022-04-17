package cyyrv64

import chisel3._
import chisel3.util._

class BranchPort extends Bundle {
    val in1 = Input(SInt(64.W))
    val in2 = Input(SInt(64.W))
    val branchOp = Input(BranchOpSel())
    val branch = Output(Bool())
}

class Branch extends Module {
    val io = IO(new BranchPort)

    val in1 = io.in1
    val in2 = io.in2

    io.branch := false.B

    switch (io.branchOp) {
        is (BranchOpSel.beq) {
            io.branch := in1 === in2
        }
        is (BranchOpSel.bne) {
            io.branch := in1 =/= in2
        }
        is (BranchOpSel.blt) {
            io.branch := in1 < in2
        }
        is (BranchOpSel.bge) {
            io.branch := in1 >= in2
        }
        is (BranchOpSel.bltu) {
            io.branch := in1.asUInt < in2.asUInt
        }
        is (BranchOpSel.bgeu) {
            io.branch := in1.asUInt >= in2.asUInt
        }
    }
}