module regfile
	(input clk,
	input reset,
	input write,
	input [4:0] wrAddrD,
	input [4:0] rdAddrA,
	input [4:0] rdAddrB,
	input [31:0] wrDataD,
	output [31:0] rdDataA,
	output [31:0] rdDataB);	
	reg [31:0] regfile [0:31];

	integer j;
	initial begin
		for (j = 0; j < 32; j = j + 1) begin
			regfile[j] <= 0;
		end
	end

	assign rdDataA = regfile[rdAddrA];
	assign rdDataB = regfile[rdAddrB];

	integer i;
	always @(negedge clk) begin
	if (reset) 
		begin
			for (i = 0; i < 32; i = i + 1) 
				begin
					regfile[i] <= 0;
					end
		end 
	else 
		begin
			if (write) 
				begin
					if (wrAddrD != 0)
						regfile[wrAddrD] <= wrDataD;
				end
		end // else: !if(reset)
	// x0 always is zero;
	regfile[0] <= 0;
	end
endmodule 