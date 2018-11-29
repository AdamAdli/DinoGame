`include "./Util.v"
`include "./DinoGameConstants.v"
`include "./GameLogic.v"
`include "./GameRenderer.v"
`include "./GameScore.v"

/* Dinosaur Verilog Game */
module DinoGame(input CLOCK_50, input [2:0] KEY, output [0:0] LEDR, output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, 
		output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, output [9:0] VGA_R, VGA_G, VGA_B);

	/* Wires */
	wire clk, jump, pause, resetn;
	wire [3:0] gameState;
	wire collision;
	wire [3:0] s_ones, s_tens, s_hundreds, s_thousands, s_tenthousands, s_hunthousands;

	/* Specific Wires for VGA */
	wire [2:0] color;
	wire `ubyte x, y;
    wire plotPixel;

	/* Assignment Statements */
	assign clk = CLOCK_50;
	assign jump = ~KEY[0]; // Active-High Jump.
	assign pause = ~KEY[1]; // Active-High Pause.
	assign resetn = KEY[2]; // Active-Low Reset.

	/* VGA Display */
   vga_adapter VGA(.clock(clk), .resetn(resetn), .colour(color), .x(x), .y(y[6:0]), .plot(plotPixel), .VGA_R(VGA_R), .VGA_G(VGA_G), 
		.VGA_B(VGA_B), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_BLANK(VGA_BLANK_N), .VGA_SYNC(VGA_SYNC_N), .VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
      defparam VGA.BACKGROUND_IMAGE = "black.mif";

    GameControl gameControl(.clk(clk), .resetn(resetn), .pause(pause), .jump(jump), .collision(collision), .gameState(gameState));
    GameImplementation gameImpl(.clk(clk), .resetn(resetn), .pause(pause), .jump(jump), .gameState(gameState), .collision(collision), .x(x), .y(y), .color(color), .plotPixel(plotPixel),
        .s_ones(s_ones), .s_tens(s_tens), .s_hundreds(s_hundreds), .s_thousands(s_thousands), .s_tenthousands(s_tenthousands), .s_hunthousands(s_hunthousands));
    GameScoreView gameScoreView(.s_ones(s_ones), .s_tens(s_tens), .s_hundreds(s_hundreds), .s_thousands(s_thousands), .s_tenthousands(s_tenthousands), .s_hunthousands(s_hunthousands), 
        .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5));

	/* Single LEDR is on when game runs */
	assign LEDR[0] = (gameState == `GAME_RUNNING);
endmodule

module TestDinoGame(input clk, resetn, pause, jump,
    // Visualization outputs
    output `ubyte x, y, output [2:0] color, output plotPixel,
    output [3:0] s_ones, s_tens, s_hundreds, s_thousands, s_tenthousands, s_hunthousands);

    wire [3:0] gameState;
    wire collision;

    GameControl gameControl(.clk(clk), .resetn(resetn), .pause(pause), .jump(jump), .collision(collision), .gameState(gameState));
    GameImplementation gameImpl(.clk(clk), .resetn(resetn), .pause(pause), .jump(jump), .gameState(gameState), .collision(collision), .x(x), .y(y), .color(color), .plotPixel(plotPixel),
        .s_ones(s_ones), .s_tens(s_tens), .s_hundreds(s_hundreds), .s_thousands(s_thousands), .s_tenthousands(s_tenthousands), .s_hunthousands(s_hunthousands));
endmodule

/* Datapath: Sends Signals */
module GameImplementation(input clk, resetn, pause, jump, input [3:0] gameState, 
    // Controller outputs
    output collision,
    // Visualization outputs
    output `ubyte x, y, output [2:0] color, output plotPixel,
    output [3:0] s_ones, s_tens, s_hundreds, s_thousands, s_tenthousands, s_hunthousands);

    wire `ubyte dinoY, obs1X, obs1H, obs2X, obs2H;    

    wire [20:0] c0;
    DelayCounterTest rate_div(.clk(clk), .resetn(resetn), .enable(1'd1), .cycle_count(c0));
    wire frameClk = (c0 == 0);

    GameLogic gameLogic(.clk(clk), .frameClk(frameClk), .resetn(resetn), .jump(jump), .gameState(gameState),
        .dinoY(dinoY), .obs1X(obs1X), .obs1H(obs1H), .obs2X(obs2X), .obs2H(obs2H), .collision(collision), 
        .s_ones(s_ones), .s_tens(s_tens), .s_hundreds(s_hundreds), .s_thousands(s_thousands), .s_tenthousands(s_tenthousands), .s_hunthousands(s_hunthousands));
    GamePixelRenderer gamePixelRenderer(.clk(clk), .frameClk(frameClk), .resetn(resetn), .enable(1'd1), .gameState(gameState),
        .dinoY(dinoY), .obs1X(obs1X), .obs1H(obs1H), .obs2X(obs2X), .obs2H(obs2H),
        .x(x), .y(y), .color(color), .plotPixel(plotPixel));
endmodule

/* Controller: Finite State Machine  */
module GameControl(input clk, resetn, pause, jump, collision, output reg [3:0] gameState);
    reg [3:0] current_state, next_state;

    wire startGame = (pause || jump);

    /* State Table */
    always @(*) begin
        case (current_state)
            `GAME_MENU: next_state = startGame ? `GAME_MENU_WAIT : `GAME_MENU;
            `GAME_MENU_WAIT: next_state = startGame ? `GAME_MENU_WAIT : `GAME_RUNNING;
            `GAME_RUNNING: begin 
                if (collision) next_state = `GAME_OVER;
                else next_state = pause ? `GAME_RUNNING_WAIT : `GAME_RUNNING;
            end
            `GAME_RUNNING_WAIT: next_state = pause ? `GAME_RUNNING_WAIT : `GAME_PAUSE;
            `GAME_PAUSE: next_state = pause ? `GAME_PAUSE_WAIT : `GAME_PAUSE;
            `GAME_PAUSE_WAIT: next_state = pause ? `GAME_PAUSE_WAIT : `GAME_RUNNING;
            `GAME_OVER: next_state = startGame ? `GAME_OVER_WAIT_1 : `GAME_OVER;
            `GAME_OVER_WAIT_1: next_state = startGame ? `GAME_OVER_WAIT_1 : `GAME_OVER_WAIT_2;
            `GAME_OVER_WAIT_2: next_state = `GAME_MENU;
            default: next_state = `GAME_MENU;
        endcase
    end
    
    /* Output Logic */
    always @(*) begin
        gameState = `GAME_MENU;
        case (current_state)
            `GAME_MENU: gameState = `GAME_MENU;
            `GAME_MENU_WAIT: gameState = `GAME_MENU;
            `GAME_RUNNING: gameState = `GAME_RUNNING;
            `GAME_RUNNING_WAIT: gameState = `GAME_RUNNING;
            `GAME_PAUSE: gameState = `GAME_PAUSE;
            `GAME_PAUSE_WAIT: gameState = `GAME_PAUSE;
            `GAME_OVER: gameState = `GAME_OVER;
            `GAME_OVER_WAIT_1: gameState = `GAME_OVER;
            `GAME_OVER_WAIT_2: gameState = `GAME_OVER;
            default: gameState = `GAME_MENU;
        endcase
    end

    /* Asynchronous Reset. */
    always @(posedge clk) begin
        if (!resetn) current_state <= `GAME_MENU;
        else current_state <= next_state;
    end
    
    /* TODO: USE THIS FOR DEBUGGING */
    reg [8*8-1:0] debug_state_text_signal;
    always @(current_state) begin 
        case(current_state)
            `GAME_MENU: debug_state_text_signal = "MENU    ";
            `GAME_MENU_WAIT: debug_state_text_signal = "MENU_W  ";
            `GAME_RUNNING: debug_state_text_signal = "RUN     ";
            `GAME_RUNNING_WAIT: debug_state_text_signal = "RUN_W   ";
            `GAME_PAUSE: debug_state_text_signal = "PAUSE   ";
            `GAME_PAUSE_WAIT: debug_state_text_signal = "PAUSE_W ";
            `GAME_OVER: debug_state_text_signal = "OVER    ";
            `GAME_OVER_WAIT_1: debug_state_text_signal = "OVER_W_1";
            `GAME_OVER_WAIT_2: debug_state_text_signal = "OVER_W_2";
            default: debug_state_text_signal = "UNKNOWN ";
        endcase
    end
endmodule
