package cyyrv64

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec
import chisel3.experimental.BundleLiterals._
import chisel3.experimental.ChiselEnum

class MulTest extends AnyFlatSpec with ChiselScalatestTester {
    behavior of "Mul"
    def test_mul(op: MulOpSel.Type, out: Long, in1: Long, in2: Long, mode32: Bool = false.B) = {
        it should "%s%s(%d,%d)==%d".format(op.toString(),(if (mode32.litToBoolean) "w" else ""),in1,in2,out) in {
            test(new Mul) { mul =>
                mul.io.in1.poke(in1)
                mul.io.in2.poke(in2)
                mul.io.en.poke(true.B)
                mul.io.mulOp.poke(op)
                mul.io.mode32.poke(mode32)
                mul.io.out_ready.poke(true.B)
                mul.clock.step()
                mul.io.out_valid.expect(false.B)
                mul.clock.step()
                mul.io.out_valid.expect(false.B)
                mul.clock.step()
                mul.io.out_valid.expect(true.B)
                mul.io.out.expect(out)
                mul.io.en.poke(false.B)
                mul.clock.step()
                mul.io.out_valid.expect(false.B)
                mul.clock.step()
                mul.io.out_valid.expect(false.B)
                mul.clock.step()
                mul.io.out_valid.expect(false.B)
                mul.clock.step()
                mul.io.out_valid.expect(false.B)
            }
        }
    }

    test_mul( MulOpSel.mul, 0x0000000000001200L, 0x0000000000007e00L, 0x6db6db6db6db6db7L );
    test_mul( MulOpSel.mul, 0x0000000000001240L, 0x0000000000007fc0L, 0x6db6db6db6db6db7L );

    test_mul( MulOpSel.mul, 0x00000000, 0x00000000, 0x00000000 );
    test_mul( MulOpSel.mul, 0x00000001, 0x00000001, 0x00000001 );
    test_mul( MulOpSel.mul, 0x00000015, 0x00000003, 0x00000007 );

    test_mul( MulOpSel.mul, 0x0000000000000000L, 0x0000000000000000L, 0xffffffffffff8000L );
    test_mul( MulOpSel.mul, 0x0000000000000000L, 0xffffffff80000000L, 0x00000000L );
    test_mul( MulOpSel.mul, 0x0000400000000000L, 0xffffffff80000000L, 0xffffffffffff8000L );

    test_mul( MulOpSel.mul, 0x000000000000ff7fL, 0xaaaaaaaaaaaaaaabL, 0x000000000002fe7dL );
    test_mul( MulOpSel.mul, 0x000000000000ff7fL, 0x000000000002fe7dL, 0xaaaaaaaaaaaaaaabL );

    test_mul( MulOpSel.mul, 143 , 13, 11 );
    test_mul( MulOpSel.mul, 154 , 14, 11 );
    test_mul( MulOpSel.mul, 169 , 13, 13 );

    test_mul( MulOpSel.mulh, 0x00000000, 0x00000000, 0x00000000 );
    test_mul( MulOpSel.mulh, 0x00000000, 0x00000001, 0x00000001 );
    test_mul( MulOpSel.mulh, 0x00000000, 0x00000003, 0x00000007 );

    test_mul( MulOpSel.mulh, 0x0000000000000000L, 0x0000000000000000L, 0xffffffffffff8000L );
    test_mul( MulOpSel.mulh, 0x0000000000000000L, 0xffffffff80000000L, 0x00000000L );
    test_mul( MulOpSel.mulh, 0x0000000000000000L, 0xffffffff80000000L, 0xffffffffffff8000L );

    test_mul( MulOpSel.mulh, 143, 13L<<32, 11L<<32 );
    test_mul( MulOpSel.mulh, 154, 14L<<32, 11L<<32 );
    test_mul( MulOpSel.mulh, 169, 13L<<32, 13L<<32 );

    test_mul( MulOpSel.mulhsu, 0x00000000, 0x00000000, 0x00000000 );
    test_mul( MulOpSel.mulhsu, 0x00000000, 0x00000001, 0x00000001 );
    test_mul( MulOpSel.mulhsu, 0x00000000, 0x00000003, 0x00000007 );

    test_mul( MulOpSel.mulhsu, 0x0000000000000000L, 0x0000000000000000L, 0xffffffffffff8000L );
    test_mul( MulOpSel.mulhsu, 0x0000000000000000L, 0xffffffff80000000L, 0x00000000L );
    test_mul( MulOpSel.mulhsu, 0xffffffff80000000L, 0xffffffff80000000L, 0xffffffffffff8000L );

    test_mul( MulOpSel.mulhsu, 143, 13L<<32, 11L<<32 );
    test_mul( MulOpSel.mulhsu, 154, 14L<<32, 11L<<32 );
    test_mul( MulOpSel.mulhsu, 169, 13L<<32, 13L<<32 );

    test_mul( MulOpSel.mulhu, 0x00000000, 0x00000000, 0x00000000 );
    test_mul( MulOpSel.mulhu, 0x00000000, 0x00000001, 0x00000001 );
    test_mul( MulOpSel.mulhu, 0x00000000, 0x00000003, 0x00000007 );

    test_mul( MulOpSel.mulhu, 0x0000000000000000L, 0x0000000000000000L, 0xffffffffffff8000L );
    test_mul( MulOpSel.mulhu, 0x0000000000000000L, 0xffffffff80000000L, 0x00000000L );
    test_mul( MulOpSel.mulhu, 0xffffffff7fff8000L, 0xffffffff80000000L, 0xffffffffffff8000L );

    test_mul( MulOpSel.mulhu, 0x000000000001fefeL, 0xaaaaaaaaaaaaaaabL, 0x000000000002fe7dL );
    test_mul( MulOpSel.mulhu, 0x000000000001fefeL, 0x000000000002fe7dL, 0xaaaaaaaaaaaaaaabL );

    test_mul( MulOpSel.mulhu, 143, 13L<<32, 11L<<32 );
    test_mul( MulOpSel.mulhu, 154, 14L<<32, 11L<<32 );
    test_mul( MulOpSel.mulhu, 169, 13L<<32, 13L<<32 );

    test_mul( MulOpSel.mul, 0x00000000, 0x00000000, 0x00000000, true.B );
    test_mul( MulOpSel.mul, 0x00000001, 0x00000001, 0x00000001, true.B );
    test_mul( MulOpSel.mul, 0x00000015, 0x00000003, 0x00000007, true.B );

    test_mul( MulOpSel.mul, 0x0000000000000000L, 0x0000000000000000L, 0xffffffffffff8000L, true.B );
    test_mul( MulOpSel.mul, 0x0000000000000000L, 0xffffffff80000000L, 0x00000000L, true.B );
    test_mul( MulOpSel.mul, 0x0000000000000000L, 0xffffffff80000000L, 0xffffffffffff8000L, true.B );

    test_mul( MulOpSel.mul, 143 , 13, 11, true.B );
    test_mul( MulOpSel.mul, 154 , 14, 11, true.B );
    test_mul( MulOpSel.mul, 169 , 13, 13, true.B );
}