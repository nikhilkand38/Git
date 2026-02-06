#include "calc_service.h"
 
static int add(int a, int b) { return a + b; }
static int sub(int a, int b) { return a - b; }
static int mul(int a, int b) { return a * b; }
static int divi(int a, int b) { return (b == 0) ? 0 : (a / b); }
 
void Calc_Service_Run(const Calc_InputType *input, Calc_OutputType *output)
{
    if (!input || !output) return;
 
    output->add = add(input->a, input->b);
    output->sub = sub(input->a, input->b);
    output->mul = mul(input->a, input->b);
    output->div = divi(input->a, input->b);
}
