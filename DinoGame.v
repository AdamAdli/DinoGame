/* Dinosaur Verilog Game */
module DinoGame(KEY, LEDR, CLOCK_50);
	
	/* FPGA I/O */
	input CLOCK_50;
	input [2:0] KEY; // KEY[0] = JUMP, KEY[1] = PAUSE, KEY[2] = RESET.
	output [1:0] LEDR;
	
	/* Wires */
	wire clk, jump, pause, reset;
	
	/* Assignment Statements */
	assign clk = CLOCK_50;
	assign jump = KEY[0];
	assign pause = KEY[1];
	assign reset = KEY[2];
	
endmodule


/* Datapath: Sends Signals */
module datapath(clk, reset);

endmodule


/* Controller:  */
module control(clk, reset);

endmodule
