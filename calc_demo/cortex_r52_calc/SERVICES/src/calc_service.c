#include "winAMS_Spmc.h"

#line 12 "D:\\winams-1\\cortex_r52_calc\\cortex_r52_calc\\SERVICES\\inc\\calc_service.h"
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
#line 4 "D:\\winams-1\\cortex_r52_calc\\cortex_r52_calc\\SERVICES\\src\\calc_service.c"
static int add_i(int a, int b) {WinAMS_SPMC_C0("calc_service.c/add_i",4); return a + b; }
static int sub_i(int a, int b) {WinAMS_SPMC_C0("calc_service.c/sub_i",5); return a - b; }
static int mul_i(int a, int b) {WinAMS_SPMC_C0("calc_service.c/mul_i",6); return a * b; }
static int div_i(int a, int b) {WinAMS_SPMC_C0("calc_service.c/div_i",7); return (((WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("calc_service.c/div_i",2,(WinAMS_SPMC_Exp(0,(b == 0))),1,2) || WinAMS_SPMC_resVal))) ? 0 : (a / b); }
#line 9
void Calc_Service_Run(const Calc_InputType *input, Calc_OutputType *output)
{
WinAMS_SPMC_C0("Calc_Service_Run",11);if ((WinAMS_SPMC_C1("Calc_Service_Run",3)||(WinAMS_SPMC_Clr(2) || WinAMS_SPMC_Res("Calc_Service_Run",1,(WinAMS_SPMC_Exp(0,((input == 0))) ||WinAMS_SPMC_Exp(1,( (output == 0)))),2,3) || WinAMS_SPMC_resVal))) {
WinAMS_SPMC_C0("Calc_Service_Run",12); WinAMS_SPMC_C1("Calc_Service_Run",4);return;
} WinAMS_SPMC_C1("Calc_Service_Run",6);
#line 16
WinAMS_SPMC_C0("Calc_Service_Run",16),output->add =(WinAMS_SPMC_CALL("Calc_Service_Run",1), add_i(input->a, input->b));
WinAMS_SPMC_C0("Calc_Service_Run",17),output->sub =(WinAMS_SPMC_CALL("Calc_Service_Run",2), sub_i(input->a, input->b));
WinAMS_SPMC_C0("Calc_Service_Run",18),output->mul =(WinAMS_SPMC_CALL("Calc_Service_Run",3), mul_i(input->a, input->b));
WinAMS_SPMC_C0("Calc_Service_Run",19),output->div =(WinAMS_SPMC_CALL("Calc_Service_Run",4), div_i(input->a, input->b));
}
