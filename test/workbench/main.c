
#define UART_BASE 0x60000000
#define UART_RX		0	/* In:  Receive buffer */
#define UART_TX		0	/* Out: Transmit buffer */
#define UART_LSR	5	/* In:  Line Status Register */
#define UART_LSR_TEMT		0x40 /* Transmitter empty */
/*
void uart_put_c(char c) {
    while (!(*((char*)UART_BASE + UART_LSR) & (UART_LSR_TEMT)));
    *((volatile char*)UART_BASE + UART_TX) = c;
}

void print_s(const char *c) {
    while (*c) {
        uart_put_c(*c);
        c ++;
    }
}

unsigned long __mulu10(unsigned long n)
{
  return (n<<3)+(n<<1);
}
*/
/* __divu* routines are from the book, Hacker's Delight */
/*
unsigned long __divu10(unsigned long n) {
  unsigned long q, r;
  q = (n >> 1) + (n >> 2);
  q = q + (q >> 4);
  q = q + (q >> 8);
  q = q + (q >> 16);
  q = q >> 3;
  r = n - __mulu10(q);
  return q + ((r + 6) >> 4);
}

void print_long(long x) {
    char buffer[30];
    if (x < 0) {
        uart_put_c('-');
        x = -x;
    }
    int idx = 0;
    while (x) {
        long new_x = __divu10(x);
        long rem_x = x - __mulu10(new_x);
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
    uart_put_c('\n');
}
*/

#define BIO_BASE    0x64000000
#define BIO_SEG7    0
#define BIO_LED16   4
#define BIO_SW      16

unsigned short bio_sw_get() {
    return *(volatile unsigned short*)((void*)BIO_BASE + BIO_SW);
}

void bio_led16_set(unsigned short value) {
    *(volatile unsigned short*)((void*)BIO_BASE + BIO_LED16) = value;
}

void bio_seg7_set(unsigned int value) {
    *(volatile unsigned int*)((void*)BIO_BASE + BIO_SEG7) = value;
}

int cmain() {
    bio_seg7_set(0xdeadbeefu);
    while (1) {
        bio_led16_set(bio_sw_get());
    }
    /*
    print_s("cyyrv64 is booting...\n");
    print_s("              vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv\n                  vvvvvvvvvvvvvvvvvvvvvvvvvvvv\nrrrrrrrrrrrrr       vvvvvvvvvvvvvvvvvvvvvvvvvv\nrrrrrrrrrrrrrrrr      vvvvvvvvvvvvvvvvvvvvvvvv\nrrrrrrrrrrrrrrrrrr    vvvvvvvvvvvvvvvvvvvvvvvv\nrrrrrrrrrrrrrrrrrr    vvvvvvvvvvvvvvvvvvvvvvvv\nrrrrrrrrrrrrrrrrrr    vvvvvvvvvvvvvvvvvvvvvvvv\nrrrrrrrrrrrrrrrr      vvvvvvvvvvvvvvvvvvvvvv  \nrrrrrrrrrrrrr       vvvvvvvvvvvvvvvvvvvvvv    \nrr                vvvvvvvvvvvvvvvvvvvvvv      \nrr            vvvvvvvvvvvvvvvvvvvvvvvv      rr\nrrrr      vvvvvvvvvvvvvvvvvvvvvvvvvv      rrrr\nrrrrrr      vvvvvvvvvvvvvvvvvvvvvv      rrrrrr\nrrrrrrrr      vvvvvvvvvvvvvvvvvv      rrrrrrrr\nrrrrrrrrrr      vvvvvvvvvvvvvv      rrrrrrrrrr\nrrrrrrrrrrrr      vvvvvvvvvv      rrrrrrrrrrrr\nrrrrrrrrrrrrrr      vvvvvv      rrrrrrrrrrrrrr\nrrrrrrrrrrrrrrrr      vv      rrrrrrrrrrrrrrrr\nrrrrrrrrrrrrrrrrrr          rrrrrrrrrrrrrrrrrr\nrrrrrrrrrrrrrrrrrrrr      rrrrrrrrrrrrrrrrrrrr\nrrrrrrrrrrrrrrrrrrrrrr  rrrrrrrrrrrrrrrrrrrrrr\n\n       INSTRUCTION SETS WANT TO BE FREE\n");
    int year = 2022;
    print_s("Year = ");
    print_long(year);
    print_s("\nHappy Lunar New Year!\n");
    */
    return 0;
}