SUBMODULE_DIR = submodules/RetroArch
BUILD_DIR = build
SRC_DIR = src
PATCH_DIR = patches

# Function to print status messages
print_status = echo -e "\033[34m--- $1\033[0m"

.PHONY: all build assemble apply-patches copy-submodule update-submodule convert-line-endings init-submodule create-patch clean

all: build

## Submodule management

init-submodule:
	$(call print_status, Initializing submodule)
	@if [ -d "$(SUBMODULE_DIR)" ] && [ -z "$$(ls -A $(SUBMODULE_DIR))" ]; then \
		git submodule update --init --recursive; \
	else \
		echo "Submodule directory is not empty, skipping initialization"; \
	fi

copy-submodule: init-submodule
	@$(call print_status, Copying submodule)
	mkdir -p $(BUILD_DIR)
	cp -r $(SUBMODULE_DIR)/* $(BUILD_DIR)/

## Patch management

convert-line-endings:
	@$(call print_status, Converting line endings)
	find $(BUILD_DIR) -type f \( -name '*.c' -o -name '*.h' \) -exec sed -i "s/\r\$$//" {} +

apply-patches: copy-submodule convert-line-endings
	@for patch in $(sort $(wildcard $(PATCH_DIR)/*.patch)); do \
		$(call print_status, Applying $$patch); \
		patch -d $(BUILD_DIR) -p1 < $$patch; \
	done

create-patch:
	@$(call print_status, Creating patch)
	./scripts/create_patch.sh

assemble: apply-patches
	@$(call print_status, Assembling source)
	cp -r $(SRC_DIR)/* $(BUILD_DIR)/

## Build targets

$(BUILD_DIR)/retroarch:
	@$(call print_status, Building for Miyoo Mini)
	@cd $(BUILD_DIR) && make -f Makefile.miyoomini PACKAGE_NAME=retroarch

$(BUILD_DIR)/retroarch_miyoo354:
	@$(call print_status, Building for Miyoo 354)
	@cd $(BUILD_DIR) && make -f Makefile.miyoomini MIYOO354=1 PACKAGE_NAME=retroarch_miyoo354

build: assemble $(BUILD_DIR)/retroarch $(BUILD_DIR)/retroarch_miyoo354
	@$(call print_status, Copying binaries)
	mkdir -p bin
	cp $(BUILD_DIR)/retroarch bin/
	cp $(BUILD_DIR)/retroarch_miyoo354 bin/

## Clean everything

clean:
	@$(call print_status, Cleaning)
	rm -rf $(BUILD_DIR)
	rm -rf bin
