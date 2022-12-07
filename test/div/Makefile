TOP_NAME := div
SRC_DIR  := ../../core
INC_FILE := $(shell find $(SRC_DIR) -name '*.vh') $(shell find $(SRC_DIR) -name '*.svh') $(shell find $(SRC_DIR) -name '*.v') $(shell find $(SRC_DIR) -name '*.sv')

.PHONY: run clean

obj_dir/V$(TOP_NAME): $(INC_FILE) test_div.cpp
	verilator --cc -Wno-fatal --exe --trace --trace-structs -LDFLAGS "-lpthread" --build test_div.cpp $(INC_FILE) -I$(SRC_DIR) --top $(TOP_NAME) -j `nproc`

run: obj_dir/V$(TOP_NAME)
	./obj_dir/V$(TOP_NAME)

clean:
	rm -rf obj_dir