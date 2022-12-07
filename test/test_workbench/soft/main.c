struct uartlite_regs {
    volatile unsigned int rx_fifo;
    volatile unsigned int tx_fifo;
    volatile unsigned int status;
    volatile unsigned int control;
};

struct uartlite_regs *const ttyUL0 = (struct uartlite_regs *)0x60100000;

#define SR_TX_FIFO_FULL         (1<<3) /* transmit FIFO full */
#define SR_TX_FIFO_EMPTY        (1<<2) /* transmit FIFO empty */
#define SR_RX_FIFO_VALID_DATA   (1<<0) /* data in receive FIFO */
#define SR_RX_FIFO_FULL         (1<<1) /* receive FIFO full */

#define ULITE_CONTROL_RST_TX	0x01
#define ULITE_CONTROL_RST_RX	0x02

void uart_put_c(char c) {
    while (ttyUL0->status & SR_TX_FIFO_FULL);
    ttyUL0->tx_fifo = c;
}

char uart_check_read() { // 1: data ready, 0: no data
    return (ttyUL0->status & SR_RX_FIFO_VALID_DATA) != 0;
}

char uart_get_c() {
    return ttyUL0->rx_fifo;
}

void print_s(const char *c) {
    while (*c) {
        uart_put_c(*c);
        c ++;
    }
}

void print_long(long x) {
    char buffer[30];
    if (x < 0) {
        uart_put_c('-');
        x = -x;
    }
    int idx = 0;
    while (x) {
        long new_x = x / 10;
        long rem_x = x % 10;
        buffer[idx ++] = '0' + rem_x;
        x = new_x;
    }
    if (idx == 0) uart_put_c('0');
    else while (idx) uart_put_c(buffer[--idx]);
}

void print_digit(unsigned char x) {
    uart_put_c('0'+x);
}

void dump_hex(unsigned long x) {
    uart_put_c('0');
    uart_put_c('x');
    char buffer[16];
    for (int i=0;i<16;i++) {
        unsigned long cur = x & 0xf;
        buffer[i] = cur < 10 ? ('0' + cur) : ('a' + cur - 10);
        x >>= 4;
    }
    for (int i=15;i>=0;i--) uart_put_c(buffer[i]);
    uart_put_c('\r');
    uart_put_c('\n');
}

int cmain() {
    print_s("              vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv\r\n                  vvvvvvvvvvvvvvvvvvvvvvvvvvvv\r\nrrrrrrrrrrrrr       vvvvvvvvvvvvvvvvvvvvvvvvvv\r\nrrrrrrrrrrrrrrrr      vvvvvvvvvvvvvvvvvvvvvvvv\r\nrrrrrrrrrrrrrrrrrr    vvvvvvvvvvvvvvvvvvvvvvvv\r\nrrrrrrrrrrrrrrrrrr    vvvvvvvvvvvvvvvvvvvvvvvv\r\nrrrrrrrrrrrrrrrrrr    vvvvvvvvvvvvvvvvvvvvvvvv\r\nrrrrrrrrrrrrrrrr      vvvvvvvvvvvvvvvvvvvvvv  \r\nrrrrrrrrrrrrr       vvvvvvvvvvvvvvvvvvvvvv    \r\nrr                vvvvvvvvvvvvvvvvvvvvvv      \r\nrr            vvvvvvvvvvvvvvvvvvvvvvvv      rr\r\nrrrr      vvvvvvvvvvvvvvvvvvvvvvvvvv      rrrr\r\nrrrrrr      vvvvvvvvvvvvvvvvvvvvvv      rrrrrr\r\nrrrrrrrr      vvvvvvvvvvvvvvvvvv      rrrrrrrr\r\nrrrrrrrrrr      vvvvvvvvvvvvvv      rrrrrrrrrr\r\nrrrrrrrrrrrr      vvvvvvvvvv      rrrrrrrrrrrr\r\nrrrrrrrrrrrrrr      vvvvvv      rrrrrrrrrrrrrr\r\nrrrrrrrrrrrrrrrr      vv      rrrrrrrrrrrrrrrr\r\nrrrrrrrrrrrrrrrrrr          rrrrrrrrrrrrrrrrrr\r\nrrrrrrrrrrrrrrrrrrrr      rrrrrrrrrrrrrrrrrrrr\r\nrrrrrrrrrrrrrrrrrrrrrr  rrrrrrrrrrrrrrrrrrrrrr\r\n\r\n       INSTRUCTION SETS WANT TO BE FREE\r\n");
    return 0;
}
