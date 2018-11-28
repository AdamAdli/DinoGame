`include "./DinoGameConstants.v"
`include "./GameRunningRenderer.v"

module GamePixelRenderer(input clk, frameClk, resetn, enable, input [3:0] gameState, input `ubyte dinoY, obs1X, obs1H, obs2X, obs2H, 
    output reg `ubyte x, y, output reg [2:0] color, output reg plotPixel);
    wire [2:0] dinoColor;
    wire [2:0] mycolor;
    DinoPixelRenderer dinoRenderer(.clk(clk), .frameClk(frameClk), .resetn(resetn), .x(x), .y(y), .gameState(gameState), .dinoY(dinoY), .color(dinoColor));
    GameRunningRenderer gameRunningRenderer(.clk(clk), .frameClk(frameClk), .resetn(resetn), .ldClk(clk), .gameState(gameState),
        .dinoY(dinoY), .obs1X(obs1X), .obs1H(obs1H), .obs2X(obs2X), .obs2H(obs2H),
        .x(x), .y(y), .color(mycolor));
    reg [1:0] frameCounter; 
    always @(posedge clk) begin
        if (!resetn) begin
            x <= 0; 
            y <= 0;
            color <= `colBG;
            plotPixel <= 0;
            frameCounter <= 2'd0;
        end else if (enable && ((frameClk) || (x || y))) begin
            if ((frameCounter >= 2)) begin
                if (x < `xMAX) x <= x + 1;
                else begin 
                    x <= 0;
                    if (y < `yMAX) y <= y + 1;
                    else y <= 0;
                end
                plotPixel <= 0;
                frameCounter <= frameCounter - 2'd1;            
            end else if (frameCounter == 1) begin
                if (gameState == `GAME_RUNNING) color = mycolor;
                else color = `colBG;
                plotPixel <= 0;
                frameCounter <= frameCounter - 2'd1;
            end else begin
                plotPixel <= 1;
                frameCounter <= 2'd2;
            end
            /*if (plotPixel) begin
                if (x < `xMAX) x <= x + 1;
                else begin 
                    x <= 0;
                    if (y < `yMAX) y <= y + 1;
                    else y <= 0;
                end
            end

                if (gameState == `GAME_RUNNING) color = mycolor;
                else color = `colBG;
                /*color <= `colBG; // Default color is background.
                if (y >= `groundTop) color <= `colGrnd; // Ground.
                else if (x >= `dinoLeft && x < `dinoRight  && y >= dinoY && y < dinoY + `dinoH && dinoColor != `colDinoTransparentMask) color <= dinoColor; // Dino    
                else if (x >= obs1X && x < obs1X + `obsW && y >= `groundTop - obs1H) color <= `colObs1; // obs 1
                else if (x >= obs2X && x < obs2X + `obsW && y >= `groundTop - obs2H) color <= `colObs2; // obs 2*/

        end else if (frameCounter == 1) begin
            if (gameState == `GAME_RUNNING) color = mycolor;
            else color = `colBG;
            plotPixel <= 0;
            frameCounter <= frameCounter - 2'd1;
        end else begin
            plotPixel <= 0;
            frameCounter <= 2'd2;
        end
    end
endmodule