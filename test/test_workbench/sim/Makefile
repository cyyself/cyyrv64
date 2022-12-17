TOP_NAME := top_axi_wrapper
SRC_DIR  := ../../../core/
SRC_FILE := $(shell find $(SRC_DIR) -name '*.svh') $(shell find $(SRC_DIR) -name '*.v') $(shell find $(SRC_DIR) -name '*.sv')

.PHONY: clean riscv-tests-build

obj_dir/V$(TOP_NAME): src/* $(SRC_FILE) ../soft/start.bin
	verilator --cc -Wno-fatal --exe --trace --trace-structs -LDFLAGS "-lpthread" --build src/sim_mycpu.cpp $(SRC_FILE) -I$(SRC_DIR) --top $(TOP_NAME) -j `nproc`

../soft/start.bin:
	cd ../soft && make

riscv-tests:
	git clone https://github.com/cyyself/riscv-tests.git -b cqu-co-lab-riscv
	cd riscv-tests && git submodule update --init --recursive && autoupdate && autoconf && ./configure

riscv-tests-build: riscv-tests
	mkdir -p riscv-tests-build
	make -C riscv-tests-build -f ../riscv-tests/Makefile RISCV_PREFIX=riscv64-unknown-linux-gnu- isa

clean:
	rm -rf obj_dir