# AlphaCore
- AlphaCore is a RISC-V Processor, made as a part of the VLSI Physical Design for ASICs course.
- AlphaCore is a simple RISC-V CPU, written in Verilog.

## Modelling
### Running pre-synthesis simulations
- Here, we run our testbench to ensure our RISC-V processor is running correctly
- We use `iverilog` and `gtkwave` to run the testbench on our module with the following command:
```bash
mkdir output/pre_synth_sim
iverilog -o output/pre_synth_sim/testbench.vvp src/module/testbench.v src/module/alphacore.v -I src/module
chmod -x output/pre_synth_sim/testbench.vvp
vvp -N output/pre_synth_sim/testbench.vvp +vcd
gtkwave output/pre_synth_sim/testbench.vcd
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
read_verilog ./module/alphacore.v
read_liberty -lib ./lib/sky130_fd_sc_hd__tt_025C_1v80.lib
synth -top alphacore
dfflibmap -liberty ./lib/sky130_fd_sc_hd__tt_025C_1v80.lib
opt
abc -liberty ./lib/sky130_fd_sc_hd__tt_025C_1v80.lib -script +strash;scorr;ifraig;retime;{D};strash;dch,-f;map,-M,1,{D}
flatten
setundef -zero
clean -purge
rename -enumerate
stat
write_verilog -noattr ../output/synth/alphacore.synth.v
```
- After running these commands, we get a synthesized module with all of our individual components connected together in `alphacore.synth.v`, found [here](output/synth/alphacore.synth.v).
- These are the statistics of the design:
```
=== alphacore ===

   Number of wires:              13024
   Number of wire bits:          15103
   Number of public wires:       13024
   Number of public wire bits:   15103
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:              14894
     sky130_fd_sc_hd__a2111o_1       1
     sky130_fd_sc_hd__a2111oi_0      6
     sky130_fd_sc_hd__a211o_2        1
     sky130_fd_sc_hd__a211oi_1      35
     sky130_fd_sc_hd__a21boi_0      17
     sky130_fd_sc_hd__a21o_2         3
     sky130_fd_sc_hd__a21oi_1     2073
     sky130_fd_sc_hd__a221oi_1      44
     sky130_fd_sc_hd__a22o_2         3
     sky130_fd_sc_hd__a22oi_1      145
     sky130_fd_sc_hd__a311oi_1      10
     sky130_fd_sc_hd__a31o_2        14
     sky130_fd_sc_hd__a31oi_1       65
     sky130_fd_sc_hd__a32o_1         5
     sky130_fd_sc_hd__a32oi_1       40
     sky130_fd_sc_hd__a41oi_1        4
     sky130_fd_sc_hd__and2_2         6
     sky130_fd_sc_hd__and3_2         2
     sky130_fd_sc_hd__clkinv_1    1173
     sky130_fd_sc_hd__dfxtp_1     1757
     sky130_fd_sc_hd__maj3_1         1
     sky130_fd_sc_hd__mux2_2        30
     sky130_fd_sc_hd__mux2i_1       84
     sky130_fd_sc_hd__nand2_1     3788
     sky130_fd_sc_hd__nand3_1      758
     sky130_fd_sc_hd__nand3b_1       6
     sky130_fd_sc_hd__nand4_1      127
     sky130_fd_sc_hd__nor2_1      1742
     sky130_fd_sc_hd__nor3_1       143
     sky130_fd_sc_hd__nor3b_1        1
     sky130_fd_sc_hd__nor4_1        43
     sky130_fd_sc_hd__nor4b_1        2
     sky130_fd_sc_hd__o2111a_1       2
     sky130_fd_sc_hd__o2111ai_1     36
     sky130_fd_sc_hd__o211a_1        1
     sky130_fd_sc_hd__o211ai_1     145
     sky130_fd_sc_hd__o21a_1        25
     sky130_fd_sc_hd__o21ai_0     1970
     sky130_fd_sc_hd__o21bai_1      58
     sky130_fd_sc_hd__o221a_2        2
     sky130_fd_sc_hd__o221ai_1      24
     sky130_fd_sc_hd__o22a_2         2
     sky130_fd_sc_hd__o22ai_1      225
     sky130_fd_sc_hd__o2bb2ai_1      4
     sky130_fd_sc_hd__o311a_2        1
     sky130_fd_sc_hd__o311ai_0      23
     sky130_fd_sc_hd__o31ai_1       47
     sky130_fd_sc_hd__o32ai_1       12
     sky130_fd_sc_hd__o41ai_1        2
     sky130_fd_sc_hd__or2_2         44
     sky130_fd_sc_hd__or2b_2        65
     sky130_fd_sc_hd__or3_2          7
     sky130_fd_sc_hd__or3b_2         1
     sky130_fd_sc_hd__or4_2          6
     sky130_fd_sc_hd__xnor2_1        9
     sky130_fd_sc_hd__xor2_1        54
```

### Post-synthesis Simulation
- We use `iverilog` and `gtkwave` to run the testbench on our module with the following command:
```bash
iverilog -o output/post_synth_sim/testbench.vvp src/module/testbench_post.v output/synth/alphacore.synth.v -DFUNCTIONAL -DUNIT_DELAY=#1 -I src/module -I src/gls_model
chmod -x output/post_synth_sim/testbench.vvp
vvp -N output/post_synth_sim/testbench.vvp +vcd
gtkwave output/post_synth_sim/testbench.vcd
```

- It gives the following output:

![post_synth_term](images/post_synth_output.png)

![post_synth_waveform](images/post_synth_waveform1.png)

![post_synth_waveform](images/post_synth_waveform2.png)

![post_synth_waveform](images/post_synth_waveform3.png)

## Static Timing Analysis
- We use OpenSTA (part of OpenLANE) to perform gate-level static timing analyser
- We verify the timing of our design using standard file formats
- After starting OpenLANE and navigating to the project directory root, we start OpenSTA using `sta` and run the following commands:
```
read_liberty -min ./lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_liberty -max ./lib/sky130_fd_sc_hd__tt_025C_1v80.lib
set_units -time ns
read_verilog ../output/synth/alphacore.synth.v
link_design alphacore
create_clock [get_ports clk] -name core_clk -period 1100
report_checks
```
- The results are as follows:
```
Startpoint: _53628_ (rising edge-triggered flip-flop clocked by core_clk)
Endpoint: _100086_ (rising edge-triggered flip-flop clocked by core_clk)
Path Group: core_clk
Path Type: max

  Delay    Time   Description
---------------------------------------------------------
   0.00    0.00   clock core_clk (rise edge)
   0.00    0.00   clock network delay (ideal)
   0.00    0.00 ^ _53628_/CLK (sky130_fd_sc_hd__dfxtp_1)
  65.56   65.56 ^ _53628_/Q (sky130_fd_sc_hd__dfxtp_1)
 957.57 1023.13 v _62832_/Y (sky130_fd_sc_hd__nor2_1)
  48.57 1071.70 ^ _76642_/Y (sky130_fd_sc_hd__clkinv_1)
  22.08 1093.78 v _76643_/Y (sky130_fd_sc_hd__nor2_1)
   5.49 1099.27 ^ _89963_/Y (sky130_fd_sc_hd__nand3_1)
   0.16 1099.43 v _89965_/Y (sky130_fd_sc_hd__o21ai_0)
   0.00 1099.43 v _100086_/D (sky130_fd_sc_hd__dfxtp_1)
        1099.43   data arrival time

1100.00 1100.00   clock core_clk (rise edge)
   0.00 1100.00   clock network delay (ideal)
   0.00 1100.00   clock reconvergence pessimism
        1100.00 ^ _100086_/CLK (sky130_fd_sc_hd__dfxtp_1)
  -0.25 1099.75   library setup time
        1099.75   data required time
---------------------------------------------------------
        1099.75   data required time
        -1099.43   data arrival time
---------------------------------------------------------
           0.32   slack (MET)
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

### Set-up
- We first run the following commands to set up our system and OpenLANE for layout generation:
```bash
mkdir -p output/alphacore_layout
cp -r src/designs/alphacore /usr/local/tools/OpenLane/designs
```

### Physical Design
- Let us examine the OpenLane settings that we use to design our processor:
```tcl
set ::env(DESIGN_NAME) "alphacore"
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]
set ::env(BASE_SDC_FILE) [glob $::env(DESIGN_DIR)/src/*.sdc]
set ::env(FP_PIN_ORDER_CFG) [glob $::env(DESIGN_DIR)/pin_order.cfg]

set ::env(CLOCK_PERIOD) "1100.00"
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set ::env(DESIGN_IS_CORE) {0}
set ::env(RUN_HEURISTIC_DIODE_INSERTION) {1}
```
- `DESIGN_NAME`: The name of the top level module of the design
- `VERILOG_FILES`: The path of the design's Verilog files
- `BASE_SDC_FILE`: Specifies the base SDC file using during the flow
- `FP_PIN_ORDER_CFG`: Points to the pin order configuration file to set the pins in specific directions
- `CLOCK_PORT`: The name of the net input to root clock buffer
- `CLOCK_PERIOD`: The clock period used for clocks in the design, in nanoseconds
- `CLOCK_NET`: The name of the net input to root clock buffer
- `DESIGN_IS_CORE`: Controls the layers used in the power grid, we set it to `0` as our design is a macro which goes inside the core.
- `RUN_HEURISTIC_DIODE_INSERTION`: Uses a script to place diodes more efficiently
- `PL_TARGET_FREQUENCY`: The desired placement density of cells, reflects how spread the cells would be on the core area, set to a high value for macros
- `FP_CORE_UTIL`: Core utilization percentage, set to a low value for macros

- For each macro, we create a Pin Configuration file to specify pin placement:
`alphacore/pin_order.cfg`
```
#N
trap
mem_la_read
mem_la_write
mem_la_wdata.*
mem_la_addr.*
mem_la_wstrb.*
cpi_valid
cpi_insn.*
cpi_rs1.*
cpi_rs2.*
cpi_wait
eoi.*
trace_valid
trace_data.*

#S
resetn
clk

#E
irq.*

#W
mem_valid
mem_instr
mem_ready
mem_addr.*
mem_wdata.*
mem_wstrb.*
mem_rdata.*
```
- Each input/output of the module is mapped to the direction the pin should be in the final macro
- For multiple bit wide ports, we define the mapping with `portname.*` to tell the floorplanner to include all the bits of the port.

- We also create a base SDC file for each macro to instruct the Static Timing Analyser for analysis done at various stages
File: `alphacore_synthesis.sdc`
```tcl
set_units -time ns
create_clock [get_ports clk] -name core_clk -period 1100
```

- We then run the following command to generate the layout:
```bash
./flow.tcl -design alphacore | tee /home/alphadelta1803/pes_riscv_processor/output/alphacore_layout/alphacore.log
```

- We then copy the result back into our main project directory:
```bash
cp -r /usr/local/tools/Openlane/designs/alphacore/runs/RUN*/logs output/alphacore_layout/logs
cp -r /usr/local/tools/Openlane/designs/alphacore/runs/RUN*/results/final output/alphacore_layout/results
cp -r /usr/local/tools/Openlane/designs/alphacore/runs/RUN*/reports output/alphacore_layout/reports
```

#### AlphaCore Final GDSII Layout
- We run the following commands to see the GDSII layout of the core
```bash
magic output/macro_layout/alphacore/RUN_2023.12.03_09.03.48/results/final/mag/alphacore.mag -T src/lib/sky130A.tech
```
- The Magic window opens up, and this is our layout for the core:

![AlphaCore GDSII Layout](images/alphacore_gdsii.png)

