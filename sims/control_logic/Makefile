# unset GTK_PATH

all: build launch

build:
	iverilog -o control_logic_tb.out -DVCD_DUMP=1 control_logic_tb.v ../../source/*.v
	vvp control_logic_tb.out

launch:
	gtkwave control_logic_tb.vcd

clean:
	rm -f control_logic_tb.out
	rm -f control_logic_tb.vcd
