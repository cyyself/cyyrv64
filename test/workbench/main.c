#define UART_BASE 0x60000000
#define UART_RX		0	/* In:  Receive buffer */
#define UART_TX		0	/* Out: Transmit buffer */
#define UART_LSR	5	/* In:  Line Status Register */
#define UART_LSR_TEMT		0x40 /* Transmitter empty */
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

/* __divu* routines are from the book, Hacker's Delight */

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

int cmain() {
    *((volatile char*)UART_BASE + UART_TX) = 'b';
    *((volatile char*)UART_BASE + UART_TX) = 'o';
    *((volatile char*)UART_BASE + UART_TX) = 'o';
    *((volatile char*)UART_BASE + UART_TX) = 't';
    *((volatile char*)UART_BASE + UART_TX) = 'i';
    *((volatile char*)UART_BASE + UART_TX) = 'n';
    *((volatile char*)UART_BASE + UART_TX) = 'g';
    *((volatile char*)UART_BASE + UART_TX) = '\n';
    char s[20];
    s[0] = 'H';
    s[1] = 'e';
    s[2] = 'l';
    s[3] = 'l';
    s[4] = 'o';
    s[5] = ' ';
    s[6] = 'w';
    s[7] = 'o';
    s[8] = 'r';
    s[9] = 'l';
    s[10]= 'd';
    s[11]= '!';
    s[12]= '\n';
    s[13]= 0;
    print_s(s);
    print_long(114514);
    uart_put_c('\n');
    return 0;
}