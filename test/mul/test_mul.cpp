#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vmul.h"
#include <cstdio>
#include <string>
#include <random>
#include <climits>

uint64_t timer = 0;

enum mul_op {
    MUL,
    MULH,
    MULHU,
    MULHSU
};

struct mul_test_item {
    mul_op op;
    int64_t out;
    int64_t in1;
    int64_t in2;
    bool is_32bit;
    mul_test_item(mul_op op, int64_t out, int64_t in1, int64_t in2, bool is_32bit = false)
        :op(op),out(out),in1(in1),in2(in2),is_32bit(is_32bit) {}
};

bool test_mul(Vmul *dut, VerilatedVcdC &vcd, mul_op op, int64_t out, int64_t in1, int64_t in2, bool is_32bit, bool silent = false) {
    // assume dut->clock == 1
    // poke input
    dut->in1 = in1;
    dut->in2 = in2;
    dut->mul_word = is_32bit;
    dut->op = op;
    dut->en = 1;
    int timeout = 1000;
    while (timeout) {
        dut->clock = !dut->clock;
        dut->eval();
        if (!silent) vcd.dump(timer++);
        if (dut->out_valid) {
            int64_t dut_out = dut->out;
            bool stat = dut_out == out;
            // set to next posedge
            dut->clock = !dut->clock;
            dut->eval();
            if (!silent) vcd.dump(timer++);
            dut->clock = !dut->clock;
            dut->eval();
            if (!silent) vcd.dump(timer++);
            if (!silent) {
                if (stat)
                    printf("[ PASS ] Test Mul (in1=%016llx,in2=%016llx,expect_out=%016llx,mode=%d,32bit=%d)\n", 
                                                       in1,        in2,               out,     op, is_32bit);
                else
                    printf("\033[0;31m[FAILED] Test Mul (in1=%016llx,in2=%016llx,expect_out=%016llx,mode=%d,32bit=%d) got %016llx!\033[0m\n", 
                                                                 in1,        in2,               out,     op, is_32bit,    dut_out);
            }
            return stat;
        }
        timeout--;
    }
    if (!silent) {
        printf("\033[0;31m[FAILED] Test Mul (in1=%016llx,in2=%016llx,expect_out=%016llx,mode=%d,32bit=%d) Timeout!\033[0m\n", 
                                                     in1,        in2,               out,     op, is_32bit);
    }
    return false;
}

int64_t golden_mul(mul_op op, int64_t a, int64_t b, bool is_32bit) {
    if (is_32bit) {
        a = (int32_t)a;
        b = (int32_t)b;
    }
    int64_t result = 0;
    switch (op) {
        case MUL:
            result = a * b;
            break;
        case MULH: {
            result = ((__int128_t)a*(__int128_t)b) >> 64;
            break;
        }
        case MULHU: 
            result = (static_cast<__uint128_t>(static_cast<uint64_t>(a))*static_cast<__uint128_t>(static_cast<uint64_t>(b))) >> 64;
            break;
        case MULHSU:
            result = (static_cast<__int128_t>(a)*static_cast<__uint128_t>(static_cast<uint64_t>(b))) >> 64;
            break;
        default:
            assert(false);
    }
    if (is_32bit) result = (int32_t)result;
    return result;
}

bool random_test(Vmul *dut, VerilatedVcdC &vcd, uint64_t size) {
    std::mt19937_64 rng;
    bool test_failed = false;
    while (size--) {
        int64_t a = rng();
        int64_t b = rng();
        for (int i=0;i<4 && !test_failed;i++) {
            int64_t expect_out = golden_mul(static_cast<mul_op>(i), a, b, false);
            test_failed |= !test_mul(dut, vcd, static_cast<mul_op>(i), expect_out, a, b, false, true);
            if (test_failed) {
                printf("\033[0;31m[FAILED] Test mul (in1=%016llx,in2=%016llx,expect_out=%016llx,mode=%d,32bit=%d) Manually test this to see what happend!\033[0m\n", 
                                                                a,          b,        expect_out,      i,       0);
            }
            else if (i == 0) { // only mul has 32-bit version mulw
                int64_t expect_out = golden_mul(static_cast<mul_op>(i), a, b, true);
                test_failed |= !test_mul(dut, vcd, static_cast<mul_op>(i), expect_out, a, b, true, true);
                if (test_failed) {
                    printf("\033[0;31m[FAILED] Test mul (in1=%016llx,in2=%016llx,expect_out=%016llx,mode=%d,32bit=%d) Manually test this to see what happend!\033[0m\n", 
                                                                    a,          b,        expect_out,      i,       1);
                }
            }
        }
    }
    return !test_failed;
}

bool do_riscv_test(Vmul *dut, VerilatedVcdC &vcd) {
    mul_test_item mul_test[] = {
        mul_test_item(MUL, 0x0000000000001200LL, 0x0000000000007e00LL, 0x6db6db6db6db6db7LL ),
        mul_test_item(MUL, 0x0000000000001240LL, 0x0000000000007fc0LL, 0x6db6db6db6db6db7LL ),

        mul_test_item(MUL, 0x00000000, 0x00000000, 0x00000000 ),
        mul_test_item(MUL, 0x00000001, 0x00000001, 0x00000001 ),
        mul_test_item(MUL, 0x00000015, 0x00000003, 0x00000007 ),

        mul_test_item(MUL, 0x0000000000000000LL, 0x0000000000000000LL, 0xffffffffffff8000LL ),
        mul_test_item(MUL, 0x0000000000000000LL, 0xffffffff80000000LL, 0x00000000LL ),
        mul_test_item(MUL, 0x0000400000000000LL, 0xffffffff80000000LL, 0xffffffffffff8000LL ),

        mul_test_item(MUL, 0x000000000000ff7fLL, 0xaaaaaaaaaaaaaaabLL, 0x000000000002fe7dLL ),
        mul_test_item(MUL, 0x000000000000ff7fLL, 0x000000000002fe7dLL, 0xaaaaaaaaaaaaaaabLL ),

        mul_test_item(MUL, 143 , 13, 11 ),
        mul_test_item(MUL, 154 , 14, 11 ),
        mul_test_item(MUL, 169 , 13, 13 ),

        mul_test_item(MULH, 0x00000000, 0x00000000, 0x00000000 ),
        mul_test_item(MULH, 0x00000000, 0x00000001, 0x00000001 ),
        mul_test_item(MULH, 0x00000000, 0x00000003, 0x00000007 ),

        mul_test_item(MULH, 0x0000000000000000LL, 0x0000000000000000LL, 0xffffffffffff8000LL ),
        mul_test_item(MULH, 0x0000000000000000LL, 0xffffffff80000000LL, 0x00000000LL ),
        mul_test_item(MULH, 0x0000000000000000LL, 0xffffffff80000000LL, 0xffffffffffff8000LL ),

        mul_test_item(MULH, 143, 13LL<<32, 11LL<<32 ),
        mul_test_item(MULH, 154, 14LL<<32, 11LL<<32 ),
        mul_test_item(MULH, 169, 13LL<<32, 13LL<<32 ),

        mul_test_item(MULHSU, 0x00000000, 0x00000000, 0x00000000 ),
        mul_test_item(MULHSU, 0x00000000, 0x00000001, 0x00000001 ),
        mul_test_item(MULHSU, 0x00000000, 0x00000003, 0x00000007 ),

        mul_test_item(MULHSU, 0x0000000000000000LL, 0x0000000000000000LL, 0xffffffffffff8000LL ),
        mul_test_item(MULHSU, 0x0000000000000000LL, 0xffffffff80000000LL, 0x00000000LL ),
        mul_test_item(MULHSU, 0xffffffff80000000LL, 0xffffffff80000000LL, 0xffffffffffff8000LL ),

        mul_test_item(MULHSU, 143, 13LL<<32, 11LL<<32 ),
        mul_test_item(MULHSU, 154, 14LL<<32, 11LL<<32 ),
        mul_test_item(MULHSU, 169, 13LL<<32, 13LL<<32 ),

        mul_test_item(MULHU, 0x00000000, 0x00000000, 0x00000000 ),
        mul_test_item(MULHU, 0x00000000, 0x00000001, 0x00000001 ),
        mul_test_item(MULHU, 0x00000000, 0x00000003, 0x00000007 ),

        mul_test_item(MULHU, 0x0000000000000000LL, 0x0000000000000000LL, 0xffffffffffff8000LL ),
        mul_test_item(MULHU, 0x0000000000000000LL, 0xffffffff80000000LL, 0x00000000LL ),
        mul_test_item(MULHU, 0xffffffff7fff8000LL, 0xffffffff80000000LL, 0xffffffffffff8000LL ),

        mul_test_item(MULHU, 0x000000000001fefeLL, 0xaaaaaaaaaaaaaaabLL, 0x000000000002fe7dLL ),
        mul_test_item(MULHU, 0x000000000001fefeLL, 0x000000000002fe7dLL, 0xaaaaaaaaaaaaaaabLL ),

        mul_test_item(MULHU, 143, 13LL<<32, 11LL<<32 ),
        mul_test_item(MULHU, 154, 14LL<<32, 11LL<<32 ),
        mul_test_item(MULHU, 169, 13LL<<32, 13LL<<32 ),

        mul_test_item(MUL, 0x00000000, 0x00000000, 0x00000000, true ),
        mul_test_item(MUL, 0x00000001, 0x00000001, 0x00000001, true ),
        mul_test_item(MUL, 0x00000015, 0x00000003, 0x00000007, true ),

        mul_test_item(MUL, 0x0000000000000000LL, 0x0000000000000000LL, 0xffffffffffff8000LL, true ),
        mul_test_item(MUL, 0x0000000000000000LL, 0xffffffff80000000LL, 0x00000000LL, true ),
        mul_test_item(MUL, 0x0000000000000000LL, 0xffffffff80000000LL, 0xffffffffffff8000LL, true ),

        mul_test_item(MUL, 143 , 13, 11, true ),
        mul_test_item(MUL, 154 , 14, 11, true ),
        mul_test_item(MUL, 169 , 13, 13, true )
    };
    bool test_failed = false;
    for (mul_test_item each_item : mul_test) {
        test_failed |= !test_mul(dut, vcd, each_item.op, each_item.out, each_item.in1, each_item.in2, each_item.is_32bit);
        if (test_failed) break;
    }
    return !test_failed;
}

int main(int argc, char **argv, char **env) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);
    Vmul *dut = new Vmul;
    VerilatedVcdC vcd;
    dut->trace(&vcd, 0);
    vcd.open("trace.vcd");
    dut->reset = 1;
    dut->clock = 1;
    dut->in1 = 0;
    dut->in2 = 0;
    dut->mul_word = 0;
    dut->en = 0;
    dut->op = 0;
    dut->out_ready = 1;
    dut->eval();
    for (int i = 0; i < 10; i++) {
        dut->clock = !dut->clock;
        dut->eval();
        vcd.dump(timer++);
    }
    dut->reset = 0;
    bool test_ok = do_riscv_test(dut, vcd) && random_test(dut, vcd, 1000);
    dut->final();
    vcd.close();
    return !test_ok;
}