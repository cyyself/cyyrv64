.PHONY: obj_dir/Vsim_soc_top
run: obj_dir/Vsim_soc_top
	@obj_dir/Vsim_soc_top

obj_dir/Vsim_soc_top:
	make -C ../workbench
	verilator --cc -Wno-fatal --exe -LDFLAGS "-lncurses" --build sim_main.cpp ../../src/*.sv ../../src/pipeline/*.sv -y ../../src/pipeline