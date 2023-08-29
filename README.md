# BEAN-2

This project is an implementation of a five staged pipelined CPU utilizing the RISC-V ISA. The BEAN-2 is the next stage from the BEAN-1 based off of the RV32I implementation as outlined in the [RISC-V Instruction Set Manual](https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf). Therefor making this a 32-bit cpu, written all in **Verilog**. 

[//]: # (This project was mostly made as a hobby and educational purposes, and I talk more about that and the design process here on my website.)

This CPU includes stalling and flushing in order to handle hazards.

## BEAN-2 High Level Block Diagram

![BEAN-2](assets/BEAN-2_High_Level_Diagram.png)

![BEAN-2](assets/BEAN-2.png)