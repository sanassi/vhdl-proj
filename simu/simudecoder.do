# Simulation script for ModelSim

vlib work
vcom -93 ../src/alu.vhd
vcom -93 ../src/data_memory.vhd
vcom -93 ../src/multiplexer_2_to_1.vhd
vcom -93 ../src/sign_extension.vhd
vcom -93 ../src/instruction_handler.vhd
vcom -93 ../src/instruction_memory.vhd
vcom -93 ../src/reg_bench.vhd
vcom -93 ../src/process_unit.vhd
vcom -93 ../tests/process_unit_tb.vhd

vsim -novopt decoder_tb
add wave *
run -a
