
# Get all dirs in 
SIMS_FOLDERS := $(wildcard $(PROJECT_ROOT)/sims/*/)


define sourcing_mk 
include $(1)
endef

# ------------------------------------------------------------ #
# Checks for tb.mk
VALID_SIMS_FOLDERS :=
$(foreach folder,$(SIMS_FOLDERS),$(if $(wildcard $(folder)/tb.mk),$(eval VALID_SIMS_FOLDERS += $(folder))))

# Build Process for compiling testbenches
define gen_build_target
BUILD_DIR := $(1)

.PHONY: build-$(BUILD_NAME)
build-$(BUILD_NAME):
	@echo $$(BUILD_DIR)
	cd $$(BUILD_DIR) && \
	iverilog -o $(BUILD_NAME).out -DVCD_DUMP=1 $(TB_SOURCE) $(TB_INCLUDE) && \
	vvp $(BUILD_NAME).out
endef
# ------------------------------------------------------------ #

# Make Process
$(foreach x, $(VALID_SIMS_FOLDERS), \
	$(eval $(call sourcing_mk, $(x)tb.mk)) \
	$(eval $(call gen_build_target, $(x))) \
)

# Clean build
clean:
	$(foreach x,$(SIMS_FOLDERS), \
		rm -f $(x)*_tb.vcd && \
		rm -f $(x)*.out \
	)





