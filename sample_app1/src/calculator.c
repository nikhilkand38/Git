#include "winAMS_Spmc.h"

#line 4 "C:\\winAMS_CM1\\CasePlayer2\\Source\\calculator.h"
int add(int a, int b);
#line 6
int subtract(int a, int b);
#line 8
int multiply(int a, int b);
#line 10
int divide(int a, int b);
#line 3 "C:\\winAMS_CM1\\CasePlayer2\\Source\\calculator.c"
int add(int a, int b) {
WinAMS_SPMC_C0("add",4);return a + b;
}
#line 7
int subtract(int a, int b) {
WinAMS_SPMC_C0("subtract",8);return a - b;
}
#line 11
int multiply(int a, int b) {
WinAMS_SPMC_C0("multiply",12);return a * b;
}
#line 15
int divide(int a, int b) {
WinAMS_SPMC_C0("divide",16);if ((WinAMS_SPMC_C1("divide",3)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("divide",1,(WinAMS_SPMC_Exp(0,(b == 0))),1,3) || WinAMS_SPMC_resVal))){
WinAMS_SPMC_C0("divide",17); WinAMS_SPMC_C1("divide",4);return 0;} WinAMS_SPMC_C1("divide",6);
WinAMS_SPMC_C0("divide",18);return a / b;
}
