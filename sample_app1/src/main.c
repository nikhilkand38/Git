#include "winAMS_Spmc.h"

#line 4 "C:\\winAMS_CM1\\CasePlayer2\\Source\\calculator.h"
int add(int a, int b);
#line 6
int subtract(int a, int b);
#line 8
int multiply(int a, int b);
#line 10
int divide(int a, int b);
#line 4 "C:\\winAMS_CM1\\CasePlayer2\\Source\\main.c"
void main(void)
{
#line 7
volatile int r1 = add(10, 20);
volatile int r2 = subtract(50, 8);
volatile int r3 = multiply(7, 6);
volatile int r4 = divide(100, 4);
#line 12
WinAMS_SPMC_C0("main",12),(void)r1; (void)r2; (void)r3; (void)r4;
#line 15
for (;WinAMS_SPMC_C0("main",15)||1;) { WinAMS_SPMC_C1("main",5); } WinAMS_SPMC_C1("main",6);
}
