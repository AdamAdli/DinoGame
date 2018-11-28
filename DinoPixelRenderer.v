`include "./DinoGameConstants.v"

module DinoPixelRenderer(input clk, frameClk, resetn, input `ubyte x, y, input [3:0] gameState, input `ubyte dinoY, output [2:0] color);
    wire [8:0] dinoSpriteOriginAddress;
    wire [8:0] dinoSpriteAddress = dinoSpriteOriginAddress + ((x - `dinoLeft) + ((y - dinoY) * 10) + 9'd1); 

    always @(posedge clk ) begin
        if (x >= `dinoLeft && x < `dinoRight  && y >= dinoY && y < dinoY + `dinoH)
            $display("%t: x %d y %d dinoSpriteAddress %d color: %b", $time, x, y, dinoSpriteAddress, color);
    end

    DinoController dinoController(.clk(clk), .frameClk(frameClk), .resetn(resetn), .gameState(gameState), 
         .dinoSpriteAddress(dinoSpriteOriginAddress));
    dinospriteROM dinoSprite(.clock(clk), .address(dinoSpriteAddress), .q(color));
endmodule

module DinoController(input clk, frameClk, resetn, input [3:0] gameState, output reg [8:0] dinoSpriteAddress);    
    reg [1:0] current_state, next_state;
    localparam DINO_STANDING = 0, DINO_RUNNING_1 = 1, DINO_RUNNING_2 = 2;

    // State Table
    always @(*) begin
        case (current_state)
            DINO_STANDING: next_state = (gameState == `GAME_RUNNING) ? DINO_RUNNING_1 : DINO_STANDING;
            DINO_RUNNING_1: next_state = DINO_RUNNING_2;
            DINO_RUNNING_2: next_state = DINO_RUNNING_1;
            default: next_state = DINO_STANDING;
        endcase
    end
    
    // Output Logic
    always @(*) begin
        dinoSpriteAddress = 9'd0;
        case (current_state)
            DINO_RUNNING_1: dinoSpriteAddress = 9'd120;
            DINO_RUNNING_2: dinoSpriteAddress = 9'd240;
        endcase
    end

    // Current State Register
    reg frameHandled;
    reg [1:0] frameCounter; 
    always @(posedge clk) begin
        if (!resetn) begin
            current_state <= DINO_STANDING;
            frameHandled <= 0;
                frameCounter <= 2'd3;
        end 
        else if (frameClk && !frameHandled) begin
            frameHandled <= 1;
                if (frameCounter == 0) begin 
                    current_state <= next_state;
                    frameCounter <= 2'd3;
                end else frameCounter <= frameCounter - 2'd1;
        end else if (!frameClk) frameHandled <= 0;
    end
endmodule