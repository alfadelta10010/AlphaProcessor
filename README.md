# pes_riscv_processor
- RISC-V Processor made as a part of the VLSI Physical Design for ASICs course

## D3SK1 - Combinational logic in TL-Verilog using Makerchip
### L2: Basic MUX implementation
- Chaining Ternary Operator:
```verilog
assign f = sel [0] ? a : (sel[1] ? b : (sel[2] ? c : d));
```
