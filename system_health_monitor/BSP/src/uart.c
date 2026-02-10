#include "uart.h"
 
#define UART0_BASE 0x1C090000  // QEMU PL011 UART (MPS3 board)
 
void uart_init(void)
{
    // nothing needed for QEMU
}

void uart_putc(char c)
{
    volatile uint32 *uart_dr = (uint32 *)(UART0_BASE + 0x00);
    *uart_dr = (uint32)c;
}
 
void uart_puts(const char *s)
{
    while (*s) uart_putc(*s++);
}
 
void uart_putnum(uint32 num)
{
    char buf[10];
    int i = 0;
 
    if (num == 0) {
        uart_putc('0');
        return;
    }
 
    while (num > 0) {
        buf[i++] = (num % 10) + '0';
        num /= 10;
    }
 
    while (i--) uart_putc(buf[i]);
}
 