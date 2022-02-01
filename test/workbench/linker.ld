SECTIONS
{
    . = 0x00000000;
    .text : { *(.text) }
    .rodata : { *(.rodata) }
    .bss : { *(.bss) }
    .sbss : { *(.sbss) }
    .sdata : { *(.sdata) }
}