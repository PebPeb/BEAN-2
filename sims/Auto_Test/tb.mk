# ================================================
#             VeroMake Project Makefile
# ================================================
# This Makefile is for use with VeroMake.
# Project Repository: https://github.com/PebPeb/VeroMake
# ================================================

# Project Name - This name will show up on the build options
BUILD_NAME := BEAN-2_Auto_Test

# $(PROJECT_ROOT) is provided from the root Makefile of VeroMake
# Relative Path in relation to root Makefile ---> my/relative/path/to/source 
RELATIVE_PROJECT_PATH := BEAN-2

# Short hand for making adding sources files easier
PDIR := $(PROJECT_ROOT)/$(RELATIVE_PROJECT_PATH)

# List of Testbench Source Files
# TB_SOURCE root directory is the default output of VeroMake
# Current Valid sources are .v & .cpp
TB_SOURCE := 

# List of files that build up verilog module under test
TB_TOP_MODULE := BEAN_2
TB_INCLUDE := 

###########################
######## Verilator ########
###########################

# List of modules to compile
V_COMPILE := BEAN_2 imem dmem

V_SOURCE_BEAN_2 := $(PDIR)/source/BEAN_2.v \
	$(PDIR)/source/alu32.v \
	$(PDIR)/source/adder.v \
	$(PDIR)/source/control_logic.v \
	$(PDIR)/source/datapath.v \
	$(PDIR)/source/extend.v \
	$(PDIR)/source/flopr.v \
	$(PDIR)/source/flopren.v \
	$(PDIR)/source/hazard_logic.v \
	$(PDIR)/source/mux2.v \
	$(PDIR)/source/mux4.v \
	$(PDIR)/source/regfile.v  

V_SOURCE_dmem := $(PDIR)/source/dmem.v

V_SOURCE_imem := $(PDIR)/source/imem.v

V_TB := BEAN_2_tb.cpp 
