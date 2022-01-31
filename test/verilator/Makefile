.PHONY: obj_dir/Vcpu_top
run: obj_dir/Vcpu_top
	@obj_dir/Vcpu_top

obj_dir/Vcpu_top:
	make -C ../workbench
	verilator --cc -Wno-fatal --exe --build sim_main.cpp ../../src/*.sv ../../src/pipeline/*.sv -y ../../src/pipeline