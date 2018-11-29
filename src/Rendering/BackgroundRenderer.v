`include "../DinoGameConstants.v"
`include "./Sprites/Background/BackgroundSpriteROM.v"

module BackgroundRenderer(input clk, moveClk, resetn, input `ubyte x, y, input [3:0] gameState, output [2:0] color);
    reg [14:0] xOffset;
    wire [14:0] spriteAddressCalc = (x + (y * 160) + 1);//(((xOffset + {7'b0,x}) % `xMAX) + ({7'b0,y} * 15'd120)); 
    reg [14:0] spriteAddress;

    always @(*) begin
        if (spriteAddressCalc >= 0 && spriteAddressCalc < 120 * 160) spriteAddress = spriteAddressCalc;
        else spriteAddress = 0;     
    end

    //reg [14:0] spriteAddress;
    always @(posedge clk) begin
        if (!resetn) xOffset <= 0;
        else if (moveClk) begin
            if (xOffset >= `xMAX) xOffset <= 0;
            else xOffset <= xOffset + 1;
        end
        //$display("spriteAddress (%d, %d) = %d", x, y, spriteAddress);
    end

    BackgroundSpriteROM bgSprite(.clock(clk), .address(spriteAddress), .q(color));
endmodule