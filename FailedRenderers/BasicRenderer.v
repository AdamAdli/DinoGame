`include "./DinoGameConstants.v"
`include "./DinoPixelRenderer.v"

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