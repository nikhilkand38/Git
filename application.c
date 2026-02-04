// application.c – pure C app for Cortex-R52 on AN536
//#define UART3_BASE   0xE0207000u
//#define UART_BASE   0xE0000000u  // UART0
#define APB_UART0_BASE  0xE7C00000ul
#define UART_DATA    (*(volatile unsigned int *)(APB_UART0_BASE + 0x00))
#define UART_STATE   (*(volatile unsigned int *)(APB_UART0_BASE + 0x04))
#define UART_CTRL    (*(volatile unsigned int *)(APB_UART0_BASE + 0x08))
#define UART_BAUDDIV (*(volatile unsigned int *)(APB_UART0_BASE + 0x10))
static inline void uart_init(void) {
   UART_CTRL = 0;          // disable during setup
   UART_BAUDDIV = 434;      // simple divider
   UART_CTRL = (1u << 0) | (1u << 1)| (1 << 2);  // RX enable
}
static inline void uart_putc(char c) {
   while (UART_STATE & 1u) { }  // wait until TX not full
   UART_DATA = (unsigned int)c;
}
static void uart_puts(const char *s) {
   while (*s) uart_putc(*s++);
}
void main(void) {
   uart_init();
   uart_puts("Hello World from C (Cortex-R52 AN536)\r\n");
   for (;;);   // loop forever
}
