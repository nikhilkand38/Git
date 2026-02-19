#ifndef CALC_SERVICE_H
#define CALC_SERVICE_H

/* If you prefer fixed-width types, uncomment the next line and change int->int32_t
#include <stdint.h>
*/

#ifdef __cplusplus
extern "C" {
#endif

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

/**
* @brief Perform basic arithmetic on input and write results to output.
* @param input  Pointer to input operands (must not be NULL)
* @param output Pointer to results (must not be NULL)
*/
void Calc_Service_Run(const Calc_InputType *input, Calc_OutputType *output);

#ifdef __cplusplus
}
#endif

#endif /* CALC_SERVICE_H */
