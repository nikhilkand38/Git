/* Cortex-R52 Linker Script (Bare Metal) */
 
ENTRY(_start)
 
MEMORY
{
    FLASH (rx)  : ORIGIN = 0x00000000, LENGTH = 256K
    RAM   (rwx) : ORIGIN = 0x10000000, LENGTH = 256K
}
 
SECTIONS
{
    .text :
    {
        *(.vectors*)
        *(.text*)
        *(.rodata*)
    } > FLASH
 
    .data : AT (ADDR(.text) + SIZEOF(.text))
    {
        *(.data*)
    } > RAM
 
    .bss :
    {
        *(.bss*)
        *(COMMON)
    } > RAM
 
    . = ALIGN(8);
    _stack_top = ORIGIN(RAM) + LENGTH(RAM);
}