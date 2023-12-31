# BEAN-2

This project is an implementation of a five staged pipelined CPU utilizing the RISC-V ISA. The BEAN-2 is the next iteration from the BEAN-1 based off of the RV32I implementation as outlined in the [RISC-V Instruction Set Manual](https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf). Therefor making this a 32-bit cpu, written all in **Verilog**. This project was mostly made as a hobby and educational purposes, and I talk more about that and the design process [here on my website](https://brycekeen.com).

## High Level Block Diagram

The BEAN-2 is broken down into three major components the *Datapath*, *Control Unit*, and the *Hazard Unit*. The *memory hierarchy* is separate from the CPU to accommodate modularity and various memory configurations and implementations.

![BEAN-2 High Level Block Diagram](assets/BEAN-2_High_Level_Diagram.png)

## System Level Block Diagram

![BEAN-2 System Level Block Diagram](assets/BEAN-2.png)

### Datapath

The **Datapath** handles the arithmetic and logical operations of the CPU. This component contains the Register file, ALU, and all the additional components for additional connections. The Datapath does not handle any of the instruction decoding and leaves this up to the Control Unit. 

![BEAN-2 System Level Block Diagram](assets/BEAN-2_Datapath.png)

### Control Unit

The **Control Unit** handles the instruction decoding, coordination, and sequencing of the system. Mainly operating as the systems brain and controller for the Datapath. The Control Unit enables and switch between components in the Datapath in order to execute a given instruction. For a more in depth description of the instruction types referrer to the [RISC-V Instruction Set Manual](https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf).

![BEAN-2 Control Unit](assets/BEAN-2_Control_Unit.png)

### Hazard Unit

The **Hazard Unit** handles all pipeline hazards that might occur while in operation. The Hazard Unit implements two different tactics to handle these hazards -- flush and stall. Each pipeline stage is able to be independently flushed or stalled depending on the hazard encountered.

![BEAN-2 Hazard Unit](assets/BEAN-2_Hazard_Unit.png)

### Memory Configuration

The BEAN-2 follows a Harvard style architecture utilizing two independent memory caches, instruction and data memory. The CPU and the memory hierarchy are separated for a modular approach to accommodate for independent development. This allows for iterative development of both the memory hierarchy and CPU. Allowing for different styles and approaches to be used with the same CPU design.

## Requirements

- A understanding of the RV32I implementation as referenced in the [RISC-V Instruction Set Manual](https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf) may help with understanding of this project.
- A Verilog synthesis tool is needed for this project such as [Icarus Verilog](https://steveicarus.github.io/iverilog/).
- GTKWave or a waveform viewer of your choice (All scripts are set up with GTKWave).
- 32 bit RISC-V Toolchain ([guide to build the toolchain](https://github.com/riscv/riscv-gnu-toolchain)) for more details on how to compile assembly or C refer to programs folder.


