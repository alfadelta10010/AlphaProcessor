module alphasoc (OUT, reset, VCO_IN, ENb_CP, ENb_VCO, REF, VREFH);
	wire [9:0] RV_TO_DAC;
	output wire OUT;
	input wire reset;
	input wire VCO_IN;
	input wire ENb_CP;
	input wire ENb_VCO;
	input wire REF;
	input wire VREFH;
	wire CLK;
	
	avsdpll pll (.CLK(CLK), .REF(REF), .ENb_CP(ENb_CP), .VCO_IN(VCO_IN), .ENb_VCO(ENb_VCO));
	alphacore core (.CLK(CLK), .OUT(RV_TO_DAC), .reset(reset));
	avsddac dac (.OUT(OUT), .VREFH(VREFH), .D(RV_TO_DAC));
endmodule