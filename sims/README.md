
To add a new testbench simply add a new folder and add a `tb.mk` file to it. The file should follow the following template.

``` Makefile
# Testbench Makefile

BUILD_NAME = datapath

TB_SOURCE = datapath_tb.v
TB_INCLUDE = $(PROJECT_ROOT)/source/*.v
```

