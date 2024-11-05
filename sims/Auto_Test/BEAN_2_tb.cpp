#include <iostream>
#include "VBEAN_2.h"  // Generated header from Verilator
#include "verilated.h"   // Verilator library for simulation

int main(int argc, char **argv) {
    // Initialize Verilator simulation model
    Verilated::commandArgs(argc, argv);  // Initialize Verilator
    VBEAN_2* top = new VBEAN_2;  // Instantiate the Verilog module

    // Apply some inputs and simulate
    top->a = 0;
    top->b = 0;
    top->eval();  // Evaluate the model

    std::cout << "a = " << (int)top->a << ", b = " << (int)top->b << ", out = " << (int)top->out << std::endl;

    // Change inputs and simulate again
    top->a = 1;
    top->b = 0;
    top->eval();
    std::cout << "a = " << (int)top->a << ", b = " << (int)top->b << ", out = " << (int)top->out << std::endl;

    top->a = 1;
    top->b = 1;
    top->eval();
    std::cout << "a = " << (int)top->a << ", b = " << (int)top->b << ", out = " << (int)top->out << std::endl;

    // Clean up
    delete top;
    return 0;
}