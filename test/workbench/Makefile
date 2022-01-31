TOOL	:=	riscv64-unknown-linux-gnu-
CC		:=	$(TOOL)gcc
OBJCOPY	:=	$(TOOL)objcopy
OBJDUMP :=  $(TOOL)objdump

.PHONY: clean

all: start.hex dump.S

start.hex: start.bin
	od -t x4 -An -w4 -v $< > $@

start.bin: start.elf
	$(OBJCOPY) -O binary $< $@

start.elf: start.S main.c linker.ld
	$(CC) -nostdlib -static -fno-builtin-printf -T linker.ld start.S main.c -o $@

dump.S: start.elf
	$(OBJDUMP) -D $< > $@

clean:
	rm start.hex start.bin start.elf