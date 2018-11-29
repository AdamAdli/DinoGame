# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules to working dir;
vlog -timescale 1ns/1ns ../src/DinoGame.v ../src/Util.v

# Load simulation the following top level simulation module.
vsim DinoGame

# Log and wave all signals.
#log {/*}
log -r /*
add wave {/*}

# Simulation
#force {frameClk} 0 0ns, 1 5ns -r 10ns
#force {obsClk} 0 0ns, 1 5ns -r 10ns
#force {gameState} 4'b0000 0ns, 4'b0011 10ns

force {clk} 0 0ns, 1 5ns -r 10ns
force {resetn} 0 0ns, 1 50ns
force {pause} 0 0ns, 1 100ns, 0 120ns, 1 140ns, 0 160ns
force {jump} 0 0ns, 1 20ns, 0 40ns, 1 60 ns, 0 80ns, 1 1300ns, 0 1310ns
run 1500ns
