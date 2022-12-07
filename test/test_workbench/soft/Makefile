TOOL	:=	riscv64-unknown-linux-gnu-
CC		:=	$(TOOL)gcc
OBJCOPY	:=	$(TOOL)objcopy
OBJDUMP :=  $(TOOL)objdump

.PHONY: clean

all: start_inst.hex start_data.hex dump.S

start_inst.hex: start.bin
	od -t x4 -An -w4 -v $< > $@

start_data.hex: start.bin
	od -t x8 -An -w8 -v $< > $@

start.bin: start.elf
	$(OBJCOPY) -O binary $< $@

start.elf: start.S main.c linker.ld
	$(CC) -nostdlib -static -fno-builtin-printf -T linker.ld start.S main.c -lgcc -O3 -o $@

dump.S: start.elf
	$(OBJDUMP) -D $< > $@

clean:
	rm start_inst.hex start_data.hex start.bin start.elf