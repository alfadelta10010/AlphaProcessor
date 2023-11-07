module IMEM(inst,PC, DataIn);
	parameter INST_WIDTH_LENGTH = 32;
	parameter PC_WIDTH_LENGTH = 32;
	parameter MEM_WIDTH_LENGTH = 32;
	parameter MEM_DEPTH = 1<<8;
	
	output reg [INST_WIDTH_LENGTH-1:0]inst;
	input [PC_WIDTH_LENGTH-1:0] PC;
	
	input [MEM_WIDTH_LENGTH-1:0] DataIn [0:MEM_DEPTH-1]
	
	reg	[MEM_WIDTH_LENGTH-1:0] IMEM [0:MEM_DEPTH-1];
	
	wire [7:0] pWord;
	wire [1:0] pByte;

	assign pWord = PC[9:2];
	assign pByte = PC[1:0];
	assign IMEM = DataIn;
	always@(PC)
		begin
			if (pByte == 2'b00)
				inst <= IMEM[pWord];
			else
				inst <= 'hz;
		end

endmodule