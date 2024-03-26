
# FOLDERS := $(wildcard *)
SIMS_FOLDERS := $(wildcard $(PROJECT_ROOT)/sims/*/)

# Checks for tb.mk
VALID_SIMS_FOLDERS :=
$(foreach folder,$(SIMS_FOLDERS),$(if $(wildcard $(folder)/tb.mk),$(eval VALID_SIMS_FOLDERS += $(folder))))

define sourcing_mk 
include $(1)
endef

define gen_build_target
BUILD_DIR := $(1)

.PHONY: build-$(BUILD_NAME)
build-$(BUILD_NAME):
	@echo $$(BUILD_DIR)
	cd $$(BUILD_DIR) && \
	iverilog -o $(BUILD_NAME).out -DVCD_DUMP=1 $(TB_SOURCE) $(TB_INCLUDE) && \
	vvp $(BUILD_NAME).out
endef

$(foreach x, $(VALID_SIMS_FOLDERS), \
	$(eval $(call sourcing_mk, $(x)tb.mk)) \
	$(eval $(call gen_build_target, $(x))) \
)

# SIMS_FOLDERS_EDIT := $(patsubst %/,%,$(VALID_SIMS_FOLDERS))																															# Remove trailing '/'
# Get the name of the testbench root folder
# TESTBENCHES_BUILD := $(foreach folder,$(SIMS_FOLDERS_EDIT), $(notdir $(basename $(folder))))

TARGET = 

# build-%:
# 	@echo $*
# iverilog -o $(TARGET)/$(TARGET)_tb.out -DVCD_DUMP=1 $(TARGET)/$(TARGET)_tb.v ../source/*.v
# vvp $(TARGET)/$(TARGET)_tb.out

launch:
	gtkwave $(TARGET)/$(TARGET)_tb.vcd

gtkw:
	gtkwave $(TARGET)/$(TARGET)_tb.gtkw

clean:
	rm -f $(TARGET)/$(TARGET)_tb.out
	rm -f $(TARGET)/$(TARGET)_tb.vcd





