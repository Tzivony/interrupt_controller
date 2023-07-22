verilate:
	verilator --cc --exe --build -j 0 --trace rtl/interrupt_controller.sv tb/sim_main.cpp

run:
	cd obj_dir; ./Vinterrupt_controller

gui:
	cd obj_dir; vcd2wlf waveform.vcd waveform.wlf; vsim -view waveform.wlf
