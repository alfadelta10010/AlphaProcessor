`include "alu_add_only.v"
`include "alucontrol.v"
`include "alu.v"
`include "branch_shiftleft2.v"
`include "control.v"
`include "data_memory.v"
`include "instruction_memory.v"
`include "jump_shiftleft2.v"
`include "mux_N_bit.v"
`include "program_counter.v"
`include "register_file.v"
`include "sign_extension.v"

module alphacore (fastclk, reset, switch_select, switch_run, reg_read_data_1);
	input fastclk, reset;		// fastclk (5m[6] Hz) feeds clock divider
	input switch_run;			// decide run(1) or check reg file(0)
	input [4:0] switch_select;	// select $0 to $31 for output
	output [31:0] reg_read_data_1; // moved here for simulation

	// pc signals
	wire [7:0] pc_in, pc_out;
	wire [31:0] pc_origin_al, pc_out_unsign_extended, pc_plus4;
	// I-MEM signals
	wire [31:0] instruction;
	// Register File signals
	wire [4:0] reg_write_addr;
	wire [31:0] reg_write_data, reg_read_data_2; // reg_read_data_1 moved to output for simulation
	// D-MEM signals
	wire [7:0] d_mem_addr;
	wire [31:0] d_mem_read_data;
	// control signals
	wire reg_dest, jump, branch, mem_read, mem_to_reg, mem_write, aluSrc, reg_write;
	wire [1:0] aluop;
	wire [3:0] alu_control_out;
	// branch
	wire [31:0] extended_immidiate;
	wire [31:0] shifted_immidiate;
	wire [31:0] branch_out;
	wire [31:0] branch_result;
	wire branch_decided, zero;
	// jump
	wire [27:0] jump_base28;
	wire [31:0] jump_addr;
	// alu
	wire [31:0] alu_in_b, alu_out;
	// ssd display & clock slow-down
	wire clknormal, clkrf, clk;
		// fastclk: 5m Hz
		// clkssd: 500 Hz for ring counter
		// clknormal: 1 Hz
    wire  [3:0] tho; // Bin_ary-Coded-Decimal 0-15
	wire  [3:0] hun;
	wire  [3:0] ten;
	wire  [3:0] one;
// multi-purpose I-MEM read_addr_1
	wire [4:0] multi_purpose_read_addr;
	wire multi_purpose_reg_write;

	// reg to resolve always block technicals
	reg clkrf_reg, clk_reg, multi_purpose_reg_write_reg;
	reg [4:0] multi_purpose_read_addr_reg;
	reg [3:0] tho_reg, hun_reg, ten_reg, one_reg;

	assign d_mem_addr = alu_out[7:0];
	assign pc_in = pc_origin_al[7:0];
	assign pc_out_unsign_extended = {26'b0000_0000_0000_0000_0000_0000, pc_out}; // from 7 bits to 32 bits
	assign jump_addr = {pc_plus4[31:28], jump_base28}; // jump_addr = (pc+4)[31:28] joined with jump_base28[27:0]
	// output processor clock (1 Hz or freeze) to a LED

	program_counter program_counter1 (.clk(clk), .reset(reset), .pc_in(pc_in), .pc_out(pc_out));
	instruction_memory instruction_memory1 (.read_addr(pc_out), .instruction(instruction), .reset(reset));
	register_file register_file1 (.read_addr_1(multi_purpose_read_addr), .read_addr_2(instruction[20:16]), .write_addr(reg_write_addr), .read_data_1(reg_read_data_1), .read_data_2(reg_read_data_2), .write_data(reg_write_data), .reg_write(multi_purpose_reg_write), .clk(clkrf), .reset(reset));
	data_memory data_memory1 (.addr(d_mem_addr), .write_data(reg_read_data_2), .read_data(d_mem_read_data), .clk(clk), .reset(reset), .mem_read(mem_read), .mem_write(mem_write));
	control control1 (.opcode(instruction[31:26]), .reg_dest(reg_dest), .jump(jump), .branch(branch), .mem_read(mem_read), .mem_to_reg(mem_to_reg), .aluop(aluop), .mem_write(mem_write), .alusrc(alusrc), .reg_write(reg_write));
	alucontrol alucontrol1 (.aluop(aluop), .funct(instruction[5:0]), .out_to_alu(alu_control_out));
	sign_extension sign_extension1 (.sign_in(instruction[15:0]), .sign_out(extended_immidiate));
	branch_shiftleft2 branch_shift1 (.shift_in(extended_immidiate), .shift_out(shifted_immidiate));
	jump_shiftleft2 jump_shift1 (.shift_in(instruction[25:0]), .shift_out(jump_base28));
	mux_N_bit #(5) program_counter10 (.in0(instruction[20:16]), .in1(instruction[15:11]), .mux_out(reg_write_addr), .control(reg_dest));
	mux_N_bit #(32) program_counter11 (.in0(reg_read_data_2), .in1(extended_immidiate), .mux_out(alu_in_b), .control(aluSrc));
	mux_N_bit #(32) program_counter12 (.in0(alu_out), .in1(d_mem_read_data), .mux_out(reg_write_data), .control(mem_to_reg));
	mux_N_bit #(32) program_counter13 (.in0(pc_plus4), .in1(branch_out), .mux_out(branch_result), .control(branch_decided));
	mux_N_bit #(32) program_counter14 (.in0(branch_result), .in1(jump_addr), .mux_out(pc_origin_al), .control(jump));
	alu program_counter15 (.in_a(reg_read_data_1), .in_b(alu_in_b), .alu_out(alu_out), .zero(zero), .control(alu_control_out));
	alu_add_only program_counter16 (.in_a(pc_out_unsign_extended), .in_b(32'b0100), .add_out(pc_plus4)); // pc + 4
	alu_add_only program_counter17 (.in_a(pc_plus4), .in_b(shifted_immidiate), .add_out(branch_out));
	and (branch_decided, zero, branch);

	
	assign clkrf = clkrf_reg;
	assign clk = clk_reg;
	assign multi_purpose_read_addr = multi_purpose_read_addr_reg;
	assign multi_purpose_reg_write = multi_purpose_reg_write_reg;
	
	always @(switch_run) begin
		if (switch_run) begin
			// sys status 1: run single-cycle processor
			clkrf_reg <= clknormal;	// 1 Hz
			clk_reg <= clknormal;		// 1 Hz
			multi_purpose_read_addr_reg <= instruction[25:21]; // reg-file-port1 reads from instruction
			// reg-file protection measure; explained in "else"
			multi_purpose_reg_write_reg <= reg_write;
		end
		else begin
			// sys status 2: pause processor; inspect Reg File content
			clk_reg <= 1'b0;		// freeze at 0
			multi_purpose_read_addr_reg <= switch_select; // reg-file-port1 reads from switch_select
			// Reg-file is not freezed in time, this protects against RF-data-overwrite
			multi_purpose_reg_write_reg <= 1'b0;
		end
	end
endmodule
