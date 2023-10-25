`include "alphacore.synth.v"
`include "primitives.v"
`include "sky130_fd_sc_hd.v"
`timescale 1ns / 1ps
module alphacore_tb;

	reg fastclk;
	reg reset;
	reg [4:0] switch_select;
	reg switch_run;
	reg clkread;
	
	integer count;


	// Outputs
	wire [31:0]reg_read_data_1;
		
	// Instantiate the Unit Under Test (UUT)
	alphacore uut (
		.fastclk(fastclk), 
		.reset(reset),
		.switch_select(switch_select),
		.switch_run(switch_run),
		.reg_read_data_1(reg_read_data_1));

	initial begin
		// Initialize Inputs
		count = 0;
		fastclk = 0;
		reset = 1;
		switch_run = 0;
		switch_select = 5'd0;
		clkread = 0;
		#4 reset=0;
		#3000;
		#50 $stop;
	end

	always begin #1 fastclk=~fastclk; end
	always begin #200 clkread = ~clkread; end 
	
	always @(posedge clkread)
	begin
		#10 switch_select = 5'd16;
	  	#10 switch_select = 5'd17;
	  	#10 switch_select = 5'd18;
	  	#10 switch_select = 5'd19;
	  	#10 switch_select = 5'd20;
	  	#10 switch_select = 5'd21;
	  	#10 switch_select = 5'd22;
	  	#10 switch_select = 5'd23;
	  	#10 switch_select = 5'd8;
	  	#10 switch_select = 5'd9;
	  	#10 switch_select = 5'd10;
	  	#10 switch_select = 5'd11;
	  	#10 switch_select = 5'd12;
	  	#10 switch_select = 5'd13;
	  	#10 switch_select = 5'd14;
	  	#10 switch_select = 5'd15;
	  	#10 switch_select = 5'd24;
	  	#10 switch_select = 5'd25; 
		#2 switch_run = 1;
		#32 switch_run = 0;
		count = count + 1;				
	end
	initial begin
		$dumpfile("post_synth_sim.vcd");
		$dumpvars(0, alphacore_tb);
		#2200 $finish;
	end
endmodule

