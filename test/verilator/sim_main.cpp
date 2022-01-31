#include "Vcpu_top.h"
#include "verilated.h"
int main(int argc, char** argv, char** env) {
    Vcpu_top* top = new Vcpu_top;
    top->clk = 0;
    top->rst = 0;
    unsigned long max_clk = 1000000;
    while (!Verilated::gotFinish() && max_clk) {
        top->eval();
        if (max_clk % 10 == 0) top->clk = !top->clk;
        max_clk --;
    }
    top->final();
    delete top;
    return 0;
}