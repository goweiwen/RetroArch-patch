SUBMODULE_DIR = submodules/RetroArch
BUILD_DIR = build
SRC_DIR = src
PATCH_DIR = patches

# Function to print status messages
print_status = echo -e "\033[34m--- $1\033[0m"

all: build

init-submodule:
	@$(call print_status, Initializing submodule)
	git submodule update --init --recursive

update-submodule: configure-submodule
	@$(call print_status, Updating submodule)
	git submodule update --remote --merge

copy-submodule: init-submodule
	@$(call print_status, Copying submodule)
	mkdir -p $(BUILD_DIR)
	cp -r $(SUBMODULE_DIR)/* $(BUILD_DIR)/

convert-line-endings:
	@$(call print_status, Converting line endings)
	find $(BUILD_DIR) -type f \( -name '*.c' -o -name '*.h' \) -exec sed -i "s/\r\$$//" {} +

apply-patches: copy-submodule convert-line-endings
	@for patch in $(sort $(wildcard $(PATCH_DIR)/*.patch)); do \
		$(call print_status, Applying $$patch); \
		patch -d $(BUILD_DIR) -p1 < $$patch; \
	done

assemble: apply-patches
	@$(call print_status, Assembling source)
	cp -r $(SRC_DIR)/* $(BUILD_DIR)/

$(BUILD_DIR)/retroarch:
	@$(call print_status, Building for Miyoo Mini)
	@cd $(BUILD_DIR) && make -f Makefile.miyoomini PACKAGE_NAME=retroarch

$(BUILD_DIR)/retroarch_miyoo354: $(BUILD_DIR)/retroarch
	@$(call print_status, Building for Miyoo 354)
	@cd $(BUILD_DIR) && make -f Makefile.miyoomini MIYOO354=1 PACKAGE_NAME=retroarch_miyoo354

build: assemble $(BUILD_DIR)/retroarch_miyoo354

clean:
	@$(call print_status, Cleaning)
	rm -rf $(BUILD_DIR)

.PHONY: all build assemble apply-patches copy-submodule update-submodule
