
TARGET = 

all: build launch

build:
	iverilog -o $(TARGET)/$(TARGET)_tb.out -DVCD_DUMP=1 $(TARGET)/$(TARGET)_tb.v ../source/*.v
	vvp $(TARGET)/$(TARGET)_tb.out

launch:
	gtkwave $(TARGET)/$(TARGET)_tb.vcd

gtkw:
	gtkwave $(TARGET)/$(TARGET)_tb.gtkw

clean:
	rm -f $(TARGET)/$(TARGET)_tb.out
	rm -f $(TARGET)/$(TARGET)_tb.vcd