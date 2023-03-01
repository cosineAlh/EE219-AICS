iverilog -o mc-cpu mc-cpu_tb.v mc-cpu.v 
vvp mc-cpu
gtkwave mc_risc_tb.vcd