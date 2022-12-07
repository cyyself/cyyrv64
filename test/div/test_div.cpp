#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vdiv.h"
#include <cstdio>
#include <string>
#include <random>
#include <climits>

uint64_t timer = 0;

enum div_op {
    DIV,
    DIVU,
    REM,
    REMU
};

struct div_test_item {
    div_op op;
    int64_t out;
    int64_t in1;
    int64_t in2;
    bool is_32bit;
    div_test_item(div_op op, int64_t out, int64_t in1, int64_t in2, bool is_32bit = false)
        :op(op),out(out),in1(in1),in2(in2),is_32bit(is_32bit) {}
};

bool test_div(Vdiv *dut, VerilatedVcdC &vcd, div_op op, int64_t out, int64_t in1, int64_t in2, bool is_32bit, bool silent = false) {
    // assume dut->clock == 1
    // poke input
    dut->in1 = in1;
    dut->in2 = in2;
    dut->div_word = is_32bit;
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
                    printf("[ PASS ] Test Div (in1=%016llx,in2=%016llx,expect_out=%016llx,mode=%d,32bit=%d)\n", 
                                                       in1,        in2,               out,     op, is_32bit);
                else
                    printf("\033[0;31m[FAILED] Test Div (in1=%016llx,in2=%016llx,expect_out=%016llx,mode=%d,32bit=%d) got %016llx!\033[0m\n", 
                                                                 in1,        in2,               out,     op, is_32bit,    dut_out);
            }
            return stat;
        }
        timeout--;
    }
    if (!silent) {
        printf("\033[0;31m[FAILED] Test Div (in1=%016llx,in2=%016llx,expect_out=%016llx,mode=%d,32bit=%d) Timeout!\033[0m\n", 
                                                     in1,        in2,               out,     op, is_32bit);
    }
    return false;
}

int64_t golden_div(div_op op, int64_t a, int64_t b, bool is_32bit = false) {
    if (is_32bit) {
        a = (int32_t)a;
        b = (int32_t)b;
    }
    int64_t result = 0;
    switch (op) {
        case DIV:
            if (b == 0) result = -1;
            else if (a == LONG_MIN && b == -1) result = LONG_MIN;
            else result = a / b;
            break;
        case DIVU:
            if (b == 0) result = ULONG_MAX;
            else if (is_32bit) result = (uint32_t)a / (uint32_t)b;
            else result = ((uint64_t)a) / ((uint64_t)b);
            break;
        case REM:
            if (b == 0) result = a;
            else if (a == LONG_MIN && b == -1) result = 0;
            else result = a % b;
            break;
        case REMU:
            if (b == 0) result = a;
            else if (is_32bit) result = (uint32_t)a % (uint32_t)b;
            else result = (uint64_t)a % (uint64_t)b;
            break;
        default:
            assert(false);
    }
    if (is_32bit) result = (int32_t)result;
    return result;
}

bool random_test(Vdiv *dut, VerilatedVcdC &vcd, uint64_t size) {
    std::mt19937_64 rng;
    bool test_failed = false;
    while (size--) {
        int64_t a = rng();
        int64_t b = rng();
        for (int i=0;i<4 && !test_failed;i++) {
            for (int j=0;j<2 && !test_failed;j++) {
                int64_t expect_out = golden_div(static_cast<div_op>(i), a, b, j);
                test_failed |= !test_div(dut, vcd, static_cast<div_op>(i), expect_out, a, b, j, true);
                if (test_failed) {
                    printf("\033[0;31m[FAILED] Test Div (in1=%016llx,in2=%016llx,expect_out=%016llx,mode=%d,32bit=%d) Manually test this to see what happend!\033[0m\n", 
                                                                   a,          b,        expect_out,      i,       j);
                }
            }
        }
    }
    return !test_failed;
}

bool do_riscv_test(Vdiv *dut, VerilatedVcdC &vcd) {
    div_test_item div_test[] = {
        // risc-v test div
        div_test_item(DIV, 3, 20, 6),
        div_test_item(DIV, -3, -20, 6),
        div_test_item(DIV, -3, 20, -6),
        div_test_item(DIV, 3, -20, -6),
        div_test_item(DIV, -1LL << 63, -1LL << 63, 1),
        div_test_item(DIV, -1LL << 63, -1LL << 63, -1),
        div_test_item(DIV, -1, -1LL << 63, 0),
        div_test_item(DIV, -1, 1, 0),
        div_test_item(DIV, -1, 0, 0),
        // risc-v test divu
        div_test_item(DIVU, 3, 20, 6),
        div_test_item(DIVU, 3074457345618258599L, -20, 6),
        div_test_item(DIVU, 0, 20, -6),
        div_test_item(DIVU, 0, -20, -6),
        div_test_item(DIVU, -1LL << 63, -1LL << 63, 1),
        div_test_item(DIVU, 0, -1LL << 63, -1),
        div_test_item(DIVU, -1, -1LL << 63, 0),
        div_test_item(DIVU, -1, 1, 0),
        div_test_item(DIVU, -1, 0, 0),
        // risc-v test divuw
        div_test_item(DIVU, 3, 20, 6, true),
        div_test_item(DIVU, 715827879, -20L << 32 >> 32, 6, true),
        div_test_item(DIVU, 0, 20, -6, true),
        div_test_item(DIVU, 0, -20, -6, true),
        div_test_item(DIVU, -1LL << 31, -1LL << 31, 1, true),
        div_test_item(DIVU, 0, -1LL << 31, -1, true),
        div_test_item(DIVU, -1, -1LL << 31, 0, true),
        div_test_item(DIVU, -1, 1, 0, true),
        div_test_item(DIVU, -1, 0, 0, true),
        // risc-v test divw
        div_test_item(DIV, 3, 20, 6, true),
        div_test_item(DIV, -3, -20, 6, true),
        div_test_item(DIV, -3, 20, -6, true),
        div_test_item(DIV, 3, -20, -6, true),
        div_test_item(DIV, -1LL << 31, -1LL << 31, 1, true),
        div_test_item(DIV, -1LL << 31, -1LL << 31, -1, true),
        div_test_item(DIV, -1, -1LL << 31, 0, true),
        div_test_item(DIV, -1, 1, 0, true),
        div_test_item(DIV, -1, 0, 0, true),
        // risc-v test rem
        div_test_item(REM, 2, 20, 6),
        div_test_item(REM, -2, -20, 6),
        div_test_item(REM, 2, 20, -6),
        div_test_item(REM, -2, -20, -6),
        div_test_item(REM, 0, -1LL << 63, 1),
        div_test_item(REM, 0, -1LL << 63, -1),
        div_test_item(REM, -1LL << 63, -1LL << 63, 0),
        div_test_item(REM, 1, 1, 0),
        div_test_item(REM, 0, 0, 0),
        // risc-v test remu
        div_test_item(REMU, 2, 20, 6),
        div_test_item(REMU, 2, -20, 6),
        div_test_item(REMU, 20, 20, -6),
        div_test_item(REMU, -20, -20, -6),
        div_test_item(REMU, 0, -1LL << 63, 1),
        div_test_item(REMU, -1LL << 63, -1LL << 63, -1),
        div_test_item(REMU, -1LL << 63, -1LL << 63, 0),
        div_test_item(REMU, 1, 1, 0),
        div_test_item(REMU, 0, 0, 0),
        // risc-v test remuw
        div_test_item(REMU, 2, 20, 6, true),
        div_test_item(REMU, 2, -20, 6, true),
        div_test_item(REMU, 20, 20, -6, true),
        div_test_item(REMU, -20, -20, -6, true),
        div_test_item(REMU, 0, -1LL << 31, 1, true),
        div_test_item(REMU, -1LL << 31, -1LL << 31, -1, true),
        div_test_item(REMU, -1LL << 31, -1LL << 31, 0, true),
        div_test_item(REMU, 1, 1, 0, true),
        div_test_item(REMU, 0, 0, 0, true),
        // risc-v test remw
        div_test_item(REM, 2, 20, 6, true),
        div_test_item(REM, -2, -20, 6, true),
        div_test_item(REM, 2, 20, -6, true),
        div_test_item(REM, -2, -20, -6, true),
        div_test_item(REM, 0, -1LL << 31, 1, true),
        div_test_item(REM, 0, -1LL << 31, -1, true),
        div_test_item(REM, -1LL << 31, -1LL << 31, 0, true),
        div_test_item(REM, 1, 1, 0, true),
        div_test_item(REM, 0, 0, 0, true),
        div_test_item(REM, 0xfffffffffffff897L, 0xfffffffffffff897L, 0, true)
    };
    bool test_failed = false;
    for (div_test_item each_item : div_test) {
        test_failed |= !test_div(dut, vcd, each_item.op, each_item.out, each_item.in1, each_item.in2, each_item.is_32bit);
        if (test_failed) break;
    }
    return !test_failed;
}

int main(int argc, char **argv, char **env) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);
    Vdiv *dut = new Vdiv;
    VerilatedVcdC vcd;
    dut->trace(&vcd, 0);
    vcd.open("trace.vcd");
    dut->reset = 1;
    dut->clock = 1;
    dut->in1 = 0;
    dut->in2 = 0;
    dut->div_word = 0;
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