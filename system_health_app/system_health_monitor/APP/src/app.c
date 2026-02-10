#include "app.h"
#include "health_service.h"
#include "uart.h"

void App_Run(void)
{
    uart_puts("\n=== Cortex-R52 System Health Monitor ===\n");

    Health_Init();

    for (int i = 0; i < 10; ++i)
    {
        Health_Report();
    }
    uart_puts("Health monitor finished.\n");
}