# Simulation script for ModelSim

vlib work
vcom -93 ../src/alu.vhd
vcom -93 ../tests/alu_tb.vhd
vsim -novopt alu_tb
add wave *
run -a
