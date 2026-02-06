.syntax unified
.cpu cortex-r52
.arm

.global _start
.global Reset_Handler

.extern app_main
.extern _stack_top

.section .vectors, "ax"
.align 7

_start:
Vectors:
    b   Reset_Handler        /* Reset */
    b   .                    /* Undefined */
    b   .                    /* SVC */
    b   .                    /* Prefetch Abort */
    b   .                    /* Data Abort */
    b   .                    /* Reserved */
    b   .                    /* IRQ */
    b   .                    /* FIQ */

.section .text
.type Reset_Handler, %function
Reset_Handler:
    ldr sp, =_stack_top
    bl  app_main
1:
    b   1b

