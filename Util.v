// Counter Modules.
module delay_counter60(input clk, resetn, enable, output reg [19:0] cycle_count);
    // 50 Mhz / 60 Hz = 833333
    always @(posedge clk) begin
        if (!resetn) cycle_count <= 20'd833332;
        else if (enable) begin
            if (cycle_count == 0) cycle_count <= 20'd833332;
            else cycle_count <= cycle_count - 1'b1; 
        end
    end
endmodule

module DelayCounter30FPS(input clk, resetn, enable, output reg [20:0] cycle_count);
    // 50 Mhz / 30 Hz = 1666667
    always @(posedge clk) begin
        if (!resetn) cycle_count <= 21'd1666667;
        else if (enable) begin
            if (cycle_count == 0) cycle_count <= 21'd833332;
            else cycle_count <= cycle_count - 1'b1; 
        end
    end
endmodule

module DelayCounter30FPSTest(input clk, resetn, enable, output reg [20:0] cycle_count);
    // 50 Mhz / 30 Hz = 1666667
    always @(posedge clk) begin
        if (!resetn) cycle_count <= 21'd99999;
        else if (enable) begin
            if (cycle_count == 0) cycle_count <= 21'd99999;
            else cycle_count <= cycle_count - 1'b1; 
        end
    end
endmodule


/*module DelayCounter(clk, resetn, enable, cycle_count);
    //1666667
    parameter ROOT_CLOCK = 50000000;
    parameter FRAME_RATE = 30;
    parameter RESET_AMOUNT = ROOT_CLOCK / FRAME_RATE;
    parameter RESET_BITS = $clog(RESET_AMOUNT);
    wire[RESET_BITS - 1:0] cycle_reset = RESET_AMOUNT;
    //wire[$clog2(ROOT_CLOCK / FRAME_RATE)] cycle_reset =  ROOT_CLOCK / FRAME_RATE;
    //parameter BITS = log
    parameter BITS = 28;
    output reg [RESET_BITS - 1:0] cycle_count;
    input clk, resetn, enable;

    always @(posedge clk) begin
        if (!resetn) cycle_count <= 0;
        else if (enable) begin
            if (cycle_count == 0) cycle_count <= RESET_AMOUNT;
            else cycle_count <= cycle_count - 1'b1; 
        end
    end
endmodule*/

module delay_counterTest(input clk, resetn, enable, output reg [19:0] cycle_count);
    // 50 Mhz / 60 Hz = 833333
    always @(posedge clk) begin
        if (!resetn) cycle_count <= 0;//20'd83333;
        else if (enable) begin
            if (cycle_count == 0) cycle_count <= 20'd83333;
            else cycle_count <= cycle_count - 1'b1; 
        end
    end
endmodule


module FrameSkipper(input clk, frameClk, resetn, input [3:0] skipCount, output reg [3:0] frame_count);
    always @(posedge clk) begin
        if (!resetn) frame_count <= 0;
        else if (frameClk) begin
            if (frame_count == 0) frame_count <= skipCount;
            else frame_count <= frame_count - 1'b1;
        end
    end
endmodule

module frame_counter_skip1(input clk, resetn, enable, output reg [3:0] frame_count);
    always @(posedge clk) begin
        if (!resetn) frame_count <= 4'd1;
        else if (enable) begin
            if (frame_count == 0) frame_count <= 4'd1;
            else frame_count <= frame_count - 1'b1;
        end
    end
endmodule

module frame_counter_skipdyn(input clk, resetn, enable, input [3:0] skip, output reg [3:0] frame_count);
    always @(posedge clk) begin
        if (!resetn) frame_count <= skip;
        else if (enable) begin
            if (frame_count == 0) frame_count <= skip;
            else frame_count <= frame_count - 1'b1;
        end
    end
endmodule

// View Modules
/** hex_decoder used from lab 6 */
module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule
