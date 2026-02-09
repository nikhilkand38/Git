/* vectors.s - minimal startup for Cortex-R52 */

    .cpu cortex-r52
    .syntax unified
    .arm

    .global _start
    .extern main
    .extern __stack_top__

    .section .text
_start:
    /* Set stack pointer to top of RAM (0x10020000) */
    LDR     sp, =__stack_top__

    /* Call C main */
    BL      main

    /* If main returns, hang */
hang:
    B       hang

    /* Placeholder exception handlers (kept like your sample) */
    .word hang  /* Undefined instruction */
    .word hang  /* SVC/SWI */
    .word hang  /* Prefetch abort */
    .word hang  /* Data abort */
    .word hang  /* Reserved */
    .word hang  /* IRQ */
    .word hang  /* FIQ */

    /* Optional helper */
    .global PUT32
PUT32:
    STR     r1, [r0]
    BX      lr
