#include "uart.h"
 
#define APB_UART0_BASE  0xE7C00000ul
 
#define UART_DATA    (*(volatile unsigned int *)(APB_UART0_BASE + 0x00))
#define UART_STATE   (*(volatile unsigned int *)(APB_UART0_BASE + 0x04))
#define UART_CTRL    (*(volatile unsigned int *)(APB_UART0_BASE + 0x08))
#define UART_BAUDDIV (*(volatile unsigned int *)(APB_UART0_BASE + 0x10))
 
void uart_init(void)
{
    UART_CTRL = 0;
    UART_BAUDDIV = 434;
    UART_CTRL = (1u << 0) | (1u << 1) | (1u << 2);
}
 
void uart_putc(char c)
{
    while (UART_STATE & 1u) {}
    UART_DATA = (unsigned int)c;
}
 
void uart_puts(const char *s)
{
    while (*s) uart_putc(*s++);
}
 
void uart_putnum(int num)
{
    char buf[12];
    int i = 0;
 
    if (num == 0) {
        uart_putc('0');
        return;
    }
 
    if (num < 0) {
        uart_putc('-');
        num = -num;
    }
 
    while (num > 0) {
        buf[i++] = (num % 10) + '0';
        num /= 10;
    }
 
    while (i--) uart_putc(buf[i]);
}