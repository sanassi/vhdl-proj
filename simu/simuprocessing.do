# Simulation script for ModelSim

vlib work
vcom -93 ../src/alu.vhd
vcom -93 ../src/reg_bench.vhd
vcom -93 ../src/process_unit.vhd

vcom -93 ../tests/reg_bench_tb.vhd

vsim -novopt alu_tb
add wave *
run -a
