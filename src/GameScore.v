`include "./DinoGameConstants.v"

/* Score Counter Logic (1-9 Values Only) */
module GameScoreCounter(input clk, resetn, input[3:0] gameState, input incrementEnable, output reg [3:0] s_ones, s_tens, s_hundreds, s_thousands, s_tenthousands, s_hunthousands);
     reg frameHandled = 0;
    /* Asynchronous Counting */
     always @(posedge clk) begin
          /* Begins on Reset or Game Menu */
        if (!resetn || gameState == `GAME_MENU) begin
            s_ones <= 0; 
            s_tens <= 0; 
            s_hundreds <= 0; 
            s_thousands <= 0; 
            s_tenthousands <= 0;
            s_hunthousands <= 0;
            frameHandled <= 0;
        end 
          /* Continues only when Game is Running */
          else if (incrementEnable && !frameHandled && gameState == `GAME_RUNNING) begin
            frameHandled <= 1;
            s_ones = s_ones + 4'd1;
            if (s_ones == 4'd10) begin
                s_ones <= 0;
                s_tens = s_tens + 4'd1;
                if (s_tens == 4'd10) begin
                    s_tens <= 0;
                    s_hundreds = s_hundreds + 4'd1;
                    if (s_hundreds == 4'd10) begin
                        s_hundreds <= 0;
                        s_thousands = s_thousands + 4'd1;
                        if (s_thousands == 4'd10) begin
                            s_thousands <= 0;
                            s_tenthousands = s_tenthousands + 4'd1;
                            if (s_tenthousands == 4'd10) begin
                                s_tenthousands <= 0;
                                s_hunthousands = s_hunthousands + 4'd1;
                            end
                        end
                    end
                end
            end
        end else if (!incrementEnable) begin
            frameHandled <= 0;
        end
    end
endmodule  

/* Displays Score On Hexes (1-9 Values Only) */
module GameScoreView(input [3:0] s_ones, s_tens, s_hundreds, s_thousands, s_tenthousands, s_hunthousands, output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
    hex_decoder h0(.hex_digit(s_ones), .segments(HEX0));
    hex_decoder h1(.hex_digit(s_tens), .segments(HEX1));
    hex_decoder h2(.hex_digit(s_hundreds), .segments(HEX2));
    hex_decoder h3(.hex_digit(s_thousands), .segments(HEX3));
    hex_decoder h4(.hex_digit(s_tenthousands), .segments(HEX4));
    hex_decoder h5(.hex_digit(s_hunthousands), .segments(HEX5));
endmodule