SUBMODULE_DIR = submodules/RetroArch
BUILD_DIR = build
SRC_DIR = src
PATCH_DIR = patches

all: build

init-submodule:
	git submodule update --init --recursive

update-submodule: configure-submodule
	git submodule update --remote --merge

copy-submodule: init-submodule
	mkdir -p $(BUILD_DIR)
	cp -r $(SUBMODULE_DIR)/* $(BUILD_DIR)/

convert-line-endings:
	find $(BUILD_DIR) -type f \( -name '*.c' -o -name '*.h' \) -exec sed -i "s/\r\$$//" {} +

apply-patches: copy-submodule convert-line-endings
	for patch in $(sort $(wildcard $(PATCH_DIR)/*.patch)); do \
		echo "--- Applying patch $$patch"; \
		patch --binary -d $(BUILD_DIR) -p1 < $$patch; \
	done

copy-src: apply-patches
	cp -r $(SRC_DIR)/* $(BUILD_DIR)/

build: copy-src
	cd $(BUILD_DIR) && make -f Makefile.miyoomini

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all build copy-src apply-patches copy-submodule update-submodule
