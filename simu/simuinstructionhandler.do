# Simulation script for ModelSim

vlib work
vcom -93 ../src/instruction_memory.vhd
vcom -93 ../src/instruction_handler.vhd
vcom -93 ../simu/instruction_handler_tb.vhd

vsim -novopt instruction_handler_tb
add wave *
run -a
