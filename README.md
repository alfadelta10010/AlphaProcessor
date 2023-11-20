# AlphaCore
- AlphaSoc is a System-On-Chip which includes a RISC-V Processor, a Register file, SPI Memory and a simple UART interface made as a part of the VLSI Physical Design for ASICs course.
- AlphaCore is a simple RISC-V CPU, written in Verilog.
- 

### AlphaCore Block Diagram

![Block Diagram](images/block_diagram.png)

## Modelling
### Running pre-synthesis simulations
- Here, we run our testbench to ensure our RISC-V processor is running correctly
- We use `iverilog` and `gtkwave` to run the testbench on our module with the following command:
```bash
mkdir output/pre_synth_sim
iverilog -o output/pre_synth_sim/testbench.vvp src/module/testbench.v src/module/alphacore.v -I src/module
chmod -x output/pre_synth_sim/testbench.vvp
vvp -N output/pre_synth_sim/testbench.vvp +vcd
mv testbench.vcd output/pre_synth_sim/
gtkwave testbench.vcd
```
- It gives the following output:

![pre_synth_term](images/pre_synth_output.png)

![pre_synth_waveform](images/pre_synth_waveform1.png)

![pre_synth_waveform](images/pre_synth_waveform2.png)

![pre_synth_waveform](images/pre_synth_waveform3.png)

### Running Synthesis
- In OpenLANE container, we run the following commands:
```
cd /home/alphadelta1803/Desktop/projects/pes_riscv_processor/src
yosys
```
- To synthesize our design, we execute the following commands in yosys:
```
read_verilog ./module/alphasoc.v
read_verilog -I./include ./module/alphacore.v
read_verilog -I./include ./module/alphasoc_mem.v
read_verilog -I./include ./module/simpleuart.v
read_verilog -I./include ./module/spimemio.v
read_liberty -lib ./lib/sky130_fd_sc_hd__tt_025C_1v80.lib
synth -top alphasoc
dfflibmap -liberty ./lib/sky130_fd_sc_hd__tt_025C_1v80.lib
opt
abc -liberty ./lib/sky130_fd_sc_hd__tt_025C_1v80.lib -script +strash;scorr;ifraig;retime;{D};strash;dch,-f;map,-M,1,{D}
flatten
setundef -zero
clean -purge
rename -enumerate
stat
write_verilog -noattr ../output/synth/alphasoc.synth.v
```
- After running these commands, we get a synthesized module with all of our individual components connected together in `alphasoc.synth.v`, found [here](output/synth/alphasoc.synth.v).
- These are the statistics of the design:
```
=== alphasoc ===

   Number of wires:              46908
   Number of wire bits:          57149
   Number of public wires:       46908
   Number of public wire bits:   57149
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:              57000
     sky130_fd_sc_hd__a2111o_1       1
     sky130_fd_sc_hd__a2111oi_0     18
     sky130_fd_sc_hd__a211o_2        2
     sky130_fd_sc_hd__a211oi_1      78
     sky130_fd_sc_hd__a21boi_0      19
     sky130_fd_sc_hd__a21o_2         5
     sky130_fd_sc_hd__a21oi_1     7727
     sky130_fd_sc_hd__a221o_2        1
     sky130_fd_sc_hd__a221oi_1      43
     sky130_fd_sc_hd__a22o_2         2
     sky130_fd_sc_hd__a22oi_1      138
     sky130_fd_sc_hd__a2bb2oi_1      1
     sky130_fd_sc_hd__a311o_2        1
     sky130_fd_sc_hd__a311oi_1       7
     sky130_fd_sc_hd__a31o_2        31
     sky130_fd_sc_hd__a31oi_1       91
     sky130_fd_sc_hd__a32o_1        12
     sky130_fd_sc_hd__a32oi_1       38
     sky130_fd_sc_hd__a41o_2         1
     sky130_fd_sc_hd__a41oi_1       20
     sky130_fd_sc_hd__and2_2        10
     sky130_fd_sc_hd__and2b_2        2
     sky130_fd_sc_hd__and3_2         9
     sky130_fd_sc_hd__and3b_2        2
     sky130_fd_sc_hd__clkinv_1    1854
     sky130_fd_sc_hd__dfxtp_1    10256
     sky130_fd_sc_hd__lpflow_inputiso0p_1      3
     sky130_fd_sc_hd__maj3_1         1
     sky130_fd_sc_hd__mux2_2        39
     sky130_fd_sc_hd__mux2i_1       93
     sky130_fd_sc_hd__nand2_1    11659
     sky130_fd_sc_hd__nand3_1     6360
     sky130_fd_sc_hd__nand3b_1     919
     sky130_fd_sc_hd__nand4_1     2716
     sky130_fd_sc_hd__nor2_1      8472
     sky130_fd_sc_hd__nor3_1       279
     sky130_fd_sc_hd__nor3b_1       14
     sky130_fd_sc_hd__nor4_1        90
     sky130_fd_sc_hd__nor4b_1        4
     sky130_fd_sc_hd__o2111a_1       1
     sky130_fd_sc_hd__o2111ai_1    314
     sky130_fd_sc_hd__o211a_1        3
     sky130_fd_sc_hd__o211ai_1     131
     sky130_fd_sc_hd__o21a_1        23
     sky130_fd_sc_hd__o21ai_0     4791
     sky130_fd_sc_hd__o21ba_2        1
     sky130_fd_sc_hd__o21bai_1      35
     sky130_fd_sc_hd__o221a_2        1
     sky130_fd_sc_hd__o221ai_1      50
     sky130_fd_sc_hd__o22ai_1      289
     sky130_fd_sc_hd__o2bb2ai_1      1
     sky130_fd_sc_hd__o311ai_0       9
     sky130_fd_sc_hd__o31ai_1       49
     sky130_fd_sc_hd__o32ai_1        8
     sky130_fd_sc_hd__o41ai_1       17
     sky130_fd_sc_hd__or2_2         41
     sky130_fd_sc_hd__or2b_2        64
     sky130_fd_sc_hd__or3_2          2
     sky130_fd_sc_hd__or3b_2         1
     sky130_fd_sc_hd__or4_2          7
     sky130_fd_sc_hd__xnor2_1       21
     sky130_fd_sc_hd__xnor3_4       31
     sky130_fd_sc_hd__xor2_1        91
     sky130_fd_sc_hd__xor3_4         1
```
- The synthesis log can be found in [synth.log](output/synth/synth.log)

### Post-synthesis Simulation
- We use `iverilog` and `gtkwave` to run the testbench on our module with the following command:
```bash
iverilog -o output/post_synth_sim/post_synth_sim.out -DFUNCTIONAL -DUNIT_DELAY=#1 src/alphacore_tb_post.v -I src/module -I src/gls_model -I output/synth
cd output/post_synth_sim
./post_synth_sim.out
```
- It gives the following output:

![post_synth_term](images/post_synth_output.png)

![post_synth_waveform](images/post_synth_waveform.png)

## Static Timing Analysis
- We use OpenSTA (part of OpenLANE) to perform gate-level static timing analyser
- We verify the timing of our design using standard file formats
- After starting OpenLANE and navigating to the project directory root, we start OpenSTA using `sta` and run the following commands:
```
read_liberty -min ./lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_liberty -max ./lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog ../output/synth/vsdbabysoc.synth.v
link_design vsdbabysoc
report_checks
```
- The results are as follows:
```
```

## Physical Design
-  Physical Design Flow is a cardinal process of converting synthesized netlist, design curtailment and standard library to a layout as per the design rules provided by the foundry. 
- This layout is later sent to the foundry for the creation of the chip.
- Physical Design consists of:
	1. Floorplanning
	1. Placement
	1. Clock Tree Synthesis
	1. Optimization
	1. Global Routing
- We run OpenLANE in interactive mode, so that we can control the various stages
- We also use [Magic](https://github.com/RTimothyEdwards/magic) in viewing and designing our circuit layout.

### Layout Generation
- We first run the following commands to set up our system and OpenLANE for layout generation:
```bash
mkdir -p output/rvmyth_layout
mkdir -p /usr/local/tools/Openlane/designs/alphacore
mkdir -p /usr/local/tools/Openlane/designs/alphacore/src
mkdir -p /usr/local/tools/Openlane/designs/alphacore/src/module
mkdir -p /usr/local/tools/Openlane/designs/alphacore/src/include
cp -r src/layout_conf/* /usr/local/tools/Openlane/designs/alphacore
cp output/compiled_tlv/alphacore.v /usr/local/tools/Openlane/designs/alphacore/src/module
//cp src/module/clk_gate.v /usr/local/tools/Openlane/designs/rvmyth/src/module
//cp output/compiled_tlv/rvmyth_gen.v /usr/local/tools/Openlane/designs/rvmyth/src/include
//cp src/include/*.vh /usr/local/tools/Openlane/designs/rvmyth/src/include
mkdir -p output/rvmyth_layout
```
- We then run the following command to generate the layout:
```
./flow.tcl -design alphacore
```
- We then copy the result back into our main project directory:
```bash
cp -r /usr/local/tools/Openlane/designs/rvmyth/runs/* output/rvmyth_layout
```
