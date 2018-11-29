# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules to working dir;
vlog -timescale 1ps/1ps ../DinoGame.v ../Util.v ../dinospriteROM.v

# Load simulation the following top level simulation module.
vsim -L altera_mf_ver GameImplementation

# Log and wave all signals.
log {/*}
#add wave {/*}
add wave {/GameImplementation/gameLogic/*}
#add wave {/GameImplementation/gameLogic/gameScoreCounter/*}
#add wave {/GameImplementation/gamePixelRenderer/x}
#add wave {/GameImplementation/gamePixelRenderer/y}
#add wave {/GameImplementation/gamePixelRenderer/color}
add wave {/GameImplementation/gamePixelRenderer/*}
#add wave {/GameImplementation/gamePixelRenderer/dinoRenderer/dinoController/*}
#add wave {/GameImplementation/gamePixelRenderer/gameRunningRenderer/*}

property wave -radix Unsigned {/*}

# Simulation
force {clk} 0 0, 1 1 -r 2
force {resetn} 0 0, 1 2
force {jump} 0 0, 1 600100ps, 0 600104ps
force {gameState} 0 0, 4'b0011 5

run 5999940ps
# 1s = 5999940
#run 1200100ps