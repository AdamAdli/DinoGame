`include "./Util.v"
`include "./DinoGameConstants.v"
`include "./DinoPixelRenderer.v"
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

    GameControl gameControl(.clk(clk), .resetn(resetn), .pause(pause), .jump(jump), .collide(collision), .gameState(gameState));
    GameImplementation gameImpl(.clk(clk), .resetn(resetn), .pause(pause), .jump(jump), .gameState(gameState), .collision (collision), .x(x), .y(y), .color(color), .plotPixel(plotPixel),
        .s_ones(s_ones), .s_tens(s_tens), .s_hundreds(s_hundreds), .s_thousands(s_thousands), .s_tenthousands(s_tenthousands), .s_hunthousands(s_hunthousands));
    /*GameLogic gameLogic(.clk(clk), .resetn(resetn), .jump(jump), .gameState(gameState),
        .dinoY(dinoY), .obs1X(obs1X), .obs1H(obs1H), .obs2X(obs2X), .obs2H(obs2H), .collision(collision), 
        .s_ones(s_ones), .s_tens(s_tens), .s_hundreds(s_hundreds), .s_thousands(s_thousands), .s_tenthousands(s_tenthousands), .s_hunthousands(s_hunthousands));
    GamePixelRenderer gamePixelRenderer(.clk(clk), .resetn(resetn), .enable(enableRender), 
        .x(x), .y(y), .color(color));*/
    GameScoreView gameScoreView(.s_ones(s_ones), .s_tens(s_tens), .s_hundreds(s_hundreds), .s_thousands(s_thousands), .s_tenthousands(s_tenthousands), .s_hunthousands(s_hunthousands), 
        .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5));

	/* Single LEDR is on when game runs */
	assign LEDR[0] = (gameState == `GAME_RUNNING);
endmodule

/* Datapath: Sends Signals */
module GameImplementation(input clk, resetn, pause, jump, input [3:0] gameState, 
    // Controller outputs
    output collision,
    // Visualization outputs
    output `ubyte x, y, output [2:0] color, output plotPixel,
    output [3:0] s_ones, s_tens, s_hundreds, s_thousands, s_tenthousands, s_hunthousands);

    wire `ubyte dinoY, obs1X, obs1H, obs2X, obs2H;    

    wire [19:0] c0;
    DelayCounterTest rate_div(.clk(clk), .resetn(resetn), .enable(1'd1), .cycle_count(c0));
    wire frameClk = (c0 == 0);

    GameLogic gameLogic(.clk(clk), .frameClk(frameClk), .resetn(resetn), .jump(jump), .gameState(gameState),
        .dinoY(dinoY), .obs1X(obs1X), .obs1H(obs1H), .obs2X(obs2X), .obs2H(obs2H), .collision(collision), 
        .s_ones(s_ones), .s_tens(s_tens), .s_hundreds(s_hundreds), .s_thousands(s_thousands), .s_tenthousands(s_tenthousands), .s_hunthousands(s_hunthousands));
    GamePixelRenderer gamePixelRenderer(.clk(clk), .frameClk(frameClk), .resetn(resetn), .enable(1), .gameState(gameState),
        .dinoY(dinoY), .obs1X(obs1X), .obs1H(obs1H), .obs2X(obs2X), .obs2H(obs2H),
        .x(x), .y(y), .color(color), .plotPixel(plotPixel));
endmodule

module GameLogic(input clk, frameClk, resetn, jump, input [3:0] gameState, output reg `ubyte dinoY, 
    obs1X, obs1H, obs2X, obs2H, output reg collision, output [3:0] s_ones, s_tens, s_hundreds, s_thousands, s_tenthousands, s_hunthousands);
    
    reg `ubyte colObsL, colObsR, colObsT;
    reg [2:0] gameSpeed = 3'd1; // TODO: Adjust gamesped.
    wire shouldJump = (jump && (dinoY == `groundTop - `dinoH));
    
    wire [3:0] c2;
    FrameSkipper obstacleFrameSkip(.clk(clk), .frameClk(frameClk), .resetn(resetn), .skipCount({1'b0, 3'd4 - gameSpeed}), .frame_count(c2));
    wire obsClk = (c2 == 0);

	 /* Max score is 999999 (6 Hex Displays) and log2(999999) = 19.93 */
    GameScoreCounter gameScoreCounter(.clk(clk), .resetn(resetn), .gameState(gameState), .incrementEnable(obsClk), 
        .s_ones(s_ones), .s_tens(s_tens), .s_hundreds(s_hundreds), .s_thousands(s_thousands), .s_tenthousands(s_tenthousands), .s_hunthousands(s_hunthousands));

    always @(posedge clk) begin
        if (!resetn || gameState == `GAME_MENU) begin
            dinoY <= `groundTop - `dinoH;
            obs1X <= 120;
            obs1H <= `minObsH;
            obs2X <= 254;
            obs2H <= `maxObsH;
            collision <= 0;
        end else if (frameClk) begin
            if (gameState == `GAME_RUNNING) begin

                // Adjust gamespeed.
                if (s_tenthousands >= 1 || s_hunthousands >= 1) gameSpeed <= 3;
                else if (s_thousands < 1) gameSpeed <= 1;
                else if (s_thousands >= 1) gameSpeed <= 2;
          
                
                // Jump/Dino Y. This could be improved. (Jump needs to be commented out for logic.do).
                if (dinoY == `groundTop - `dinoH) dinoY <= shouldJump ? dinoY - 20 : dinoY;
                else if (dinoY < `groundTop - `dinoH) dinoY <= dinoY + 2;
                else if (dinoY > `groundTop - `dinoH) dinoY <= `groundTop - `dinoH;

                // Collision setup.
                if (obs1X < obs2X && obs1X >= `dinoLeft - `obsW) begin
                    colObsL = obs1X;
                    colObsR = obs1X + `obsW;
                    colObsT = `groundTop - obs1H;
                end else begin
                    colObsL = obs2X;
                    colObsR = obs2X + `obsW;
                    colObsT = `groundTop - obs2H;
                end

                // Check collisions.
                // collision <= 0; //Commented THIS OUT (seems unnecessary?)
                if ((colObsL >= `dinoLeft && colObsL < `dinoRight) || (colObsR >= `dinoRight && colObsR - 1 < `dinoRight)) begin                 
                    //if (colObsT >= dinoY && colObsT < dinoY + `dinoH) collision <= 1; //OLD VERSION
						  if (colObsT <= dinoY + `dinoH) collision <= 1; // Nick's Maybe Working Ver?
                end

                // Update Obstacles.
                if (obsClk) begin
                    obs1X <= obs1X - 1;
                    obs2X <= obs2X - 1;
                end
            end
        end
    end
endmodule

module GamePixelRenderer(input clk, frameClk, resetn, enable, input [3:0] gameState, input `ubyte dinoY, obs1X, obs1H, obs2X, obs2H, 
    output reg `ubyte x, y, output reg [2:0] color, output reg plotPixel);
    wire [2:0] dinoColor;
    DinoPixelRenderer dinoRenderer(.clk(clk), .frameClk(frameClk), .resetn(resetn), .x(x), .y(y), .gameState(gameState), .dinoY(dinoY), .color(dinoColor));
    always @(posedge clk) begin
        if (!resetn) begin
            x <= 0; 
            y <= 0;
            color <= `colBG;
            plotPixel <= 0;
        end else if (enable && ((frameClk) || ((x || y) || plotPixel))) begin
            if (!plotPixel) begin
                if (x < `xMAX) x <= x + 1;
                else begin 
                    x <= 0;
                    if (y < `yMAX) y <= y + 1;
                    else y <= 0;
                end
            end else begin
                color <= `colBG; // Default color is background.
                if (y >= `groundTop) color <= `colGrnd; // Ground.
                else if (x >= `dinoLeft && x < `dinoRight  && y >= dinoY && y < dinoY + `dinoH && dinoColor != `colDinoTransparentMask) color <= dinoColor; // Dino    
                else if (x >= obs1X && x < obs1X + `obsW && y >= `groundTop - obs1H) color <= `colObs1; // obs 1
                else if (x >= obs2X && x < obs2X + `obsW && y >= `groundTop - obs2H) color <= `colObs2; // obs 2
            end
            plotPixel <= ~plotPixel;
        end
    end
endmodule

/* Controller: Finite State Machine  */
module GameControl(input clk, resetn, pause, jump, collide, output reg [3:0] gameState);
    reg [3:0] current_state, next_state;

    wire startGame = (pause || jump);

    /* State Table */
    always @(*) begin
        case (current_state)
            `GAME_MENU: next_state = startGame ? `GAME_MENU_WAIT : `GAME_MENU;
            `GAME_MENU_WAIT: next_state = startGame ? `GAME_MENU_WAIT : `GAME_RUNNING;
            `GAME_RUNNING: begin 
                if (collide) next_state = `GAME_OVER;
                else next_state = pause ? `GAME_RUNNING_WAIT : `GAME_RUNNING;
            end
            `GAME_RUNNING_WAIT: next_state = pause ? `GAME_RUNNING_WAIT : `GAME_PAUSE;
            `GAME_PAUSE: next_state = startGame ? `GAME_PAUSE_WAIT : `GAME_PAUSE;
            `GAME_PAUSE_WAIT: next_state = startGame ? `GAME_PAUSE_WAIT : `GAME_RUNNING;
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
