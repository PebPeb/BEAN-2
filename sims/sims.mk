
# Get all dirs in 
SIMS_FOLDERS := $(wildcard $(PROJECT_ROOT)/sims/*/)

# Checks for tb.mk
VALID_SIMS_FOLDERS :=
$(foreach folder,$(SIMS_FOLDERS),$(if $(wildcard $(folder)/tb.mk),$(eval VALID_SIMS_FOLDERS += $(folder))))

# ------------------------------------------------------------ #
# Source mk files
define sourcing_mk 
include $(1)
endef

# Build Process for compiling testbenches
define gen_build_target
BUILD_DIR_$(BUILD_NAME) := $(1)

.PHONY: build-$(BUILD_NAME)
build-$(BUILD_NAME):
	cd $$(BUILD_DIR_$(BUILD_NAME)) && \
	iverilog -o $(BUILD_NAME).out -DVCD_DUMP=1 $(TB_SOURCE) $(TB_INCLUDE) && \
	vvp $(BUILD_NAME).out
endef

define gtkwave_sim_target 
BUILD_DIR_$(BUILD_NAME) := $(1)
VCD_FILE := $(wildcard $(BUILD_DIR_$(BUILD_NAME))*.vcd)

ifneq ($(strip $(wildcard $(BUILD_DIR_$(BUILD_NAME))*.vcd)),)
.PHONY: gtk-$(BUILD_NAME)
gtk-$(BUILD_NAME):
	@echo $(VCD_FILE)
endif
endef

# ------------------------------------------------------------ #

# Make Process
$(foreach x, $(VALID_SIMS_FOLDERS), \
	$(eval $(call sourcing_mk, $(x)tb.mk)) \
	$(eval $(call gen_build_target, $(x))) \
	$(eval $(call gtkwave_sim_target, $(x))) \
)

# Clean build
clean:
	$(foreach x,$(VALID_SIMS_FOLDERS), \
		rm -f $(x)*_tb.vcd && \
		rm -f $(x)*.out \
	)





