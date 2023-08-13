# unset GTK_PATH

all: build launch

build:
	iverilog -o datapath_tb.out -DVCD_DUMP=1 datapath_tb.v ../../source/*.v
	vvp datapath_tb.out

launch:
	gtkwave datapath_tb.vcd

clean:
	rm -f datapath_tb.out
	rm -f datapath_tb.vcd
