module DMEM(Addr, DataW, DataR, MemRW, clk);
	output [31:0] DataR;
	input clk;
	input [31:0] Addr,DataW;
	input MemRW;
	
	reg [7:0] datafile [0:1023];
	assign DataR[7:0] = datafile[Addr];
	assign DataR[15:8] = datafile[Addr+1];
	assign DataR[23:16] = datafile[Addr+2];
	assign DataR[31:24] = datafile[Addr+3];

	always @(negedge clk) 
		begin
			if(MemRW == 1) 
				begin
					datafile[Addr] <= DataW[7:0];
					datafile[Addr+1] <= DataW[15:8];
					datafile[Addr+2] <= DataW[23:16];
					datafile[Addr+3] <= DataW[31:24];
				end
		end
endmodule