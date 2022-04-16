package cyyrv64

import chisel3._
import chisel3.experimental.ChiselEnum

object ALUOpSel extends ChiselEnum {
    val nop, add, sub, sll, slt, sltu, xor, srl, sra, or, and = Value
}

object MulOpSel extends ChiselEnum {
    val nop, mul, mulh, mulhu, mulhsu = Value
}

object DivOpSel extends ChiselEnum {
    val nop, div, divu, rem, remu = Value
}