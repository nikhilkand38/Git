.section .vectors, "ax"
.global _start
 
_start:
    b reset_handler
 
reset_handler:
    ldr sp, =_stack_top
    bl main
 
hang:
    b hang