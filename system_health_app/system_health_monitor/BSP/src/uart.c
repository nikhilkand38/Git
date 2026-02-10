#include "uart.h"

/* CMSDK APB UART0 base on QEMU mps3-an536 */
#define UART0_BASE       0xE7C00000ul   /* CMSDK APB UART, NOT PL011 */

/* Register offsets (CMSDK APB UART) */
#define UART_DATA_OFS    0x00  /* TXD/RXD */
#define UART_STATE_OFS   0x04  /* Status */
#define UART_CTRL_OFS    0x08  /* Control */
#define UART_INTSTS_OFS  0x0C  /* IntStatus/IntClear */
#define UART_BAUDDIV_OFS 0x10  /* Baud Divider */

/* Convenience accessors */
#define REG32(addr)      (*(volatile uint32 *)(addr))
#define UART_REG(ofs)    REG32(UART0_BASE + (ofs))

/* STATE bits */
#define UART_STATE_TXFULL  (1u << 0)
#define UART_STATE_RXFULL  (1u << 1)
#define UART_STATE_TXOVR   (1u << 2)   /* W1C */
#define UART_STATE_RXOVR   (1u << 3)   /* W1C */

/* CTRL bits */
#define UART_CTRL_TX_EN    (1u << 0)
#define UART_CTRL_RX_EN    (1u << 1)
#define UART_CTRL_TX_INTEN (1u << 2)
#define UART_CTRL_RX_INTEN (1u << 3)
#define UART_CTRL_TXO_INTEN (1u << 4)
#define UART_CTRL_RXO_INTEN (1u << 5)
/* [6] is high-speed test mode; leave it off for normal use */

/* A good default for QEMU mps3-an536:
 * BAUDDIV = PCLK / BAUD. With PCLK ≈ 50MHz, 115200 baud -> 50,000,000 / 115200 ≈ 434.
 * QEMU’s CMSDK model accepts BAUDDIV >= 16 and sets baud = pclk/bauddiv.
 */
#define UART_BAUDDIV_115200  (434u)

void uart_init(void)
{
    /* Disable, clear, program, enable */
    UART_REG(UART_CTRL_OFS) = 0;

    /* Clear any sticky overrun flags (W1C via STATE[3:2]) */
    UART_REG(UART_STATE_OFS) = (UART_STATE_TXOVR | UART_STATE_RXOVR);

    /* Program baud rate divider */
    UART_REG(UART_BAUDDIV_OFS) = UART_BAUDDIV_115200;

    /* Enable TX and RX (interrupts not needed for polling prints) */
    UART_REG(UART_CTRL_OFS) = (UART_CTRL_TX_EN | UART_CTRL_RX_EN);
}

void uart_putc(char c)
{
    /* Wait while TX FIFO is full */
    while (UART_REG(UART_STATE_OFS) & UART_STATE_TXFULL) { }
    UART_REG(UART_DATA_OFS) = (uint32)(uint8)c;
}

void uart_puts(const char *s)
{
    while (*s) {
        if (*s == '\n') uart_putc('\r'); /* make terminal happy */
        uart_putc(*s++);
    }
}

void uart_putnum(uint32 num)
{
    char buf[10];
    int i = 0;

    if (num == 0) {
        uart_putc('0');
        return;
    }

    while (num > 0 && i < (int)sizeof(buf)) {
        buf[i++] = (char)((num % 10u) + '0');
        num /= 10u;
    }
    while (i--) uart_putc(buf[i]);
}