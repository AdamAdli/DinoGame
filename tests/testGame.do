# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules to working dir;
vlog -timescale 1ps/1ps ../src/DinoGame.v

# Load simulation the following top level simulation module.
vsim -L altera_mf_ver TestDinoGame

# Log and wave all signals.
log {/*}
add wave {/*}
#add wave {/TestDinoGame/gameImpl/gameLogic/dinoJumper/*}
#add wave {/TestDinoGame/gameImpl/gameLogic/*}
#add wave {/TestDinoGame/gameImpl/gamePixelRenderer/gameColorRenderer/gameRunningRenderer/*}
#add wave {/TestDinoGame/gameImpl/gamePixelRenderer/gameColorRenderer/gameRunningRenderer/bgRenderer/*}
#add wave {/TestDinoGame/gameControl/debug_state_text_signal}
add wave {/TestDinoGame/gameImpl/gamePixelRenderer/*}
add wave {/TestDinoGame/gameImpl/gamePixelRenderer/gameColorRenderer/*}
add wave {/TestDinoGame/gameImpl/gamePixelRenderer/gameColorRenderer/gameRunningRenderer/*}
#add wave {/TestDinoGame/gameImpl/gameLogic/gameScoreCounter/*}
#add wave {/TestDinoGame/gameImpl/gamePixelRenderer/x}
#add wave {/TestDinoGame/gameImpl/gamePixelRenderer/y}
#add wave {/TestDinoGame/gameImpl/gamePixelRenderer/color}
#add wave {/TestDinoGame/gameImpl/gamePixelRenderer/*}
#add wave {/TestDinoGame/gameImpl/gamePixelRenderer/dinoRenderer/dinoController/*}
#add wave {/TestDinoGame/gameImpl/gamePixelRenderer/gameRunningRenderer/*}

property wave -radix Unsigned {/*}

# Simulation
force {clk} 0 0, 1 1 -r 2
force {resetn} 0 0, 1 2
force {jump} 0 0, 1 99182, 0 99282, 1 1547865, 0 1547867, 1 1557867, 0 1558867, 1 1658867
force {pause} 0 0, 1 1958867, 0 1998867, 1 2158867, 0 2198867
#, 1 600100ps, 0 600104ps

#99182 1frame
run 8000801ps
# run 200801ps
# run 5999940ps
# 1s = 5999940
#run 1200100ps