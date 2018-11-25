# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules to working dir;
vlog -timescale 1ns/1ns DinoGame.v Util.v

# Load simulation the following top level simulation module.
vsim GameLogic

# Log and wave all signals.
log {/*}
add wave {/*}

# Simulation
force {clk} 0 0ns, 1 5ns -r 10ns
force {frameClk} 0 0ns, 1 5ns -r 10ns
force {obsClk} 0 0ns, 1 5ns -r 10ns
force {gameState} 4'b0000 0ns, 4'b0011 10ns
run 1500ns
