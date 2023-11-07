module BranchComp(
	input [31:0] dataA, 
	input [31:0] dataB,
	input BrUn, 
	output reg BrEq,
	output reg BrLT); 

	always @* begin
	if (BrUn == 1) begin
		if ($unsigned(dataA) < $unsigned(dataB)) begin
			BrEq <= 0;
			BrLT <= 1;
		end
	end
	else begin
		if (dataA == dataB) begin
			BrEq <= 1;
			BrLT <= 0;
		end
		else if (dataA < dataB) begin
			BrEq <= 0;
			BrLT <= 1;
		end
		else begin
			BrEq <= 0;
			BrLT <= 0;
		end
	end
	end
endmodule 