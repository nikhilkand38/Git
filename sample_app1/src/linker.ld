/* linker.ld - Cortex-R52 bare-metal, ROM+RAM layout */

MEMORY
{
    rom (rx)  : ORIGIN = 0x00000000, LENGTH = 0x20000
    ram (rwx) : ORIGIN = 0x10000000, LENGTH = 0x20000
}

ENTRY(_start)

SECTIONS
{
    /* Code + const data in ROM */
    .text : ALIGN(4)
    {
        *(.text*)
        *(.rodata*)
        *(.glue_7*)
        *(.glue_7t*)
        . = ALIGN(4);
        __etext = .;
    } > rom

    /* Initialized data in RAM (load image in ROM) */
    .data : ALIGN(4)
    {
        __data_start__ = .;
        *(.data*)
        . = ALIGN(4);
        __data_end__ = .;
    } > ram AT > rom
    __data_load__ = LOADADDR(.data);

    /* BSS in RAM */
    .bss (NOLOAD) : ALIGN(4)
    {
        __bss_start__ = .;
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        __bss_end__ = .;
    } > ram

    _end = .;
    __end__ = .;

    /* Stack top = end of RAM = 0x10020000 */
    __stack_top__ = ORIGIN(ram) + LENGTH(ram);
}
