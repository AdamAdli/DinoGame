`include "../DinoGameConstants.v"
`include "./DinoPixelRenderer.v"
`include "./BackgroundRenderer.v"
`include "./Sprites/GameOver/GameOverSpriteROM.v"
`include "./Sprites/Menu/TitleSpriteROM.v"
`include "./Sprites/Pause/PauseSpriteROM.v"

module GameRunningRenderer(input clk, frameClk, resetn, input `ubyte x, y, input `ubyte dinoY, obs1X, obs1H, obs2X, obs2H, 
    output reg [2:0] color);
    wire [2:0] dinoColor;
    DinoPixelRenderer dinoRenderer(.clk(clk), .frameClk(frameClk), .resetn(resetn), .x(x), .y(y), .gameState(`GAME_RUNNING), .dinoY(dinoY), .color(dinoColor));
    wire [2:0] bgColor;
    BackgroundRenderer bgRenderer(.clk(clk), .moveClk(frameClk), .resetn(resetn), .x(x), .y(y), .gameState(`GAME_RUNNING), .color(bgColor));
    always @(posedge clk) begin
        if (!resetn) color = `colBG;
        else begin
            color = bgColor; // Default color is background.
            if (y < `groundTop) begin
                if (x >= `dinoLeft && x < `dinoRight  && y >= dinoY && y < dinoY + `dinoH && dinoColor != `colDinoTransparentMask) color = dinoColor; // Dino    
                else if (x >= obs1X && x < obs1X + `obsW && y >= `groundTop - obs1H) color = `colObs1; // obs 1
                else if (x >= obs2X && x < obs2X + `obsW && y >= `groundTop - obs2H) color = `colObs2; // obs 2
            end
        end
    end
endmodule

module GameMenuRenderer(input clk, frameClk, resetn, input `ubyte x, y, input `ubyte dinoY, obs1X, obs1H, obs2X, obs2H, 
    output reg [2:0] color);
    wire [2:0] dinoColor;
    DinoPixelRenderer dinoRenderer(.clk(clk), .frameClk(frameClk), .resetn(resetn), .x(x), .y(y), .gameState(`GAME_MENU), .dinoY(dinoY), .color(dinoColor));
    wire [2:0] bgColor;
    BackgroundRenderer bgRenderer(.clk(clk), .moveClk(frameClk), .resetn(resetn), .x(x), .y(y), .gameState(`GAME_MENU), .color(bgColor));
    wire [2:0] titleColor;
    wire [11:0] titleSpriteAddressCalc = ((x - 18) + ((y - 46) * 122) + 1); 
    reg [11:0] spriteAddress;
    always @(*) begin
        if (titleSpriteAddressCalc >= 0 && titleSpriteAddressCalc < 3172) spriteAddress = titleSpriteAddressCalc;
        else spriteAddress = 0;     
    end
    // W: 122 H: 26 T: 46 L:18 R:140 B: 72
    TitleSpriteROM titleSprite(.clock(clk), .address(spriteAddress), .q(titleColor));
    always @(posedge clk) begin
        if (!resetn) color = `colBG;
        else begin
            color = bgColor; // Default color is background.
            if (y < `groundTop) begin
                if (x >= `dinoLeft && x < `dinoRight  && y >= dinoY && y < dinoY + `dinoH && dinoColor != `colDinoTransparentMask) color = dinoColor; // Dino    
                else if (x >= obs1X && x < obs1X + `obsW && y >= `groundTop - obs1H) color = `colObs1; // obs 1
                else if (x >= obs2X && x < obs2X + `obsW && y >= `groundTop - obs2H) color = `colObs2; // obs 2
            end
            if (x >= 18 && x < 140 && y >= 46 && y < 72 && titleColor != `colDinoTransparentMask) color = titleColor;
        end
    end
endmodule

module GamePauseRenderer(input clk, frameClk, resetn, input `ubyte x, y, input `ubyte dinoY, obs1X, obs1H, obs2X, obs2H, 
    output reg [2:0] color);
    wire [2:0] dinoColor;
    DinoPixelRenderer dinoRenderer(.clk(clk), .frameClk(frameClk), .resetn(resetn), .x(x), .y(y), .gameState(`GAME_PAUSE), .dinoY(dinoY), .color(dinoColor));
    wire [2:0] bgColor;
    BackgroundRenderer bgRenderer(.clk(clk), .moveClk(frameClk), .resetn(resetn), .x(x), .y(y), .gameState(`GAME_PAUSE), .color(bgColor));
    wire [2:0] titleColor;
    wire [10:0] titleSpriteAddressCalc = ((x - 33) + ((y - 49) * 92) + 1); 
    reg [10:0] spriteAddress;
    always @(*) begin
        if (titleSpriteAddressCalc >= 0 && titleSpriteAddressCalc < 1840) spriteAddress = titleSpriteAddressCalc;
        else spriteAddress = 0;     
    end
    // T: 49 L:33 W: 92 H: 20
    PauseSpriteROM pauseSprite(.clock(clk), .address(spriteAddress), .q(titleColor));
    always @(posedge clk) begin
        if (!resetn) color = `colBG;
        else begin
            color = bgColor; // Default color is background.
            if (y < `groundTop) begin
                if (x >= `dinoLeft && x < `dinoRight  && y >= dinoY && y < dinoY + `dinoH && dinoColor != `colDinoTransparentMask) color = dinoColor; // Dino    
                else if (x >= obs1X && x < obs1X + `obsW && y >= `groundTop - obs1H) color = `colObs1; // obs 1
                else if (x >= obs2X && x < obs2X + `obsW && y >= `groundTop - obs2H) color = `colObs2; // obs 2
            end
            if (x >= 33 && x < 125 && y >= 49 && y < 69 && titleColor != `colDinoTransparentMask) color = titleColor;
        end
    end
endmodule

module GameOverRenderer(input clk, frameClk, resetn, input `ubyte x, y, input `ubyte dinoY, obs1X, obs1H, obs2X, obs2H, 
    output reg [2:0] color);
    wire [2:0] dinoColor;
    DinoPixelRenderer dinoRenderer(.clk(clk), .frameClk(frameClk), .resetn(resetn), .x(x), .y(y), .gameState(`GAME_OVER), .dinoY(dinoY), .color(dinoColor));
    wire [2:0] bgColor;
    BackgroundRenderer bgRenderer(.clk(clk), .moveClk(frameClk), .resetn(resetn), .x(x), .y(y), .gameState(`GAME_OVER), .color(bgColor));
    wire [2:0] titleColor;
    wire [11:0] titleSpriteAddressCalc = ((x - 11) + ((y - 49) * 136) + 1); 
    reg [11:0] spriteAddress;
    always @(*) begin
        if (titleSpriteAddressCalc >= 0 && titleSpriteAddressCalc < 2720) spriteAddress = titleSpriteAddressCalc;
        else spriteAddress = 0;     
    end
    // L:11 T: 49 W: 136 H: 20
    GameOverSpriteROM gameOverSprite(.clock(clk), .address(spriteAddress), .q(titleColor));
    always @(posedge clk) begin
        if (!resetn) color = `colBG;
        else begin
            color = bgColor; // Default color is background.
            if (y < `groundTop) begin
                if (x >= `dinoLeft && x < `dinoRight  && y >= dinoY && y < dinoY + `dinoH && dinoColor != `colDinoTransparentMask) color = dinoColor; // Dino    
                else if (x >= obs1X && x < obs1X + `obsW && y >= `groundTop - obs1H) color = `colObs1; // obs 1
                else if (x >= obs2X && x < obs2X + `obsW && y >= `groundTop - obs2H) color = `colObs2; // obs 2
            end
            if (x >= 11 && x < 147 && y >= 49 && y < 69 && titleColor != `colDinoTransparentMask) color = titleColor;
        end
    end
endmodule
