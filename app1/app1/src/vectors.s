.cpu cortex-r52

.global _start
.section .text
_start:
    LDR sp, =stacktop
    BL main
    B reset

    .word hang  // Undefined instruction handler
    .word hang  // Software interrupt handler
    .word hang  // Prefetch abort handler
    .word hang  // Data abort handler
    .word hang  // Reserved
    .word hang  // IRQ handler
    .word hang  // FIQ handler

stacktop: .word 0x30002000

reset:
    B hang

hang:
    B hang

.globl PUT32
PUT32:
    STR r1, [r0]
    BX lr
