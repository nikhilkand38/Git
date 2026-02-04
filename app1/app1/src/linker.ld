MEMORY
{
    rom : ORIGIN = 0x00000000, LENGTH = 0x20000
    ram : ORIGIN = 0x10000000, LENGTH = 0x20000
}

ENTRY(_start);

SECTIONS
{
    .text : { *(.text*) } > rom
    .rodata : { *(.rodata*) } > rom
    .bss : { *(.bss*) } > ram
    .data : { *(.data*) } > ram AT > rom
    . = ALIGN(4);
}
