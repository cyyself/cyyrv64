TOOL	:=	riscv64-unknown-linux-gnu-
AS		:=	$(TOOL)as
OBJCOPY	:=	$(TOOL)objcopy

.PHONY: clean

start.hex: start.bin
	od -t x4 -An -w4 -v $< > $@

start.bin: start.out
	$(OBJCOPY) -O binary $< $@

start.out: start.S
	$(AS) $< -o $@

clean:
	rm start.hex start.bin start.out