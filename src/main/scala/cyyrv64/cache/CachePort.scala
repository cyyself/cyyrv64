package cyyrv64

import chisel3._
import chisel3.util._

// L1 to L2
object L2ReqType extends ChiselEnum {
    val read, read_through, write_shared, write_back, acq_modified = Value
}
/* 
    read            -> acquire shared
    read_through    -> read from L2 but didn't acquire any status. e.g. I Cache and DMA read and MMIO read
    write_shared    -> release modified but keep shared
    wirte_back      -> release modified and shared. (Also used for DMA device and MMIO request from core)

    Note: acq_modified is used for amo operations
 */
                               
// L2 to L1
object COReqType extends ChiselEnum {
    val rel_shared, rel_modified = Value
}

class L2DataChannel extends Bundle {
    val reqType = Output(L2ReqType())
    val reqAddr = Output(UInt(64.W))
    val reqSize = Output(UInt(6.W)) // Bytes - 1
    val reqValid = Output(Bool())
    val reqReady = Input(Bool())
    val rData = Input(UInt(64.W))
    val wData = Output(UInt(64.W))
    val wstrb = Output(8.W)
    val rValid = Input(Bool())
    val rReady = Output(Bool())
    val wValid = Output(Bool())
    val wReady = Input(Bool())
}

class L2ConherenceChannel extends Bundle {
    val reqType = Input(COReqType())
    val reqAddr = Input(UInt(64.W))
    val reqValid = Input(Bool())
    val reqReady = Output(Bool())
}