# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules to working dir;
vlog -timescale 1ns/1ns DinoGame.v 

# Load simulation the following top level simulation module.
vsim GameControl

# Log and wave all signals.
log {/*}
add wave {/*}

# 20ns - 40ns: From Menu to Running.
# 100 - 110ns: From Running to Pause.
# 140 - 160ns: Unpause.
# 180 - 200ns: Collide (to Game Over).
# 220 - 240ns: Back to Menu.

# Note: I used Pause for Start (wire) after 40ns.

# Simulation
force {clk} 0 0ns, 1 5ns -r 10ns
force {resetn} 0 0ns, 1 10ns
force {pause} 0 0ns, 1 100ns, 0 120ns, 1 140ns, 0 160ns, 1 220ns, 0 240ns
force {jump} 0 0ns, 1 20ns, 0 40ns, 1 60 ns, 0 80ns
force {collide} 0 0ns, 1 180ns, 0 200ns
run 300ns
