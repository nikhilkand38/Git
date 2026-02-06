#include "calculator.h"

/* ---- Global variables (winAMS-visible) ---- */
volatile int32_t g_operand_a = 10;
volatile int32_t g_operand_b = 20;
volatile int32_t g_result    = 0;

/* ---- Functions ---- */
int32_t add(int32_t a, int32_t b)
{
    return a + b;
}

int32_t sub(int32_t a, int32_t b)
{
    return a - b;
}

/* ---- Entry point called from reset handler ---- */
void app_main(void)
{
    g_result = add(g_operand_a, g_operand_b);

    /* Infinite loop so debugger / winAMS can inspect */
    while (1)
    {
        __asm__ volatile ("nop");
    }
}

