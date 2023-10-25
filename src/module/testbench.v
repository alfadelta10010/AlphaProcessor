`timescale 1ns / 1ps
`include "alphacore.v"
`include "clk_gate.v"

module alphacore_tb;
	reg clk = 0;
	reg reset = 0; 
	reg [31:0] idata0, idata1, idata2, idata3, idata4, idata5, idata6, idata7, idata8, idata9, idata10, idata11, idata12, idata13, idata14, idata15, idata16, idata17, idata18, idata19, idata20, idata21, idata22, idata23, idata24, idata25, idata26, idata27, idata28, idata29, idata30, idata31; 
	wire [31:0] reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15, reg16, reg17, reg18, reg19, reg20, reg21, reg22, reg23, reg24, reg25, reg26, reg27, reg28, reg29, reg30, reg31;
	
	riscv rv(.clk(clk), .reset(reset), .idata0(idata0), .idata1(idata1), .idata2(idata2), .idata3(idata3), .idata4(idata4), .idata5(idata5), .idata6(idata6), .idata7(idata7), .idata8(idata8), .idata9(idata9), .idata10(idata10), .idata11(idata11), .idata12(idata12), .idata13(idata13), .idata14(idata14), .idata15(idata15), .idata16(idata16), .idata17(idata17), .idata18(idata18), .idata19(idata19), .idata20(idata20), .idata21(idata21), .idata22(idata22), .idata23(idata23), .idata24(idata24), .idata25(idata25), .idata26(idata26), .idata27(idata27), .idata28(idata28), .idata29(idata29), .idata30(idata30), .idata31(idata31), .reg0(reg0), .reg1(reg1), .reg2(reg2), .reg3(reg3), .reg4(reg4), .reg5(reg5), .reg6(reg6), .reg7(reg7), .reg8(reg8), .reg9(reg9), .reg10(reg10), .reg11(reg11), .reg12(reg12), .reg13(reg13), .reg14(reg14), .reg15(reg15), .reg16(reg16), .reg17(reg17), .reg18(reg18), .reg19(reg19), .reg20(reg20), .reg21(reg21), .reg22(reg22), .reg23(reg23), .reg24(reg24), .reg25(reg25), .reg26(reg26), .reg27(reg27), .reg28(reg28), .reg29(reg29), .reg30(reg30), .reg31(reg31));
	
	always
		#5 clk = ~clk;
	initial begin
		reset = 0;
		idata0 = 32'b00010010001101000101001100110111;
		idata1 = 32'b01100111100000110000001100010011;
		idata2 = 32'b00001111111101010000010100010011;
		idata3 = 32'b00000000101000110111111000110011;
		idata4 = 32'b00000001100011100001111000010011;
		idata5 = 32'b00000001110001000000010000110011;
		idata6 = 32'b00000000100001010001010100010011;
		idata7 = 32'b00000000101000110111111000110011;
		idata8 = 32'b00000000100011100001111000010011;
		idata9 = 32'b00000001110001000000010000110011;
		idata10 = 32'b00000000100001010001010100010011;
		idata11 = 32'b00000000101000110111111000110011;
		idata12 = 32'b00000000100011100101111000010011;
		idata13 = 32'b00000001110001000000010000110011;
		idata14 = 32'b00000000100001010001010100010011;
		idata15 = 32'b00000000101000110111111000110011;
		idata16 = 32'b00000001100011100101111000010011;
		idata17 = 32'b00000001110001000000010000110011;
		idata18 = 32'b00000000100001010001010100010011;
		#10 reset = 1;
		#50 reset = 0;
	end
	
	initial 
		begin
			$dumpfile("pre_synth_test.vcd");
			$dumpvars(0, alphacore_tb);
			#100000 $finish;
		end
endmodule