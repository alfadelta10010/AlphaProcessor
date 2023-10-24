# AlphaSoC
- AlphaSoC is a RISC-V Processor made as a part of the VLSI Physical Design for ASICs course.
- This follows in the footsteps of [VSDBabySoC](https://github.com/manili/VSDBabySoC), using a similar layout and combining a RV core (based on RVMYTH course) with PLL and DAC to build a stand-alone SoC.

## Overall Architecture Block Diagaram

![AlphaSoC](images/Diagram.png)


### AlphaCore 
- AlphaCore is a simple RISC-V CPU, written in TL-Verilog, made by following the RISC-V MYTH course by VSD and RedwoodEDA.

### PLL
- A Phase-locked loop is a control system that generate an output signal with a phase related to the phase of the input signal.
- A PLL is used for synchronization, and here we are using a PLL for clock generation
- We are using a PLL made by VSD-IP, called [avsdpll](https://github.com/vsdip/rvmyth_avsdpll_interface)

### DAC
- A digital-to-analog converter is used to convert digital signals to analog signals.
- A DAC is used for communication purposes, to enable the generation of digitally-defined transmission signals.
- We are using a DAC made by VSD-IP, called [avsddac](https://github.com/vsdip/rvmyth_avsddac_interface).

### AlphaCore Block Diagram

![Block Diagram](images/block_diagram.png)

### Converting TL-Verilog file to Verilog
- We use Sandpiper-SaaS to convert our TL-Verilog processor to Verilog for synthesis and physical design, with the following command:
```bash
sandpiper-saas -i src/module/alphacore.tlv -o alphacore.v --bestsv --noline -p verilog --outdir output/compiled_tlv
```
- The output is as follows:

![Result](images/sandpiper_op.png)

### Running pre-synthesis simulations
- Here, we increase/decrease the digital output value and feed it to the DAC. so we can watch the changes on the SoC output
- We use `iverilog` and `gtkwave` to run the testbench on our module with the following command:
```bash
iverilog -o output/pre_synth_sim/pre_synth_sim.out src/module/testbench.v -I src/include -I src/module -I output/compiled_tlv
cd output/pre_synth_sim
./pre_synth_sim.out
```
- It gives the following output:

![pre_synth_term](images/pre_synth_term.png)

![pre_synth_waveform](images/pre_synth_waveform.png)

### Running Synthesis
- First, we need to create `.lib` files for `avsdpll.v` and `avsddac.v`. 
- We do this using the `verilog_to_lib.pl` script, which is run using the following commands:
```bash
cd ../../src/lib
perl verilog_to_lib.pl ../module/avsdpll.v avsdpll
perl verilog_to_lib.pl ../module/avsddac.v avsddac
```
- This creates `avsdpll.lib` and `avsddac.lib`, which we can invoke in YoSys
- To synthesize our design, we execute the following commands:
```
read_verilog ./module/alphasoc.v
read_verilog -I./include ../output/compiled_tlv/alphacore.v
read_verilog -I./include ./module/clk_gate.v
read_liberty -lib ./lib/avsdpll.lib
read_liberty -lib ./lib/avsddac.lib
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
- These are the statistics of our design:
```
=== alphasoc ===

   Number of wires:              10457
   Number of wire bits:          12558
   Number of public wires:       10457
   Number of public wire bits:   12558
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:              12444
     avsddac                         1
     avsdpll                         1
     sky130_fd_sc_hd__a2111oi_0     23
     sky130_fd_sc_hd__a211o_2       32
     sky130_fd_sc_hd__a211oi_1      22
     sky130_fd_sc_hd__a21boi_0       7
     sky130_fd_sc_hd__a21o_2         3
     sky130_fd_sc_hd__a21oi_1     1835
     sky130_fd_sc_hd__a221oi_1      68
     sky130_fd_sc_hd__a22o_2         9
     sky130_fd_sc_hd__a22oi_1      420
     sky130_fd_sc_hd__a311oi_1       3
     sky130_fd_sc_hd__a31o_2         2
     sky130_fd_sc_hd__a31oi_1       39
     sky130_fd_sc_hd__a32oi_1        4
     sky130_fd_sc_hd__and2_2        11
     sky130_fd_sc_hd__and3_2         3
     sky130_fd_sc_hd__clkinv_1    1386
     sky130_fd_sc_hd__dfxtp_1     1970
     sky130_fd_sc_hd__mux2i_1       25
     sky130_fd_sc_hd__nand2_1     3500
     sky130_fd_sc_hd__nand3_1      195
     sky130_fd_sc_hd__nand3b_1       1
     sky130_fd_sc_hd__nand4_1      179
     sky130_fd_sc_hd__nor2_1       794
     sky130_fd_sc_hd__nor3_1        77
     sky130_fd_sc_hd__nor4_1       108
     sky130_fd_sc_hd__o2111ai_1     23
     sky130_fd_sc_hd__o211ai_1      84
     sky130_fd_sc_hd__o21a_1        17
     sky130_fd_sc_hd__o21ai_0      848
     sky130_fd_sc_hd__o21bai_1      34
     sky130_fd_sc_hd__o221a_2        3
     sky130_fd_sc_hd__o221ai_1      46
     sky130_fd_sc_hd__o22ai_1      582
     sky130_fd_sc_hd__o2bb2ai_1      2
     sky130_fd_sc_hd__o311ai_0       7
     sky130_fd_sc_hd__o31ai_1        5
     sky130_fd_sc_hd__o32ai_1        2
     sky130_fd_sc_hd__or2_2         19
     sky130_fd_sc_hd__or4_2          9
     sky130_fd_sc_hd__xnor2_1        9
     sky130_fd_sc_hd__xor2_1        36
```
- The synthesis log can be found in [synth.log](output/synth/synth.log)



## Files
- [alphacore.tlv](src/module/alphacore.tlv): The source TL-Verilog file
- [alpha_processor.sv](src/module/alpha_processor.sv): Generated by Sandpiper (contains logic)
- [alpha_processor_gen.sv](src/module/alpha_processor_gen.sv): Generated by Sandpiper (contains declartions and staging)

![Code Comparision](images/code_comparision.png)
