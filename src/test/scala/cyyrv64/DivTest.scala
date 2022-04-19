package cyyrv64

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec
import chisel3.experimental.BundleLiterals._
import chisel3.experimental.ChiselEnum

class DivTest extends AnyFlatSpec with ChiselScalatestTester {
    behavior of "Div"
    def test_div(op: DivOpSel.Type, out: Long, in1: Long, in2: Long, mode32: Bool = false.B) = {
        it should "%s%s(%d,%d)==%d".format(op.toString(),(if (mode32.litToBoolean) "w" else ""),in1,in2,out) in {
            test(new Div) { div =>
                div.io.in1.poke(in1)
                div.io.in2.poke(in2)
                div.io.en.poke(true.B)
                div.io.divOp.poke(op)
                div.io.mode32.poke(mode32)
                div.io.out_ready.poke(true.B)
                div.clock.step()
                var timeout = 100
                while (!div.io.out_valid.peekBoolean()) {
                    timeout = timeout - 1
                    assert(timeout > 0)
                    div.clock.step()
                }
                div.io.out.expect(out)
            }
        }
    }
    
    // risc-v test div
    test_div(DivOpSel.div,  3,  20,   6 );
    test_div(DivOpSel.div, -3, -20,   6 );
    test_div(DivOpSel.div, -3,  20,  -6 );
    test_div(DivOpSel.div,  3, -20,  -6 );

    test_div(DivOpSel.div, -1L<<63, -1L<<63,  1 );
    test_div(DivOpSel.div, -1L<<63, -1L<<63, -1 );

    test_div(DivOpSel.div, -1, -1L<<63, 0 );
    test_div(DivOpSel.div, -1,      1, 0 );
    test_div(DivOpSel.div, -1,      0, 0 );

    // risc-v test divu
    test_div(DivOpSel.divu,                   3,  20,   6 );
    test_div(DivOpSel.divu, 3074457345618258599L, -20,   6 );
    test_div(DivOpSel.divu,                   0,  20,  -6 );
    test_div(DivOpSel.divu,                   0, -20,  -6 );

    test_div(DivOpSel.divu, -1L<<63, -1L<<63,  1 );
    test_div(DivOpSel.divu,     0,  -1L<<63, -1 );

    test_div(DivOpSel.divu, -1, -1L<<63, 0 );
    test_div(DivOpSel.divu, -1,      1, 0 );
    test_div(DivOpSel.divu, -1,      0, 0 );

    // risc-v test divuw
    test_div(DivOpSel.divu,         3,  20,   6, true.B );
    test_div(DivOpSel.divu, 715827879, -20L << 32 >> 32,   6, true.B );
    test_div(DivOpSel.divu,         0,  20,  -6, true.B );
    test_div(DivOpSel.divu,         0, -20,  -6, true.B );

    test_div(DivOpSel.divu, -1L<<31, -1L<<31,  1, true.B );
    test_div(DivOpSel.divu, 0,      -1L<<31, -1, true.B );

    test_div(DivOpSel.divu, -1, -1L<<31, 0, true.B );
    test_div(DivOpSel.divu, -1,      1, 0, true.B );
    test_div(DivOpSel.divu, -1,      0, 0, true.B );

    // risc-v test divw
    test_div(DivOpSel.div,  3,  20,   6, true.B );
    test_div(DivOpSel.div, -3, -20,   6, true.B );
    test_div(DivOpSel.div, -3,  20,  -6, true.B );
    test_div(DivOpSel.div,  3, -20,  -6, true.B );

    test_div(DivOpSel.div, -1L<<31, -1L<<31,  1, true.B );
    test_div(DivOpSel.div, -1L<<31, -1L<<31, -1, true.B );

    test_div(DivOpSel.div, -1, -1L<<31, 0, true.B );
    test_div(DivOpSel.div, -1,      1, 0, true.B );
    test_div(DivOpSel.div, -1,      0, 0, true.B );
    
    // risc-v test rem
    test_div(DivOpSel.rem,  2,  20,   6 );
    test_div(DivOpSel.rem, -2, -20,   6 );
    test_div(DivOpSel.rem,  2,  20,  -6 );
    test_div(DivOpSel.rem, -2, -20,  -6 );

    test_div(DivOpSel.rem,  0, -1L<<63,  1 );
    test_div(DivOpSel.rem,  0, -1L<<63, -1 );

    test_div(DivOpSel.rem, -1L<<63, -1L<<63, 0 );
    test_div(DivOpSel.rem,      1,      1, 0 );
    test_div(DivOpSel.rem,      0,      0, 0 );

    // risc-v test remu
    test_div(DivOpSel.remu,   2,  20,   6 );
    test_div(DivOpSel.remu,   2, -20,   6 );
    test_div(DivOpSel.remu,  20,  20,  -6 );
    test_div(DivOpSel.remu, -20, -20,  -6 );

    test_div(DivOpSel.remu,      0, -1L<<63,  1 );
    test_div(DivOpSel.remu, -1L<<63, -1L<<63, -1 );

    test_div(DivOpSel.remu, -1L<<63, -1L<<63, 0 );
    test_div(DivOpSel.remu,      1,      1, 0 );
    test_div(DivOpSel.remu,      0,      0, 0 );

    // risc-v test remuw
    test_div(DivOpSel.remu,   2,  20,   6, true.B );
    test_div(DivOpSel.remu,   2, -20,   6, true.B );
    test_div(DivOpSel.remu,  20,  20,  -6, true.B );
    test_div(DivOpSel.remu, -20, -20,  -6, true.B );

    test_div(DivOpSel.remu,      0, -1L<<31,  1, true.B );
    test_div(DivOpSel.remu, -1L<<31, -1L<<31, -1, true.B );

    test_div(DivOpSel.remu, -1L<<31, -1L<<31, 0, true.B );
    test_div(DivOpSel.remu,      1,      1, 0, true.B );
    test_div(DivOpSel.remu,      0,      0, 0, true.B );

    // risc-v test remw
    test_div(DivOpSel.rem,  2,  20,   6, true.B );
    test_div(DivOpSel.rem, -2, -20,   6, true.B );
    test_div(DivOpSel.rem,  2,  20,  -6, true.B );
    test_div(DivOpSel.rem, -2, -20,  -6, true.B );

    test_div(DivOpSel.rem,  0, -1L<<31,  1, true.B );
    test_div(DivOpSel.rem,  0, -1L<<31, -1, true.B );

    test_div(DivOpSel.rem, -1L<<31, -1L<<31, 0, true.B );
    test_div(DivOpSel.rem,      1,      1, 0, true.B );
    test_div(DivOpSel.rem,      0,      0, 0, true.B );
    test_div(DivOpSel.rem, 0xfffffffffffff897L,0xfffffffffffff897L, 0, true.B );
} 