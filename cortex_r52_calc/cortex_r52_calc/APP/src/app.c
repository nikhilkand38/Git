#include "app.h"
#include "uart.h"
#include "calc_service.h"
 
void App_Run(void)
{
    uart_init();
    uart_puts("Cortex-R52 Calculator App\r\n");
 
    Calc_InputType input = {10, 5};
    Calc_OutputType output;
 
    Calc_Service_Run(&input, &output);
 
    uart_puts("Add = "); uart_putnum(output.add); uart_puts("\r\n");
    uart_puts("Sub = "); uart_putnum(output.sub); uart_puts("\r\n");
    uart_puts("Mul = "); uart_putnum(output.mul); uart_puts("\r\n");
    uart_puts("Div = "); uart_putnum(output.div); uart_puts("\r\n");
}
