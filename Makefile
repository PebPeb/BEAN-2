
# Root of the poject
PROJECT_ROOT = $(abspath .)

export PROJECT_ROOT

-include $(PROJECT_ROOT)/config.properties
include $(PROJECT_ROOT)/sims/sims.mk
