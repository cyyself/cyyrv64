.PHONY: obj_dir/Vsim_soc_top
TRACE_TIME := 100000
run: obj_dir/Vsim_soc_top
	@obj_dir/Vsim_soc_top

trace.vcd: obj_dir/Vsim_soc_top
	@obj_dir/Vsim_soc_top -trace $(TRACE_TIME)

obj_dir/Vsim_soc_top:
	make -C ../workbench
	verilator --cc -Wno-fatal --trace --trace-structs --exe -LDFLAGS "-lncurses" --build sim_main.cpp ../../src/*.sv ../../src/pipeline/*.sv -y ../../src/pipeline