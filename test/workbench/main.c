#define UART_BASE 0x60000000
#define UART_RX		0	/* In:  Receive buffer */
#define UART_TX		0	/* Out: Transmit buffer */
#define UART_LSR	5	/* In:  Line Status Register */
#define UART_LSR_TEMT		0x40 /* Transmitter empty */
void uart_put_c(char c) {
    //while (!(*((char*)UART_BASE + UART_LSR) & (UART_LSR_TEMT)));
    *((volatile char*)UART_BASE + UART_TX) = c;
}

void print_s(const char *c) {
    while (*c) {
        uart_put_c(*c);
        c ++;
    }
}

int cmain() {
    *((volatile char*)UART_BASE + UART_TX) = 'b';
    *((volatile char*)UART_BASE + UART_TX) = 'o';
    *((volatile char*)UART_BASE + UART_TX) = 'o';
    *((volatile char*)UART_BASE + UART_TX) = 't';
    *((volatile char*)UART_BASE + UART_TX) = 'i';
    *((volatile char*)UART_BASE + UART_TX) = 'n';
    *((volatile char*)UART_BASE + UART_TX) = 'g';
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
    *((volatile char*)UART_BASE + UART_TX) = s[0];
    return 0;
}