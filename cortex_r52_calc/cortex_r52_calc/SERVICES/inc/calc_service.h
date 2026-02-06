#ifndef CALC_SERVICE_H
#define CALC_SERVICE_H
 
typedef struct {
    int a;
    int b;
} Calc_InputType;
 
typedef struct {
    int add;
    int sub;
    int mul;
    int div;
} Calc_OutputType;
 
void Calc_Service_Run(const Calc_InputType *input, Calc_OutputType *output);
 
#endif
