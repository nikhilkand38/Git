#include "winAMS_Spmc.h"

#line 4 "C:\\Users\\winams_user\\Favorites\\Documents\\Git\\cortex_r52_calc\\cortex_r52_calc\\APP\\inc\\app.h"
void App_Run(void);
#line 4 "C:\\Users\\winams_user\\Favorites\\Documents\\Git\\cortex_r52_calc\\cortex_r52_calc\\BSP\\inc\\uart.h"
void uart_init(void);
void uart_putc(char c);
void uart_puts(const char *s);
void uart_putnum(int num);
#line 12 "C:\\Users\\winams_user\\Favorites\\Documents\\Git\\cortex_r52_calc\\cortex_r52_calc\\SERVICES\\inc\\calc_service.h"
typedef struct {
int a;
int b;
} Calc_InputType;
#line 17
typedef struct {
int add;
int sub;
int mul;
int div;
} Calc_OutputType;
#line 29
void Calc_Service_Run(const Calc_InputType *input, Calc_OutputType *output);
#line 5 "C:\\Users\\winams_user\\Favorites\\Documents\\Git\\cortex_r52_calc\\cortex_r52_calc\\APP\\src\\app.c"
void App_Run(void)
{
Calc_InputType input;
Calc_OutputType output;(WinAMS_SPMC_CALL("App_Run",1),
#line 10
WinAMS_SPMC_C0("App_Run",10),uart_init());(WinAMS_SPMC_CALL("App_Run",2),
WinAMS_SPMC_C0("App_Run",11),uart_puts("Cortex-R52 Calculator App\r\n"));
#line 14
WinAMS_SPMC_C0("App_Run",14),input.a = 10;
WinAMS_SPMC_C0("App_Run",15),input.b = 5;(WinAMS_SPMC_CALL("App_Run",3),
#line 18
WinAMS_SPMC_C0("App_Run",18),Calc_Service_Run(&input, &output));(WinAMS_SPMC_CALL("App_Run",4),
#line 20
WinAMS_SPMC_C0("App_Run",20),uart_puts("Add = "));(WinAMS_SPMC_CALL("App_Run",5), uart_putnum(output.add));(WinAMS_SPMC_CALL("App_Run",6), uart_puts("\r\n"));(WinAMS_SPMC_CALL("App_Run",7),
WinAMS_SPMC_C0("App_Run",21),uart_puts("Sub = "));(WinAMS_SPMC_CALL("App_Run",8), uart_putnum(output.sub));(WinAMS_SPMC_CALL("App_Run",9), uart_puts("\r\n"));(WinAMS_SPMC_CALL("App_Run",10),
WinAMS_SPMC_C0("App_Run",22),uart_puts("Mul = "));(WinAMS_SPMC_CALL("App_Run",11), uart_putnum(output.mul));(WinAMS_SPMC_CALL("App_Run",12), uart_puts("\r\n"));(WinAMS_SPMC_CALL("App_Run",13),
WinAMS_SPMC_C0("App_Run",23),uart_puts("Div = "));(WinAMS_SPMC_CALL("App_Run",14), uart_putnum(output.div));(WinAMS_SPMC_CALL("App_Run",15), uart_puts("\r\n"));
}
