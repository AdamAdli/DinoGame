`define ubyte [7:0] 
`define uint [31:0]

/* Dimensions */
`define xMAX 159
`define yMAX 119
// `define dinoX 16
// `define dinoW 10
`define dinoLeft 15
`define dinoRight 25
`define dinoH 12
`define obsW 12
`define minObsH 7
`define maxObsH 14

`define groundTop 105

/* Colors */
`define colBG 3'b011
`define colDino 3'b010
`define colObs1 3'b100
`define colObs2 3'b101
`define colGrnd 3'b110

/* Game States */
`define GAME_MENU           4'b0000
`define GAME_MENU_WAIT      4'b0001
`define GAME_RUNNING        4'b0011
`define GAME_RUNNING_WAIT   4'b0111
`define GAME_PAUSE          4'b1111
`define GAME_PAUSE_WAIT     4'b1011
`define GAME_OVER           4'b0010
`define GAME_OVER_WAIT_1    4'b0110
`define GAME_OVER_WAIT_2    4'b0100  // We split this to avoid race issue between flipping bits causing weird momentary states.

/* Dinosaur Verilog Game */
module DinoGame(input CLOCK_50, input [2:0] KEY, output [0:0] LEDR,
        output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
        output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N,
        output [9:0] VGA_R, VGA_G, VGA_B);
    // ~KEY[0] = JUMP, ~KEY[1] = PAUSE, KEY[2] = resetn.
	/* Wires */
	wire clk, jump, pause, resetn;
	
	/* Assignment Statements */
	assign clk = CLOCK_50;
	assign jump = ~KEY[0]; // Active-High Jump.
	assign pause = ~KEY[1]; // Active-High Pause.
	assign resetn = KEY[2]; // Active-Low resetn.

    // Create the colour, x, y and writeEn wires that are inputs to the controller.
    wire [2:0] color;
    wire `ubyte x, y;
    wire enableRender = 1;

    vga_adapter VGA(.clock(clk), .resetn(resetn),
            .colour(color), .x(x), .y(y[6:0]), .plot(enableRender),
            /* Signals for the DAC to drive the monitor. */
            .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B),
            .VGA_HS(VGA_HS), .VGA_VS(VGA_VS),
            .VGA_BLANK(VGA_BLANK_N), .VGA_SYNC(VGA_SYNC_N), .VGA_CLK(VGA_CLK));
        defparam VGA.RESOLUTION = "160x120";
        defparam VGA.MONOCHROME = "FALSE";
        defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
        defparam VGA.BACKGROUND_IMAGE = "black.mif";

    wire [3:0] gameState;
    wire `ubyte dinoY, obs1X, obs1H, obs2X, obs2H;
    wire collision;
    wire [3:0] s_ones, s_tens, s_hundreds, s_thousands, s_tenthousands, s_hunthousands;
    GameControl gameControl(.clk(clk), .resetn(resetn), .pause(pause), .jump(jump), .collide(collision),
        .gameState(gameState));
    GameLogic gameLogic(.clk(clk), .resetn(resetn), .jump(jump), .gameState(gameState),
        .dinoY(dinoY), .obs1X(obs1X), .obs1H(obs1H), .obs2X(obs2X), .obs2H(obs2H), .collision(collision), 
        .s_ones(s_ones), .s_tens(s_tens), .s_hundreds(s_hundreds), .s_thousands(s_thousands), .s_tenthousands(s_tenthousands), .s_hunthousands(s_hunthousands));
    GamePixelRenderer gamePixelRenderer(.clk(clk), .resetn(resetn), .enable(enableRender), 
        .x(x), .y(y), .color(color));

    GameScoreView gameScoreView(.s_ones(s_ones), .s_tens(s_tens), .s_hundreds(s_hundreds), .s_thousands(s_thousands), .s_tenthousands(s_tenthousands), .s_hunthousands(s_hunthousands), 
        .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5));

    assign LEDR[0] = (gameState == `GAME_RUNNING);
endmodule

/* Datapath: Sends Signals */
module GameLogic(input clk, resetn, jump, input [3:0] gameState, output reg `ubyte dinoY, 
    obs1X, obs1H, obs2X, obs2H, output reg collision, output [3:0] s_ones, s_tens, s_hundreds, s_thousands, s_tenthousands, s_hunthousands);
    // Max score is 999999 (6 hex displays) and log2(999999) = 19.93
    reg `ubyte colObsL, colObsR, colObsT;
    reg [2:0] gameSpeed = 1; // TODO: Adjust gamesped.
    wire shouldJump = (jump && (dinoY == `groundTop - `dinoH));
    
    wire [19:0] c0;
    delay_counter60 rate_div(.clk(clk), .resetn(resetn), .enable(1), .cycle_count(c0));
    wire [3:0] c1;
    frame_counter_skip1 frame_cnt(.clk(clk), .resetn(resetn), .enable((c0 == 19'd0)), .frame_count(c1));
    wire frame_clk = (c1 == 4'b0000 && c0 == 19'd1) ? 1 : 0;
    wire [3:0] c2;
    frame_counter_skipdyn frame_cnt_obs(.clk(clk), .resetn(resetn), .enable((c0 == 19'd0)), .skip({1'b0,gameSpeed}), .frame_count(c2));
    wire obs_clk = (c2 == 4'b0000 && c0 == 19'd1) ? 1 : 0;

    GameScoreCounter gameScoreCounter(.clk(clk), .resetn(resetn), .gameState(gameState), .incrementEnable(obs_clk), 
        .s_ones(s_ones), .s_tens(s_tens), .s_hundreds(s_hundreds), .s_thousands(s_thousands), .s_tenthousands(s_tenthousands), .s_hunthousands(s_hunthousands));

    always @(posedge clk) begin
        if (!resetn || gameState == `GAME_MENU) begin
            dinoY <= `groundTop - `dinoH;
            obs1X <= 120;
            obs1H <= `minObsH;
            obs2X <= 254;
            obs2H <= `maxObsH;
            collision <= 0;
        end else if (frame_clk) begin
            if (gameState == `GAME_RUNNING) begin

                // Adjust gamespeed.
                if (s_thousands >= 1) gameSpeed <= 3;
                else if (s_hundreds < 1) gameSpeed <= 1;
                else if (s_hundreds < 5) gameSpeed <= 2;
                
                // Jump/Dino Y. This could be improved.
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
                if (colObsL >= `dinoLeft || colObsL < `dinoRight || colObsR >= `dinoRight || colObsR - 1 < `dinoRight) begin                 
                    if (colObsT >= dinoY && colObsT < dinoY + `dinoH) begin // Collision!
                        collision <= 1;
                    end
                end

                // Update Obstacles.
                if (obs_clk) begin
                    obs1X <= obs1X - 1;
                    obs2X <= obs2X - 1;
                end
            end
        end
    end
endmodule

module GamePixelRenderer(input clk, resetn, enable, input `ubyte dinoY, obs1X, obs1H, obs2X, obs2H, 
    output reg `ubyte x, y, output reg [2:0] color);
    always @(posedge clk) begin
        if (!resetn) begin
            x <= 0; 
            y <= 0;
            color <= `colBG;
        end else if (enable) begin
            if (x < `xMAX) x <= x + 1;
            else x <= 0;
            if (y < `yMAX) y <= y + 1;
            else y <= 0;

            color <= `colBG; // Default color is background.
            if (y >= `groundTop) color <= `colGrnd; // Ground.
            else if (x >= `dinoLeft && x < `dinoRight  && y >= dinoY && y < dinoY - `dinoH) color <= `colDino; // Dino    
            else if (x >= obs1X && x < obs1X + `obsW && y >= `groundTop - obs1H) color <= `colObs1; // obs 1
            else if (x >= obs2X && x < obs2X + `obsW && y >= `groundTop - obs2H) color <= `colObs2; // obs 2
        end
    end
endmodule

module GameScoreCounter(input clk, resetn, gameState, incrementEnable, output reg [3:0] s_ones, s_tens, s_hundreds, s_thousands, s_tenthousands, s_hunthousands);
    always @(posedge clk) begin
        if (!resetn || gameState == `GAME_MENU) begin
            s_ones <= 0; 
            s_tens <= 0; 
            s_hundreds <= 0; 
            s_thousands <= 0; 
            s_tenthousands <= 0;
            s_hunthousands <= 0;
        end else if (incrementEnable) begin
            s_ones = s_ones + 1;
            if (s_ones == 10) begin
                s_ones <= 0;
                s_tens = s_tens + 1;
                if (s_tens == 10) begin
                    s_tens <= 0;
                    s_hundreds = s_hundreds + 1;
                    if (s_hundreds == 10) begin
                        s_hundreds <= 0;
                        s_thousands = s_thousands + 1;
                        if (s_thousands == 10) begin
                            s_thousands <= 0;
                            s_tenthousands = s_tenthousands + 1;
                            if (s_tenthousands == 10) begin
                                s_tenthousands <= 0;
                                s_hunthousands = s_hunthousands + 1;
                            end
                        end
                    end
                end
            end
        end
    end
endmodule  

module GameScoreView(input [3:0] s_ones, s_tens, s_hundreds, s_thousands, s_tenthousands, s_hunthousands, output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
    hex_decoder h0(.hex_digit(s_ones), .segments(HEX0));
    hex_decoder h1(.hex_digit(s_tens), .segments(HEX1));
    hex_decoder h2(.hex_digit(s_hundreds), .segments(HEX2));
    hex_decoder h3(.hex_digit(s_thousands), .segments(HEX3));
    hex_decoder h4(.hex_digit(s_tenthousands), .segments(HEX4));
    hex_decoder h5(.hex_digit(s_hunthousands), .segments(HEX5));
endmodule

/* Controller:  */
module GameControl(input clk, resetn, pause, jump, collide, output reg [3:0] gameState);
    reg [3:0] current_state, next_state;

    wire startGame = (pause || jump);

    // State Table
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
    
    // Output Logic
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

    // Current State Register
    always @(posedge clk) begin
        if (!resetn) current_state <= `GAME_MENU;
        else current_state <= next_state;
    end
    
    // TODO: USE THIS FOR DEBUG.
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