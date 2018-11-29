# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules to working dir;
vlog -timescale 1ns/1ns ../src/DinoGame.v

# Load simulation the following top level simulation module.
vsim LFSR4bit

# Log and wave all signals.
#log {/*}
log -r /*
add wave {/*}

# Simulation
force {reset} 0 0ps, 1 20ps 
force {clk} 0 0ps, 1 5ps -r 10ps
force {enable} 0 0ps, 1 5ps -r 10ps
run 100ps
