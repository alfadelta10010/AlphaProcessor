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

## Files
- [alpha_processor.tlv](src/module/alpha_processor.tlv): Generated after combining the library files with the TLV code written
- [alpha_processor.sv](src/module/alpha_processor.sv): Generated by Sandpiper (contains logic)
- [alpha_processor_gen.sv](src/module/alpha_processor_gen.sv): Generated by Sandpiper (contains declartions and staging)

![Code Comparision](images/code_comparision.png)

- 
