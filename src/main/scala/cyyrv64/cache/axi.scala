package cyyrv64

import chisel3._
import chisel3.util._

object AxiDef {
    object Burst {
        val FIXED = 0
        val INCR = 1
        val WRAP = 2
        val RESERVED = 3
    }
    object Resp {
        val OKEY = 0
        val EXOKEY = 1
        val SLVERR = 2
        val DECERR = 3
    }
}

class AxiPort(val addrWidth: Int = 64, val dataWidth: Int = 64, val idWidth: Int = 4) extends Bundle {
    // aw channel
    val awid = Output(UInt(idWidth.W))
    val awaddr = Output(UInt(addrWidth.W))
    val awlen = Output(UInt(8.W))
    val awsize = Output(UInt(3.W))
    val awburst = Output(UInt(2.W))
    val awvalid = Output(Bool())
    val awready = Input(Bool())
    // w channel
    val wdata = Output(UInt(dataWidth.W))
    val wstrb = Output(UInt((dataWidth/8).W))
    val wlast = Output(Bool())
    val wvalid = Output(Bool())
    val wready = Input(Bool())
    // b channel
    val bid = Input(UInt(idWidth.W))
    val bresp = Input(UInt(2.W))
    val bvalid = Input(Bool())
    val bready = Output(Bool())
    // ar channel
    val arid = Output(UInt(idWidth.W))
    val araddr = Output(UInt(addrWidth.W))
    val arlen = Output(UInt(8.W))
    val arsize = Output(UInt(3.W))
    val arburst = Output(UInt(2.W))
    val arvalid = Output(Bool())
    val arready = Input(Bool())
    // r channel
    val rid = Input(UInt(idWidth.W))
    val rdata = Input(UInt(dataWidth.W))
    val rresp = Input(UInt(2.W))
    val rlast = Input(Bool())
    val rvalid = Input(Bool())
    val rready = Output(Bool())
}