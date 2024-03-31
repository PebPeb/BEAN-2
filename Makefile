
# Root of the poject
PROJECT_ROOT = $(abspath .)

export PROJECT_ROOT

-include $(PROJECT_ROOT)/config.properties
include $(PROJECT_ROOT)/sims/sims.mk

gtkwave-container:
	CURRENT_INSTANCES=$$(docker ps --filter name=gtkwave_app -q | wc -l); \
  DESIRED_INSTANCES=$$(expr $$CURRENT_INSTANCES + 1); \
	docker-compose -f $(PROJECT_ROOT)/containers/gtkwave/docker-compose.yml up -d --scale app=$$DESIRED_INSTANCES
