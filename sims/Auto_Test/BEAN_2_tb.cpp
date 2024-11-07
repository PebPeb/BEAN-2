#include <iostream>
#include "VBEAN_2.h"  // Generated header from Verilator
#include "Vimem.h"
#include "Vdmem.h"
#include "verilated.h"   // Verilator library for simulation
#include "verilated_vcd_c.h"  // Verilator VCD tracing


int main(int argc, char **argv) {
  // Initialize Verilator simulation model
  Verilated::commandArgs(argc, argv);  // Initialize Verilator
  Verilated::traceEverOn(true);

  VBEAN_2* BEAN2 = new VBEAN_2;  // Instantiate the Verilog module
  Vimem* imem = new Vimem;
  Vdmem* dmem = new Vdmem;

  // Create VCD trace file
  VerilatedVcdC* tfp = new VerilatedVcdC;
  BEAN2->trace(tfp, 99);  // Trace signals in BEAN_2
  imem->trace(tfp, 99);   // Trace signals in imem
  dmem->trace(tfp, 99);   // Trace signals in dmem
  tfp->open("BEAN_2_tb.vcd");

// Clock and reset signals
  bool clk = 0;
  BEAN2->clk = clk;
  BEAN2->reset = 1;

  // Simulation parameters
  int sim_time = 0;
  const int reset_time = 6; // Simulation time to release reset
  const int max_time = 10000; // End simulation time

  while (sim_time < max_time && !Verilated::gotFinish()) {
    // Toggle clock every 2 time units
    clk = !clk;
    BEAN2->clk = clk;
    dmem->clk = clk;

    // Release reset after reset_time
    if (sim_time == reset_time) {
      BEAN2->reset = 0;
    }

    // Connect BEAN_2 core to instruction memory
    imem->a = BEAN2->pc;
    BEAN2->Instr = imem->rd;

    // Connect BEAN_2 core to data memory
    dmem->a = BEAN2->memAdrs;
    dmem->wd = BEAN2->memDataWD;
    dmem->we = BEAN2->dmem_WE;
    dmem->mode = BEAN2->dmem_SEL;
    BEAN2->memDataRD = dmem->rd;

    // Evaluate the modules for this time step
    BEAN2->eval();
    imem->eval();
    dmem->eval();

    // Dump trace at each time step
    tfp->dump(sim_time);

    // Increment simulation time
    sim_time++;
  }

  // Close VCD file and clean up
  tfp->close();
  delete BEAN2;
  delete imem;
  delete dmem;
  delete tfp;

  std::cout << "Simulation finished" << std::endl;
  return 0;
}
