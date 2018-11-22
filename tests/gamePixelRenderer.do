# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules to working dir;
vlog -timescale 1ps/1ps ../DinoGame.v ../Util.v ../dinospriteROM.v

# Load simulation the following top level simulation module.
vsim -L altera_mf_ver GamePixelRenderer

# Log and wave all signals.
log {/*}
add wave {/*}
property wave -radix Unsigned {/*}

# Simulation
force {clk} 0 0, 1 1 -r 2
force {frameClk} 1 1, 1 3, 0 5
force {resetn} 0 0, 1 2
force {enable} 0 0, 1 2
force {gameState} 0 0, 4'b0011
force {dinoY} 8'd93 2
force {obs1X} 8'd120 2
force {obs1H} 8'd7 2
force {obs2X} 8'd254 2
force {obs2H} 8'd14 2

run 5
force {frameClk} 0 0, 1 166666 -r 166668

# run 1
run 33798
#run 499998 
# run 40000ps
