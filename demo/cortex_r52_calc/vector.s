.cpu cortex-r52
.global _start
 
.section .vectors, "ax"
 
_start:
    LDR sp, =_stack_top
    BL main
1:
    B 1b