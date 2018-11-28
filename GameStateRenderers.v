`include "./DinoGameConstants.v"
`include "./DinoPixelRenderer.v"

module GameRunningRenderer(input clk, frameClk, resetn, input `ubyte x, y, input `ubyte dinoY, obs1X, obs1H, obs2X, obs2H, 
    output reg [2:0] color);
    wire [2:0] dinoColor;
    DinoPixelRenderer dinoRenderer(.clk(clk), .frameClk(frameClk), .resetn(resetn), .x(x), .y(y), .gameState(`GAME_RUNNING), .dinoY(dinoY), .color(dinoColor));
    always @(posedge clk) begin
        color = `colBG; // Default color is background.
        if (y >= `groundTop) color = `colGrnd; // Ground.
        else if (x >= `dinoLeft && x < `dinoRight  && y >= dinoY && y < dinoY + `dinoH && dinoColor != `colDinoTransparentMask) color = dinoColor; // Dino    
        else if (x >= obs1X && x < obs1X + `obsW && y >= `groundTop - obs1H) color = `colObs1; // obs 1
        else if (x >= obs2X && x < obs2X + `obsW && y >= `groundTop - obs2H) color = `colObs2; // obs 2
    end
endmodule

module GameMenuRenderer(input clk, frameClk, resetn, input `ubyte x, y, input `ubyte dinoY, obs1X, obs1H, obs2X, obs2H, 
    output reg [2:0] color);
    wire [2:0] dinoColor;
    DinoPixelRenderer dinoRenderer(.clk(clk), .frameClk(frameClk), .resetn(resetn), .x(x), .y(y), .gameState(`GAME_RUNNING), .dinoY(dinoY), .color(dinoColor));
    always @(posedge clk) begin
        color = `colBG; // Default color is background.
        if (y >= `groundTop) color = `colGrnd; // Ground.
        else if (x >= `dinoLeft && x < `dinoRight  && y >= dinoY && y < dinoY + `dinoH && dinoColor != `colDinoTransparentMask) color = dinoColor; // Dino    
        else if (x >= obs1X && x < obs1X + `obsW && y >= `groundTop - obs1H) color = `colObs1; // obs 1
        else if (x >= obs2X && x < obs2X + `obsW && y >= `groundTop - obs2H) color = `colObs2; // obs 2
    end
endmodule

module GamePauseRenderer(input clk, frameClk, resetn, input `ubyte x, y, input `ubyte dinoY, obs1X, obs1H, obs2X, obs2H, 
    output reg [2:0] color);
    wire [2:0] dinoColor;
    DinoPixelRenderer dinoRenderer(.clk(clk), .frameClk(frameClk), .resetn(resetn), .x(x), .y(y), .gameState(`GAME_RUNNING), .dinoY(dinoY), .color(dinoColor));
    always @(posedge clk) begin
        color = `colBG; // Default color is background.
        if (y >= `groundTop) color = `colGrnd; // Ground.
        else if (x >= `dinoLeft && x < `dinoRight  && y >= dinoY && y < dinoY + `dinoH && dinoColor != `colDinoTransparentMask) color = dinoColor; // Dino    
        else if (x >= obs1X && x < obs1X + `obsW && y >= `groundTop - obs1H) color = `colObs1; // obs 1
        else if (x >= obs2X && x < obs2X + `obsW && y >= `groundTop - obs2H) color = `colObs2; // obs 2
    end
endmodule

module GameOverRenderer(input clk, frameClk, resetn, input `ubyte x, y, input `ubyte dinoY, obs1X, obs1H, obs2X, obs2H, 
    output reg [2:0] color);
    wire [2:0] dinoColor;
    DinoPixelRenderer dinoRenderer(.clk(clk), .frameClk(frameClk), .resetn(resetn), .x(x), .y(y), .gameState(`GAME_RUNNING), .dinoY(dinoY), .color(dinoColor));
    always @(posedge clk) begin
        color = `colBG; // Default color is background.
        if (y >= `groundTop) color = `colGrnd; // Ground.
        else if (x >= `dinoLeft && x < `dinoRight  && y >= dinoY && y < dinoY + `dinoH && dinoColor != `colDinoTransparentMask) color = dinoColor; // Dino    
        else if (x >= obs1X && x < obs1X + `obsW && y >= `groundTop - obs1H) color = `colObs1; // obs 1
        else if (x >= obs2X && x < obs2X + `obsW && y >= `groundTop - obs2H) color = `colObs2; // obs 2
    end
endmodule
