#include "verilated_vcd_c.h"
#include "Vsim_soc_top.h"
#include "verilated.h"
#include "ncurses.h"
#include <queue>

using std::queue;

#define CTRL(c) ((c) & 037)

void do_keyboard_input(std::queue <char> &uart_buf) {
    static bool ctrl_a;
    int ch;
    ch = getch();
    if (ch != -1) {
        if ( (ctrl_a && ch == 'k') || (ch == CTRL('c'))) {
            endwin();
            exit(0);
        }
        ctrl_a = (ch == CTRL('a'));
        if (!ctrl_a) {
            if (ch == '\n') {
                // translate '\n' to '\r' to sim like screen tty default settings
                uart_buf.push('\r');
            }
            else uart_buf.push(ch);
        }
    }
}

void do_uart(Vsim_soc_top &top, std::queue <char> &uart_buf) {
    static bool last_clk;
    if (!last_clk && top.clk) { // posedge clk
        if (top.uart_tx_valid) {
            if (top.uart_tx_data != '\r') {
                addch(top.uart_tx_data);
                refresh();
                // TODO: Find a solution to make clrtoeol should not be called after addch('\n'), otherwise, we should add this if.
            }
        }
        if (!uart_buf.empty()) {
            // data comes
            if (top.uart_rx_ready) {
                top.uart_rx_data = uart_buf.front();
                top.uart_rx_valid = 1;
                uart_buf.pop();
            }
        }
        else if (top.uart_rx_ready) top.uart_rx_valid = 0;
    }
    last_clk = top.clk;
}

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    // trace_usage: obj_dir/Vsim_soc_top -trace 100000
    bool trace_on = false;
    unsigned long sim_time = 1e5;
    for (int i=1;i<argc;i++) if (strcmp(argv[i],"-trace") == 0) {
        trace_on = true;
        if (i+1 < argc) {
            sscanf(argv[i+1],"%lu",&sim_time);
        }
    }
    Verilated::traceEverOn(true);
    initscr();
    scrollok(stdscr,TRUE);
    raw();      // disable line buffer
    noecho();
    timeout(0); // non blocking getch()
    printw("CPU is running. Press Ctrl+'A'-'K' or Ctrl+'C' to exit.\n");
    refresh();
    Vsim_soc_top top;
    int rst_timer = 100;
    VerilatedVcdC vcd;
    if (trace_on) {
        top.trace(&vcd,0);
        vcd.open("trace.vcd");
    }

    top.clk = 0;
    top.rst = 1;
    top.uart_rx_data = 0;
    top.uart_rx_valid = 0;
    top.uart_tx_ready = 1;

    std::queue <char> uart_buf;
    unsigned long current_time = 0;
    while (current_time < sim_time && !Verilated::gotFinish()) {
        top.eval();
        top.clk = !top.clk;
        if (rst_timer) {
            rst_timer --;
        }
        else {
            top.rst = 0;
            do_keyboard_input(uart_buf);
            do_uart(top,uart_buf);
            if (trace_on) {
                vcd.dump(current_time);
                current_time ++;
            }
        }
    }
    if (trace_on) vcd.close();
    top.final();
    endwin();
    return 0;
}