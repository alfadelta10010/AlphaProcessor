\TLV_version 1d: tl-x.org
\SV
   // This code can be found in: https://github.com/stevehoover/RISC-V_MYTH_Workshop
   // Included URL: "https://raw.githubusercontent.com/BalaDhinesh/RISC-V_MYTH_Workshop/master/tlv_lib/risc-v_shell_lib.tlv"// Included URL: "https://raw.githubusercontent.com/stevehoover/warp-v_includes/2d6d36baa4d2bc62321f982f78c8fe1456641a43/risc-v_defs.tlv"
\SV
   module alpha_processor(input wire clk, input wire reset, input wire [31:0] cyc_cnt, output wire passed, output wire failed);    /* verilator lint_save */ /* verilator lint_off UNOPTFLAT */  bit [256:0] RW_rand_raw; bit [256+63:0] RW_rand_vect; pseudo_rand #(.WIDTH(257)) pseudo_rand (clk, reset, RW_rand_raw[256:0]); assign RW_rand_vect[256+63:0] = {RW_rand_raw[62:0], RW_rand_raw};  /* verilator lint_restore */  /* verilator lint_off WIDTH */ /* verilator lint_off UNOPTFLAT */   // (Expanded in Nav-TLV pane.)
\TLV
   // /====================\
   // | Sum 1 to 9 Program |
   // \====================/
   //
   // Program for MYTH Workshop to test RV32I
   // Add 1,2,3,...,9 (in that order).
   //
   // Regs:
   //  r10 (a0): In: 0, Out: final sum
   //  r12 (a2): 10
   //  r13 (a3): 1..10
   //  r14 (a4): Sum
   // 
   // External to function:
   // Inst #0: ADD,r10,r0,r0             // Initialize r10 (a0) to 0.
   // Function:
   // Inst #1: ADD,r14,r10,r0            // Initialize sum register a4 with 0x0
   // Inst #2: ADDI,r12,r10,1010         // Store count of 10 in register a2.
   // Inst #3: ADD,r13,r10,r0            // Initialize intermediate sum register a3 with 0
   // Loop:
   // Inst #4: ADD,r14,r13,r14           // Incremental addition
   // Inst #5: ADDI,r13,r13,1            // Increment intermediate register by 1
   // Inst #6: BLT,r13,r12,1111111111000 // If a3 is less than a2, branch to label named <loop>
   // Inst #7: ADD,r10,r14,r0            // Store final result to register a0 so that it can be read by main program
   // Inst #8: SW,r0,r10,10000           // Store the final result value to byte address 16
   // Inst #9: LW,r17,r0,10000           // Load the final result value from adress 16 to x17
   
   // Optional:
   // Inst #10: JAL,r7,00000000000000000000 // Done. Jump to itself (infinite loop). (Up to 20-bit signed immediate plus implicit 0 bit (unlike JALR) provides byte address; last immediate bit should also be 0)
   

   |cpu
      @0
         $reset = *reset;
         $pc[31:0] = >>1$reset ? 32'b0 :
                     >>3$valid_taken_branch ? >>3$br_target_pc :
                     >>3$valid_load ? >>3$inc_pc :
                     >>3$valid_jump && >>3$is_jal ? >>3$br_target_pc :
                     >>3$valid_jump && >>3$is_jalr ? >>3$jalr_target_pc :
                     >>1$inc_pc ;
      @1   
         $inc_pc[31:0] = $pc + 32'd4;
         $imem_rd_addr[4-1:0] = $pc[4+1:2];
         $imem_rd_en = !$reset;
         $instr[31:0] = $imem_rd_data[31:0];
         $is_u_instr = $instr[6:2] ==? 5'b0x101;
         
         $is_s_instr = $instr[6:2] ==? 5'b0100x;
         
         $is_r_instr = $instr[6:2] ==? 5'b01011 ||
                       $instr[6:2] ==? 5'b011x0 ||
                       $instr[6:2] ==? 5'b10100;
         
         $is_j_instr = $instr[6:2] ==? 5'b11011;
         
         $is_i_instr = $instr[6:2] ==? 5'b0000x ||
                       $instr[6:2] ==? 5'b001x0 ||
                       $instr[6:2] ==? 5'b11001;
         
         $is_b_instr = $instr[6:2] ==? 5'b11000;
         $imm[31:0] = $is_i_instr ? {{21{$instr[31]}}, $instr[30:20]} :
                      $is_s_instr ? {{21{$instr[31]}}, $instr[30:25], $instr[11:7]} :
                      $is_b_instr ? {{20{$instr[31]}}, $instr[7], $instr[30:25], $instr[11:8], 1'b0} :
                      $is_u_instr ? {$instr[31:12], 12'b0} :
                      $is_j_instr ? {{12{$instr[31]}}, $instr[19:12], $instr[20], $instr[30:21], 1'b0} :
                                    32'b0;
         `BOGUS_USE($imm)
         
         $opcode[6:0] = $instr[6:0];
         $rs2_valid = $is_r_instr || $is_s_instr || $is_b_instr;
         ?$rs2_valid
            $rs2[4:0] = $instr[24:20];
            
         $rs1_valid = $is_r_instr || $is_i_instr || $is_s_instr || $is_b_instr;
         ?$rs1_valid
            $rs1[4:0] = $instr[19:15];
         
         $funct3_valid = $is_r_instr || $is_i_instr || $is_s_instr || $is_b_instr;
         ?$funct3_valid
            $funct3[2:0] = $instr[14:12];
            
         $funct7_valid = $is_r_instr ;
         ?$funct7_valid
            $funct7[6:0] = $instr[31:25];
            
         $rd_valid = $is_r_instr || $is_i_instr || $is_u_instr || $is_j_instr;
         ?$rd_valid
            $rd[4:0] = $instr[11:7];
            
         `BOGUS_USE($rd)
         
      @2
         $dec_bits[10:0] = {$funct7[5], $funct3, $opcode};
         $is_beq = $dec_bits ==? 11'bx_000_1100011;
         $is_bne = $dec_bits ==? 11'bx_001_1100011;
         $is_blt = $dec_bits ==? 11'bx_100_1100011;
         $is_bge = $dec_bits ==? 11'bx_101_1100011;
         $is_bltu = $dec_bits ==? 11'bx_110_1100011;
         $is_bgeu = $dec_bits ==? 11'bx_111_1100011;
         $is_addi = $dec_bits ==? 11'bx_000_0010011;
         $is_add = $dec_bits ==? 11'b0_000_0110011;
         $is_load = $opcode == 7'b0000011;
         $is_xori = $dec_bits ==? 11'bx_100_0010011;
         $is_xor = $dec_bits ==? 11'b0_100_0110011;
         $is_sw = $dec_bits ==? 11'bx_010_0100011;
         $is_sub = $dec_bits ==? 11'b1_000_0110011;
         $is_srli = $dec_bits ==? 11'b0_101_0010011;
         $is_srl = $dec_bits ==? 11'b0_101_0110011;
         $is_srai = $dec_bits ==? 11'b1_101_0010011;
         $is_sra = $dec_bits ==? 11'b1_101_0110011;
         $is_sltu = $dec_bits ==? 11'b0_011_0110011;
         $is_sltiu = $dec_bits ==? 11'bx_011_0010011;
         $is_slti = $dec_bits ==? 11'bx_010_0010011;
         $is_slt = $dec_bits ==? 11'b0_010_0110011;
         $is_slli = $dec_bits ==? 11'b0_001_0010011;
         $is_sll = $dec_bits ==? 11'b0_001_0110011;
         $is_sh = $dec_bits ==? 11'bx_001_0100011;
         $is_sb = $dec_bits ==? 11'bx_000_0100011;
         $is_ori = $dec_bits ==? 11'bx_110_0010011;
         $is_or = $dec_bits ==? 11'b0_110_0110011;
         $is_lui = $dec_bits ==? 11'bx_xxx_0110111;
         $is_jalr = $dec_bits ==? 11'bx_000_1100111;
         $is_jal = $dec_bits ==? 11'bx_xxx_1101111;
         $is_auipc = $dec_bits ==? 11'bx_xxx_0010111;
         $is_andi = $dec_bits ==? 11'bx_111_0010011;
         $is_and = $dec_bits ==? 11'b0_111_0110011;
         $jalr_target_pc[31:0] = $src1_value +$imm ;
         $br_target_pc[31:0] = $pc +$imm;
         $rf_rd_en1 = $rs1_valid;
         $rf_rd_index1[4:0] = $rs1;
         $rf_rd_en2 = $rs2_valid;
         $rf_rd_index2[4:0] = $rs2;
         $src1_value[31:0] = (>>1$rf_wr_index == $rf_rd_index1) && >>1$rf_wr_en ? >>1$result :  
                             $rf_rd_data1;
         $src2_value[31:0] = (>>1$rf_wr_index == $rf_rd_index2) && >>1$rf_wr_en ? >>1$result :
                             $rf_rd_data2;

      @3
         $is_jump = $is_jal || $is_jalr ;
         `BOGUS_USE ($is_beq $is_bne $is_blt $is_bge $is_bltu $is_bgeu $is_addi $is_add)
         $rf_wr_en = ($rd_valid && $rd != 5'b0 && $valid) || >>2$valid_load;
         $rf_wr_index[4:0] = >>2$valid_load ? >>2$rd : $rd;
         $rf_wr_data[31:0] = >>2$valid_load ? >>2$ld_data : $result;  
         $sltu_rslt[31:0] = $src1_value < $src2_value ;
         $sltiu_rslt[31:0]  = $src1_value < $imm ;
         $valid = !(>>1$valid_taken_branch || >>2$valid_taken_branch || 
                    >>1$valid_load || >>2$valid_load ||  
                    >>1$valid_jump || >>2$valid_jump) ;
         
         $valid_load = $valid && $is_load ;
         $valid_jump = $is_jump && $valid ;
         $result[31:0] = $is_andi ? $src1_value & $imm :
                         $is_ori ? $src1_value | $imm :
                         $is_xori ? $src1_value ^ $imm :
                         ($is_addi || $is_load || $is_s_instr) ? $src1_value + $imm :
                         $is_slli ? $src1_value << $imm[5:0] :
                         $is_srli ? $src1_value >> $imm[5:0] :
                         $is_and ? $src1_value & $src2_value :
                         $is_or ? $src1_value | $src2_value :
                         $is_xor ? $src1_value ^ $src2_value :
                         $is_add ? $src1_value + $src2_value :
                         $is_sub ? $src1_value - $src2_value :
                         $is_sll ? $src1_value << $src2_value[4:0] :
                         $is_srl ? $src1_value >> $src2_value[4:0] :
                         $is_sltu ? $src1_value | $src2_value :
                         $is_sltiu ? $src1_value < $imm :
                         $is_lui ? {$imm[31:12], 12'b0} :
                         $is_auipc ? $pc + $imm :
                         $is_jal ? $pc + 4 :
                         $is_jalr ? $pc + 4 :
                         $is_srai ? {{32{$src1_value[31]}}, $src1_value} >> $imm[4:0] :
                         $is_slt ? ($src1_value[31] == $src2_value[31]) ? $sltu_rslt : {31'b0, $src1_value[31]} :
                         $is_slti ? ($src1_value[31] == $imm[31]) ? $sltiu_rslt : {31'b0, $src1_value[31]} :
                         $is_sra ? {{32{$src1_value[31]}}, $src1_value} > $src2_value[4:0] :
                         32'bx ;
         $taken_branch = $is_beq ? ($src1_value == $src2_value):
                         $is_bne ? ($src1_value != $src2_value):
                         $is_blt ? (($src1_value < $src2_value) ^ ($src1_value[31] != $src2_value[31])):
                         $is_bge ? (($src1_value >= $src2_value) ^ ($src1_value[31] != $src2_value[31])):
                         $is_bltu ? ($src1_value < $src2_value):
                         $is_bgeu ? ($src1_value >= $src2_value):
                                    1'b0;
         $valid_taken_branch = $valid && $taken_branch;

      @4
         $dmem_wr_en = $is_s_instr && $valid ;
         $dmem_addr[3:0] = $result[5:2] ;
         $dmem_wr_data[31:0] = $src2_value ;
         $dmem_rd_en = $is_load ;
      @5
         //LOAD DATA
         $ld_data[31:0] = $dmem_rd_data ;   
      @2
         //TESTBENCH
         *passed = |cpu/xreg[17]>>5$value == (1+2+3+4+5+6+7+8+9) ;
      // Note: Because of the magic we are using for visualisation, if visualisation is enabled below,
      //       be sure to avoid having unassigned signals (which you might be using for random inputs)
      //       other than those specifically expected in the labs. You'll get strange errors for these.
   
   // Assert these to end simulation (before Makerchip cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
   
   // Macro instantiations for:
   //  o instruction memory
   //  o register file
   //  o data memory
   //  o CPU visualization
   |cpu
      \source /raw.githubusercontent.com/BalaDhinesh/RISCVMYTHWorkshop/master/tlvlib/riscvshelllib.tlv 19   // Instantiated from top.tlv, 217 as: m4+imem(@1)
         // Instruction Memory containing program defined by m4_asm(...) instantiations.
         @1
            
            \SV_plus
               // The program in an instruction memory.
               logic [31:0] instrs [0:11-1];
               assign instrs = '{
                  {7'b0000000, 5'd0, 5'd0, 3'b000, 5'd10, 7'b0110011}, {7'b0000000, 5'd0, 5'd10, 3'b000, 5'd14, 7'b0110011}, {12'b1010, 5'd10, 3'b000, 5'd12, 7'b0010011}, {7'b0000000, 5'd0, 5'd10, 3'b000, 5'd13, 7'b0110011}, {7'b0000000, 5'd14, 5'd13, 3'b000, 5'd14, 7'b0110011}, {12'b1, 5'd13, 3'b000, 5'd13, 7'b0010011}, {1'b1, 6'b111111, 5'd12, 5'd13, 3'b100, 4'b1100, 1'b1, 7'b1100011}, {7'b0000000, 5'd0, 5'd14, 3'b000, 5'd10, 7'b0110011}, {7'b0000000, 5'd10, 5'd0, 3'b010, 5'b10000, 7'b0100011}, {12'b10000, 5'd0, 3'b010, 5'd17, 7'b0000011}, {1'b0, 10'b0000000000, 1'b0, 8'b00000000, 5'd7, 7'b1101111}
               };
            /imem[10:0]
               $instr[31:0] = *instrs\[#imem\];
            ?$imem_rd_en
               $imem_rd_data[31:0] = /imem[$imem_rd_addr]$instr;
            
            
            
               
                              
                              
                              
                              
                              
                              
                              
                              
                              
                              
                              
                              
                              
                              
                              
                              
                              
                              
                              
                              
                              
                              
                              
                              
                              
                              
                              
                              
                              
                              
                              
                              
              
          
      \end_source    // Args: (read stage)
      \source /raw.githubusercontent.com/BalaDhinesh/RISCVMYTHWorkshop/master/tlvlib/riscvshelllib.tlv 74   // Instantiated from top.tlv, 218 as: m4+rf(@2, @3)
         // Reg File
         @3
            /xreg[31:0]
               $wr = |cpu$rf_wr_en && (|cpu$rf_wr_index != 5'b0) && (|cpu$rf_wr_index == #xreg);
               $value[31:0] = |cpu$reset ?   #xreg           :
                              $wr        ?   |cpu$rf_wr_data :
                                             $RETAIN;
         @2
            ?$rf_rd_en1
               $rf_rd_data1[31:0] = /xreg[$rf_rd_index1]>>2$value;
            ?$rf_rd_en2
               $rf_rd_data2[31:0] = /xreg[$rf_rd_index2]>>2$value;
            `BOGUS_USE($rf_rd_data1 $rf_rd_data2) 
      \end_source  // Args: (read stage, write stage) - if equal, no register bypass is required
      \source /raw.githubusercontent.com/BalaDhinesh/RISCVMYTHWorkshop/master/tlvlib/riscvshelllib.tlv 91   // Instantiated from top.tlv, 219 as: m4+dmem(@4)
         // Data Memory
         @4
            /dmem[15:0]
               $wr = |cpu$dmem_wr_en && (|cpu$dmem_addr == #dmem);
               $value[31:0] = |cpu$reset ?   #dmem :
                              $wr        ?   |cpu$dmem_wr_data :
                                             $RETAIN;
                                        
            ?$dmem_rd_en
               $dmem_rd_data[31:0] = /dmem[$dmem_addr]>>1$value;
            `BOGUS_USE($dmem_rd_data)
      \end_source    // Args: (read/write stage)
      //m4+myth_fpga(@0)  // Uncomment to run on fpga
   \source /raw.githubusercontent.com/BalaDhinesh/RISCVMYTHWorkshop/master/tlvlib/riscvshelllib.tlv 144   // Instantiated from top.tlv, 221 as: m4+cpu_viz(@4)
      
      
      |cpu
         // for pulling default viz signals into CPU
         // and then back into viz
         @0
            $ANY = /top|cpuviz/defaults<>0$ANY;
            `BOGUS_USE($dummy)
            /xreg[31:0]
               $ANY = /top|cpuviz/defaults/xreg<>0$ANY;
            /dmem[15:0]
               $ANY = /top|cpuviz/defaults/dmem<>0$ANY;
      // String representations of the instructions for debug.
      \SV_plus
         logic [40*8-1:0] instr_strs [0:11];
         assign instr_strs = '{ "(R) ADD r10,r0,r0                       ",  "(R) ADD r14,r10,r0                      ",  "(I) ADDI r12,r10,1010                   ",  "(R) ADD r13,r10,r0                      ",  "(R) ADD r14,r13,r14                     ",  "(I) ADDI r13,r13,1                      ",  "(B) BLT r13,r12,1111111111000           ",  "(R) ADD r10,r14,r0                      ",  "(S) SW r0,r10,10000                     ",  "(I) LW r17,r0,10000                     ",  "(J) JAL r7,00000000000000000000         ",  "END                                     "};
      |cpuviz
         @1
            /imem[10:0]  // TODO: Cleanly report non-integer ranges.
               $instr[31:0] = /top|cpu/imem<>0$instr;
               $instr_str[40*8-1:0] = *instr_strs[imem];
               \viz_js
                  box: {width: 500, height: 18, strokeWidth: 0},
                  onTraceData() {
                     let instr_str = '$instr_str'.asString() + ": " + '$instr'.asBinaryStr(NaN);
                     return {objects: {instr_str: new fabric.Text(instr_str, {
                        top: 0,
                        left: 0,
                        fontSize: 14,
                        fontFamily: "monospace"
                     })}};
                  },
                  where: {left: -580, top: 0}
                
         @0
            /defaults
               {$is_lui, $is_auipc, $is_jal, $is_jalr, $is_beq, $is_bne, $is_blt, $is_bge, $is_bltu, $is_bgeu, $is_lb, $is_lh, $is_lw, $is_lbu, $is_lhu, $is_sb, $is_sh, $is_sw} = '0;
               {$is_addi, $is_slti, $is_sltiu, $is_xori, $is_ori, $is_andi, $is_slli, $is_srli, $is_srai, $is_add, $is_sub, $is_sll, $is_slt, $is_sltu, $is_xor} = '0;
               {$is_srl, $is_sra, $is_or, $is_and, $is_csrrw, $is_csrrs, $is_csrrc, $is_csrrwi, $is_csrrsi, $is_csrrci} = '0;
               {$is_load, $is_store} = '0;
   
               $valid               = 1'b1;
               $rd[4:0]             = 5'b0;
               $rs1[4:0]            = 5'b0;
               $rs2[4:0]            = 5'b0;
               $src1_value[31:0]    = 32'b0;
               $src2_value[31:0]    = 32'b0;
   
               $result[31:0]        = 32'b0;
               $pc[31:0]            = 32'b0;
               $imm[31:0]           = 32'b0;
   
               $is_s_instr          = 1'b0;
   
               $rd_valid            = 1'b0;
               $rs1_valid           = 1'b0;
               $rs2_valid           = 1'b0;
               $rf_wr_en            = 1'b0;
               $rf_wr_index[4:0]    = 5'b0;
               $rf_wr_data[31:0]    = 32'b0;
               $rf_rd_en1           = 1'b0;
               $rf_rd_en2           = 1'b0;
               $rf_rd_index1[4:0]   = 5'b0;
               $rf_rd_index2[4:0]   = 5'b0;
   
               $ld_data[31:0]       = 32'b0;
               $imem_rd_en          = 1'b0;
               $imem_rd_addr[4-1:0] = {4{1'b0}};
               
               /xreg[31:0]
                  $value[31:0]      = 32'b0;
                  $wr               = 1'b0;
                  `BOGUS_USE($value $wr)
                  $dummy[0:0]       = 1'b0;
               /dmem[15:0]
                  $value[31:0]      = 32'b0;
                  $wr               = 1'b0;
                  `BOGUS_USE($value $wr) 
                  $dummy[0:0]       = 1'b0;
               `BOGUS_USE($is_lui $is_auipc $is_jal $is_jalr $is_beq $is_bne $is_blt $is_bge $is_bltu $is_bgeu $is_lb $is_lh $is_lw $is_lbu $is_lhu $is_sb $is_sh $is_sw)
               `BOGUS_USE($is_addi $is_slti $is_sltiu $is_xori $is_ori $is_andi $is_slli $is_srli $is_srai $is_add $is_sub $is_sll $is_slt $is_sltu $is_xor)
               `BOGUS_USE($is_srl $is_sra $is_or $is_and $is_csrrw $is_csrrs $is_csrrc $is_csrrwi $is_csrrsi $is_csrrci)
               `BOGUS_USE($is_load $is_store)
               `BOGUS_USE($valid $rd $rs1 $rs2 $src1_value $src2_value $result $pc $imm)
               `BOGUS_USE($is_s_instr $rd_valid $rs1_valid $rs2_valid)
               `BOGUS_USE($rf_wr_en $rf_wr_index $rf_wr_data $rf_rd_en1 $rf_rd_en2 $rf_rd_index1 $rf_rd_index2 $ld_data)
               `BOGUS_USE($imem_rd_en $imem_rd_addr)
               
               $dummy[0:0]          = 1'b0;
         @4
            $ANY = /top|cpu<>0$ANY;
            
            /xreg[31:0]
               $ANY = /top|cpu/xreg<>0$ANY;
               `BOGUS_USE($dummy)
            
            /dmem[15:0]
               $ANY = /top|cpu/dmem<>0$ANY;
               `BOGUS_USE($dummy)
   
            // m4_mnemonic_expr is build for WARP-V signal names, which are slightly different. Correct them.
            
            $mnemonic[10*8-1:0] = $is_lui ? "LUI       " : $is_auipc ? "AUIPC     " : $is_jal ? "JAL       " : $is_jalr ? "JALR      " : $is_beq ? "BEQ       " : $is_bne ? "BNE       " : $is_blt ? "BLT       " : $is_bge ? "BGE       " : $is_bltu ? "BLTU      " : $is_bgeu ? "BGEU      " : $is_lb ? "LB        " : $is_lh ? "LH        " : $is_lw ? "LW        " : $is_lbu ? "LBU       " : $is_lhu ? "LHU       " : $is_sb ? "SB        " : $is_sh ? "SH        " : $is_sw ? "SW        " : $is_addi ? "ADDI      " : $is_slti ? "SLTI      " : $is_sltiu ? "SLTIU     " : $is_xori ? "XORI      " : $is_ori ? "ORI       " : $is_andi ? "ANDI      " : $is_slli ? "SLLI      " : $is_srli ? "SRLI      " : $is_srai ? "SRAI      " : $is_add ? "ADD       " : $is_sub ? "SUB       " : $is_sll ? "SLL       " : $is_slt ? "SLT       " : $is_sltu ? "SLTU      " : $is_xor ? "XOR       " : $is_srl ? "SRL       " : $is_sra ? "SRA       " : $is_or ? "OR        " : $is_and ? "AND       " : $is_csrrw ? "CSRRW     " : $is_csrrs ? "CSRRS     " : $is_csrrc ? "CSRRC     " : $is_csrrwi ? "CSRRWI    " : $is_csrrsi ? "CSRRSI    " : $is_csrrci ? "CSRRCI    " :  $is_load ? "LOAD      " : $is_store ? "STORE     " : "ILLEGAL   ";
            \viz_js
               box: {left: -600, top: -20, width: 2000, height: 1000, strokeWidth: 0},
               render() {
                  //
                  // PC instr_mem pointer
                  //
                  let $pc = '$pc';
                  let color = !('$valid'.asBool()) ? "gray" :
                                                     "blue";
                  let pcPointer = new fabric.Text("->", {
                     top: 18 * ($pc.asInt() / 4),
                     left: -600,
                     fill: color,
                     fontSize: 14,
                     fontFamily: "monospace"
                  });
                  //
                  //
                  // Fetch Instruction
                  //
                  // TODO: indexing only works in direct lineage.  let fetchInstr = new fabric.Text('|fetch/instr_mem[$Pc]$instr'.asString(), {  // TODO: make indexing recursive.
                  //let fetchInstr = new fabric.Text('$raw'.asString("--"), {
                  //   top: 50,
                  //   left: 90,
                  //   fill: color,
                  //   fontSize: 14,
                  //   fontFamily: "monospace"
                  //});
                  //
                  // Instruction with values.
                  //
                  let regStr = (valid, regNum, regValue) => {
                     return valid ? `r${regNum} (${regValue})` : `rX`;
                  };
                  let srcStr = ($src, $valid, $reg, $value) => {
                     return $valid.asBool(false)
                                ? `\n      ${regStr(true, $reg.asInt(NaN), $value.asInt(NaN))}`
                                : "";
                  };
                  let str = `${regStr('$rd_valid'.asBool(false), '$rd'.asInt(NaN), '$result'.asInt(NaN))}\n` +
                            `  = ${'$mnemonic'.asString()}${srcStr(1, '$rs1_valid', '$rs1', '$src1_value')}${srcStr(2, '$rs2_valid', '$rs2', '$src2_value')}\n` +
                            `      i[${'$imm'.asInt(NaN)}]`;
                  let instrWithValues = new fabric.Text(str, {
                     top: 70,
                     left: 90,
                     fill: color,
                     fontSize: 14,
                     fontFamily: "monospace"
                  });
                  return [pcPointer, instrWithValues];
               }
            //
            // Register file
            //
            /xreg[31:0]           
               \viz_js
                  box: {width: 90, height: 18, strokeWidth: 0},
                  all: {
                     box: {strokeWidth: 0},
                     init() {
                        let regname = new fabric.Text("Reg File", {
                           top: -20, left: 2,
                           fontSize: 14,
                           fontFamily: "monospace"
                        });
                        return {regname};
                     }
                  },
                  init() {
                     let reg = new fabric.Text("", {
                        top: 0, left: 0,
                        fontSize: 14,
                        fontFamily: "monospace"
                     });
                     return {reg};
                  },
                  render() {
                     let mod = '$wr'.asBool(false);
                     let reg = parseInt(this.getIndex());
                     let regIdent = reg.toString();
                     let oldValStr = mod ? `(${'>>1$value'.asInt(NaN).toString()})` : "";
                     this.getObjects().reg.set({
                        text: regIdent + ": " + '$value'.asInt(NaN).toString() + oldValStr,
                        fill: mod ? "blue" : "black"});
                  },
                  where: {left: 365, top: -20},
                  where0: {left: 0, top: 0}
            //
            // DMem
            //
            /dmem[15:0]
               \viz_js
                  box: {width: 100, height: 18, strokeWidth: 0},
                  all: {
                     box: {strokeWidth: 0},
                     init() {
                     let memname = new fabric.Text("Mini DMem", {
                           top: -20,
                           left: 2,
                           fontSize: 14,
                           fontFamily: "monospace"
                        });
                        return {memname};
                     }
                  },
                  init() {
                     let mem = new fabric.Text("", {
                        top: 0,
                        left: 10,
                        fontSize: 14,
                        fontFamily: "monospace"
                     });
                     return {mem};
                  },
                  render() {
                     let mod = '$wr'.asBool(false);
                     let mem = parseInt(this.getIndex());
                     let memIdent = mem.toString();
                     let oldValStr = mod ? `(${'>>1$value'.asInt(NaN).toString()})` : "";
                     this.getObjects().mem.set({
                        text: memIdent + ": " + '$value'.asInt(NaN).toString() + oldValStr,
                        fill: mod ? "blue" : "black"});
                  },
                  where: {left: 458, top: -20},
                  where0: {left: 0, top: 0}
          
      
   \end_source    // For visualisation, argument should be at least equal to the last stage of CPU logic. @4 would work for all labs.
\SV
   endmodule

