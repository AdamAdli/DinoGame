`include "./DinoGameConstants.v"
`include "./GameRunningRenderer.v"

module GamePixelRenderer(input clk, frameClk, resetn, enable, input [3:0] gameState, input `ubyte dinoY, obs1X, obs1H, obs2X, obs2H, 
    output reg `ubyte x, y, output reg [2:0] color, output plotPixel);
    wire [2:0] dinoColor;
    wire [2:0] mycolor;
    DinoPixelRenderer dinoRenderer(.clk(clk), .frameClk(frameClk), .resetn(resetn), .x(x), .y(y), .gameState(gameState), .dinoY(dinoY), .color(dinoColor));
    GameRunningRenderer gameRunningRenderer(.clk(clk), .frameClk(frameClk), .resetn(resetn), .ldClk(clk), .gameState(gameState),
        .dinoY(dinoY), .obs1X(obs1X), .obs1H(obs1H), .obs2X(obs2X), .obs2H(obs2H),
        .x(x), .y(y), .color(mycolor));
    reg loadColor;
    reg frameHandled;
    always @(posedge clk) begin
        if (!resetn) begin
            x <= 0; 
            y <= 0;
            color <= `colBG;
            loadColor <= 1;
            frameHandled <= 0;
        //end else if (enable && ((frameClk) || (x || y))) begin
        end else if (enable) begin
            if (frameClk || !frameHandled) begin
                frameHandled <= 0;
                if (loadColor) begin
                    if (x < `xMAX) x <= x + 1;
                    else begin 
                        x <= 0;
                        if (y < `yMAX) y <= y + 1;
                        else begin 
                            y 
                        end 
                    end
                    loadColor <= 0;
                end else begin
                    loadColor <= 1;
                end
                if (gameState == `GAME_RUNNING) color = mycolor;
                else color = `colBG;
            end 
            if (frameClk ||  || loadColor) begin
                if (loadColor) begin
                    if (x < `xMAX) x <= x + 1;
                    else begin 
                        x <= 0;
                        if (y < `yMAX) y <= y + 1;
                        else y <= 0;
                    end
                    loadColor <= 0;
                end else begin
                    loadColor <= 1;
                end
                if (gameState == `GAME_RUNNING) color = mycolor;
                else color = `colBG;
            end
        end
    end
    assign plotPixel = loadColor;
endmodule