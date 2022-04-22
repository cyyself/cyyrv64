package cyyrv64

import chisel3._
import chisel3.util._
import chisel3.experimental.ChiselEnum

object pageSize extends ChiselEnum {
    val Invalid = Value(0.U)
    val SZ_4K, SZ_2M, SZ_1G = Value
}

class TLBEntry extends Bundle {
    val vpn = UInt(27.W)
    val ppn = UInt(44.W)
    val D = Bool()
    val A = Bool()
    val U = Bool()
    val X = Bool()
    val W = Bool()
    val R = Bool()
    val V = Bool()

    val size = pageSize()

    def query(va : UInt): (Bool, UInt) = {
        val ok = false.B
        val pa = 0.U
        switch (size) {
            is (pageSize.SZ_4K) {
                ok := va(63,12).asSInt === vpn.asSInt
                pa := Cat(ppn,va(11,0)).asUInt
            }
            is (pageSize.SZ_2M) {
                ok := va(63,21).asSInt === vpn(26,9).asSInt
                pa := Cat(ppn(43,9),va(20,0)).asUInt
            }
            is (pageSize.SZ_1G) {
                ok := va(63,30).asSInt === vpn(26,18).asSInt
                pa := Cat(ppn(43,18),va(29,0)).asUInt
            }
        }
        (ok, pa)
    }

    def invalidate(): Unit = {
        size := pageSize.Invalid
    }

    def fromPTE(pte: UInt, va: UInt, pgsize: pageSize.Type): Unit = {
        when (pte(0)) { // Valid
            D := pte(7)
            A := pte(6)
            U := pte(4)
            X := pte(3)
            W := pte(2)
            R := pte(1)
            // PTW should check PPN zero for large Page before call this function to write TLB
            ppn := pte(53,10)
            size := pgsize
            switch (pgsize) {
                is (pageSize.SZ_4K) {
                    vpn := va(38,12)
                }
                is (pageSize.SZ_2M) {
                    vpn := Cat(va(38,21),0.U(9.W))
                }
                is (pageSize.SZ_1G) {
                    vpn := Cat(va(38,30),0.U(18.W))
                }
            }
        }
    }

    def ifCheck(privMode: RVPrivMode.Type): Bool = { // return false should raise page fault
        // Note: mprv didn't affect instr fetch.
        val priv_ok = false.B
        switch (privMode) {
            is (RVPrivMode.User) {
                priv_ok := U
            }
            is (RVPrivMode.Supervisor) {
                priv_ok := !U
            }
            is (RVPrivMode.Machine) {
                assert(false, "Should not check permission when M Mode")
            }
        }
        A && X && priv_ok
    }

    def lsCheck(privMode: RVPrivMode.Type, write: Bool, mxr: Bool, sum: Bool): Bool = {
        // Note: privMode should be value after mprv
        val priv_ok = false.B
        val read_permit = R || (mxr && X)
        val write_permit = D && W
        switch (privMode) {
            is (RVPrivMode.User) {
                priv_ok := U
            }
            is (RVPrivMode.Supervisor) {
                priv_ok := !U || sum
            }
            is (RVPrivMode.Machine) {
                assert(false, "Should not check permission when M Mode or mprv to M Mode")
            }
        }
        A && priv_ok && Mux(write,write_permit,read_permit)
    }
}
