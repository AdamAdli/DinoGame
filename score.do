# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules to working dir;
vlog -timescale 1ns/1ns DinoGame.v 

# Load simulation the following top level simulation module.
vsim GameScoreCounter

# Log and wave all signals.
log {/*}
add wave {/*}

# Simulation
force {clk} 0 0ns, 1 5ns -r 10ns
force {resetn} 0 0ns, 1 10ns
force {gameState} 4'b0000 0ns, 4'b0001 10ns
force {incrementEnable} 0 0ns, 1 5ns -r 10ns
run 240ns