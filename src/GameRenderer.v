`include "./DinoGameConstants.v"
`include "./Rendering/GameStateRenderers.v"

module GamePixelRenderer(input clk, frameClk, resetn, enable, input [3:0] gameState, input `ubyte dinoY, obs1X, obs1H, obs2X, obs2H, 
    output reg `ubyte x, y, output [2:0] color, output reg plotPixel);
    reg frameSnapped;
    reg `ubyte f_dinoY, f_obs1X, f_obs1H, f_obs2X, f_obs2H; // Frame snapshot.
    GameColorRenderer gameColorRenderer(.clk(clk), .frameClk(frameClk), .resetn(resetn), .gameState(gameState),
        .dinoY(f_dinoY), .obs1X(f_obs1X), .obs1H(f_obs1H), .obs2X(f_obs2X), .obs2H(f_obs2H),
        .x(x), .y(y), .color(color));
    /*  When plotPixel, that means the color of the current x,y is loaded and should be plotted & x,y updated.
        When !plotPixel, x,y was changed, we must wait 1 cycle for the new color to be loaded; DON'T draw with invalidated color!*/
    always @(posedge clk) begin
        if (!resetn) begin
            x <= 0; 
            y <= 0;
            plotPixel <= 0;
            f_dinoY <= `groundTop - `dinoH;
            f_obs1X <= 120;
            f_obs1H <= `minObsH;
            f_obs2X <= 254;
            f_obs2H <= `maxObsH;
            frameSnapped <= 0;
        end else if (enable) begin
            if (frameClk) begin
                f_dinoY <= dinoY;
                f_obs1X <= obs1X;
                f_obs1H <= obs1H;
                f_obs2X <= obs2X;
                f_obs2H <= obs2H;
                frameSnapped <= 1; 
            end else if (frameSnapped || x || y || plotPixel) begin
                frameSnapped <= 0;
                if (plotPixel) begin
                    if (x < `xMAX) x <= x + 1;
                    else begin 
                        x <= 0;
                        if (y < `yMAX) y <= y + 1;
                        else y <= 0;
                    end
                    $display("%d, ", color);
                end
                plotPixel <= plotPixel - 1;
            end
        end
    end
endmodule

module GameColorRenderer(input clk, frameClk, resetn, input `ubyte x, y, input [3:0] gameState, input `ubyte dinoY, obs1X, obs1H, obs2X, obs2H, 
    output [2:0] color);
    wire [2:0] gameRunningColor;
    GameRunningRenderer gameRunningRenderer(.clk(clk), .frameClk(frameClk), .resetn(resetn),
        .dinoY(dinoY), .obs1X(obs1X), .obs1H(obs1H), .obs2X(obs2X), .obs2H(obs2H),
        .x(x), .y(y), .color(gameRunningColor));
    wire [2:0] gameMenuColor;
    GameMenuRenderer gameMenuRenderer(.clk(clk), .frameClk(frameClk), .resetn(resetn),
        .dinoY(dinoY), .obs1X(obs1X), .obs1H(obs1H), .obs2X(obs2X), .obs2H(obs2H),
        .x(x), .y(y), .color(gameMenuColor));
    wire [2:0] gamePauseColor;
    GamePauseRenderer gamePauseRenderer(.clk(clk), .frameClk(frameClk), .resetn(resetn),
        .dinoY(dinoY), .obs1X(obs1X), .obs1H(obs1H), .obs2X(obs2X), .obs2H(obs2H),
        .x(x), .y(y), .color(gamePauseColor));
    wire [2:0] gameOverColor;
    GameOverRenderer gameOverRenderer(.clk(clk), .frameClk(frameClk), .resetn(resetn),
        .dinoY(dinoY), .obs1X(obs1X), .obs1H(obs1H), .obs2X(obs2X), .obs2H(obs2H),
        .x(x), .y(y), .color(gameOverColor));
    /*always @(posedge clk) begin
        case (gameState)
            `GAME_MENU: color = gameMenuColor;
            `GAME_RUNNING: color = gameRunningColor;
            `GAME_PAUSE: color = gamePauseColor;
            `GAME_OVER: color = gameOverColor;
            default: color = `colBG;
        endcase
    end*/
    // This allows us to not use reg (remove a cycle delay):
    assign color = gameState == `GAME_MENU ? gameMenuColor 
                    : (gameState == `GAME_RUNNING ? gameRunningColor 
                        : (gameState == `GAME_PAUSE ? gamePauseColor 
                            : (gameState == `GAME_OVER ? gameOverColor : `colBG)));
endmodule