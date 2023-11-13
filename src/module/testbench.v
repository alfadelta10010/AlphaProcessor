`timescale 1ns/1ps
`include "src/module/alphacore.v"
module testbench;
	reg clk;
	reg [31:0] memInput [0:255];
	
	alphacore uut(clk, memInput);
	
	initial 
		begin
			clk = 0;
			memInput = '{32'h000006b3, 32'h00600713, 32'h00e6a023, 32'h00700713, 32'h00e6a223, 32'h00200713, 32'h00e6a423, 32'h00300713, 32'h00e6a623, 32'h00100713, 32'h00e6a823, 32'h00000713, 32'h00e6aa23, 32'h00400713, 32'h00e6ac23, 32'h00600713, 32'h00e6ae23, 32'h00900713, 32'h02e6a023, 32'h00800713, 32'h02e6a223, 32'h00900e93, 32'h020e8e63, 32'hfffe8e93, 32'h001e8e13, 32'h00068893, 32'hfe0e08e3, 32'hfffe0e13, 32'h0008a703, 32'h00488893, 32'h0008a783, 32'h00f72833, 32'hfe0804e3, 32'hfff80813, 32'h00e8a023, 32'hfef8ae23, 32'hfd9ff06f, 32'h00000033};
			$dumpfile("pre_synth_sim.vcd");
			$dumpvars(0, testbench);
			#10000 $finish;
		end
	
	always 
		begin
			#5 clk =~ clk;
		end
	
endmodule 