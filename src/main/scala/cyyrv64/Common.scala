package cyyrv64

import chisel3._
import chisel3.experimental.ChiselEnum

object ALUOpSel extends ChiselEnum {
    val nop, add, sub, sll, slt, sltu, xor, srl, sra, or, and = Value
}