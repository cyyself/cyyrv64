package cyyrv64

import chisel3._
import chisel3.util._

class IFCtrl extends Bundle {
    val ready = Output(Bool())
    val IFUBusy = Input(Bool())
}

class IDCtrl extends Bundle {
    val ready = Output(Bool())
    val rsBusy = Input(Bool())
}

class EXECtrl extends Bundle {
    val ready = Output(Bool())
    val useMem = Input(Bool())
    val unitBusy = Input(Bool()) // Mul and Div
}

class MEMCtrl extends Bundle {
    val ready       = Output(Bool())
    val useBranch   = Input(Bool())
    val CSRBusy     = Input(Bool())
    val LSUBusy     = Input(Bool())
}
// Warn: LSUBusy => CSRBusy => useBranch could happens when page fault

class ctrl extends Module {
    val io = IO(new Bundle {
        val toIF  = new IFCtrl()
        val toID  = new IDCtrl()
        val toEXE = new EXECtrl()
        val toMEM = new MEMCtrl()
    })
}