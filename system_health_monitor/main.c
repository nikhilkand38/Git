#include "uart.h"
#include "app.h"
 
int main(void)
{
    uart_init();
    App_Run();
    while (1);
}