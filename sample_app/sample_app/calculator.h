#ifndef CALCULATOR_H
#define CALCULATOR_H

#include <stdint.h>

/* ---- Global variables (visible to winAMS) ---- */
extern volatile int32_t g_operand_a;
extern volatile int32_t g_operand_b;
extern volatile int32_t g_result;

/* ---- APIs ---- */
int32_t add(int32_t a, int32_t b);
int32_t sub(int32_t a, int32_t b);

#endif /* CALCULATOR_H */

