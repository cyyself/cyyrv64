#define TEST_BOARD_IO
#define TEST_UART

#ifdef  TEST_UART
#define UART_BASE 0x60000000
#define UART_RX     0   /* In:  Receive buffer */
#define UART_TX     0   /* Out: Transmit buffer */
#define UART_LSR    5   /* In:  Line Status Register */
#define UART_LSR_TEMT       0x40 /* Transmitter empty */
#define UART_LSR_THRE       0x20 /* Transmit-hold-register empty */
#define UART_LSR_DR         0x01 /* Receiver data ready */

void uart_put_c(char c) {
    while (!(*((volatile char*)UART_BASE + UART_LSR) & (UART_LSR_TEMT)));
    *((volatile char*)UART_BASE + UART_TX) = c;
}

char uart_check_read() { // 1: data ready, 0: no data
    return (*((volatile char*)UART_BASE + UART_LSR) & (UART_LSR_DR));
}

char uart_get_c() {
    return (*((volatile char*)UART_BASE + UART_RX));
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

#endif

#ifdef  TEST_BOARD_IO
#define BIO_BASE    0x64000000
#define BIO_SEG7    0
#define BIO_LED16   4
#define BIO_LED     6
#define BIO_CLOCK   8
#define BIO_SW      16
#define BIO_DIR_BTN 18

unsigned short bio_sw_get() {
    return *(volatile unsigned short*)((void*)BIO_BASE + BIO_SW);
}

void bio_led16_set(unsigned short value) {
    *(volatile unsigned short*)((void*)BIO_BASE + BIO_LED16) = value;
}

void bio_led_set(unsigned short value) {
    *(volatile unsigned short*)((void*)BIO_BASE + BIO_LED) = value;
}

void bio_seg7_set(unsigned int value) {
    *(volatile unsigned int*)((void*)BIO_BASE + BIO_SEG7) = value;
}

unsigned long bio_get_clock() {
    return *(volatile unsigned long*)((void*)BIO_BASE + BIO_CLOCK);
}

unsigned short bio_dir_btn_get() {
    return *(volatile unsigned short*)((void*)BIO_BASE + BIO_DIR_BTN);
}

#endif

int cmain() {
#ifdef TEST_UART
    print_s("cyyrv64 is booting...\r\n");
    print_s("              vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv\r\n                  vvvvvvvvvvvvvvvvvvvvvvvvvvvv\r\nrrrrrrrrrrrrr       vvvvvvvvvvvvvvvvvvvvvvvvvv\r\nrrrrrrrrrrrrrrrr      vvvvvvvvvvvvvvvvvvvvvvvv\r\nrrrrrrrrrrrrrrrrrr    vvvvvvvvvvvvvvvvvvvvvvvv\r\nrrrrrrrrrrrrrrrrrr    vvvvvvvvvvvvvvvvvvvvvvvv\r\nrrrrrrrrrrrrrrrrrr    vvvvvvvvvvvvvvvvvvvvvvvv\r\nrrrrrrrrrrrrrrrr      vvvvvvvvvvvvvvvvvvvvvv  \r\nrrrrrrrrrrrrr       vvvvvvvvvvvvvvvvvvvvvv    \r\nrr                vvvvvvvvvvvvvvvvvvvvvv      \r\nrr            vvvvvvvvvvvvvvvvvvvvvvvv      rr\r\nrrrr      vvvvvvvvvvvvvvvvvvvvvvvvvv      rrrr\r\nrrrrrr      vvvvvvvvvvvvvvvvvvvvvv      rrrrrr\r\nrrrrrrrr      vvvvvvvvvvvvvvvvvv      rrrrrrrr\r\nrrrrrrrrrr      vvvvvvvvvvvvvv      rrrrrrrrrr\r\nrrrrrrrrrrrr      vvvvvvvvvv      rrrrrrrrrrrr\r\nrrrrrrrrrrrrrr      vvvvvv      rrrrrrrrrrrrrr\r\nrrrrrrrrrrrrrrrr      vv      rrrrrrrrrrrrrrrr\r\nrrrrrrrrrrrrrrrrrr          rrrrrrrrrrrrrrrrrr\r\nrrrrrrrrrrrrrrrrrrrr      rrrrrrrrrrrrrrrrrrrr\r\nrrrrrrrrrrrrrrrrrrrrrr  rrrrrrrrrrrrrrrrrrrrrr\r\n\r\n       INSTRUCTION SETS WANT TO BE FREE\r\n");
    int year = 2022;
    print_s("Year = ");
    print_long(year);
    print_s("\r\nHappy Lunar New Year!\r\n");
    #ifdef TEST_BOARD_IO
        unsigned long clk = bio_get_clock();
        dump_hex(clk);
        print_long(clk);
        print_s("\r\n");
    #endif
#endif
    while (1) {
#ifdef TEST_BOARD_IO
        bio_led16_set(bio_sw_get());
        bio_led_set(bio_dir_btn_get());
        unsigned long clock = bio_get_clock();
        bio_seg7_set(0xf00ba000u^(clock >> 24));
#endif
#ifdef TEST_UART
        if (uart_check_read()) {
            char c = uart_get_c();
            if (c == 0) print_s("error\r\n");
            else if (c == '\r') {
                uart_put_c(c);
                uart_put_c('\n');
            }
            else uart_put_c(c);
        }
#endif
    }
    return 0;
}