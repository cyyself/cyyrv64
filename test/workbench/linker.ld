SECTIONS
{
    . = 0x00000000;
    .text : { *(.text) }
    
  	. = ALIGN(0x0800);
    .rodata : { *(.rodata) }
    .bss : { *(.bss) }
    .sbss : { *(.sbss) }
    .sdata : { *(.sdata) }
}