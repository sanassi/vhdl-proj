# Simulation script for ModelSim

vlib work
vcom -93 ../src/vic.vhd
vcom -93 ../tests/vic_tb.vhd

vsim -novopt vic_tb
add wave *
run -a

