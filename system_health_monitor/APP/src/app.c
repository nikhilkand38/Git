#include "app.h"
#include "health_service.h"
#include "uart.h"
 
void App_Run(void)
{
    uart_puts("\n=== Cortex-R52 System Health Monitor ===\n");
 
    Health_Init();
 
    while (1)
    {
        Health_Report();
 
        for (volatile int i = 0; i < 5000000; i++); // delay
    }
}