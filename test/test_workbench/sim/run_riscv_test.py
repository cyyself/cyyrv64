#!/usr/bin/env python3

import os
# build riscv-tests to this folder
BUILD_DIR = "riscv-tests-build/isa"
DST_DIR = "./tests-bin"
TEST_PRIFIX = ["rv64ui-p-","rv64um-p-","rv64mi-p-"]
RISCV_PREFIX = "riscv64-unknown-linux-gnu-"

file_list = []
for (dirpath, dirnames, filenames) in os.walk(BUILD_DIR):
    for x in filenames:
        if x.endswith(".dump"):
            continue
        for y in TEST_PRIFIX:
            if x.startswith(y):
                file_list.append(x)
file_list.sort()

def make_test():
    os.system("mkdir -p {}".format(DST_DIR))
    for x in file_list:
        os.system("{}objcopy -O binary {}/{} {}/{}.bin".format(RISCV_PREFIX,BUILD_DIR,x,DST_DIR,x))

def run_all():
    for x in file_list:
        print("Testing {}: ".format(x),end="",flush=True)
        os.system("./obj_dir/Vtop_axi_wrapper {}/{}.bin -rvtest".format(DST_DIR,x))

make_test()
run_all()