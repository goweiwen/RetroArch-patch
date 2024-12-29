#!/bin/bash
PWD="$(pwd)"
echo -e "\e[32mCurrent directory: $PWD\e[0m"

# Define directories, only if not given as environment variables
SUBMODULE_DIR="${SUBMODULE_DIR:-submodules/RetroArch}"
BUILD_DIR="${BUILD_DIR:-build}"
PATCH_DIR="${PATCH_DIR:-patches}"
SRC_DIR="${SRC_DIR:-src}"

# Create patches directory if it doesn't exist
mkdir -p "$PATCH_DIR"

# Get the last patch number
LAST_PATCH=$(ls $PATCH_DIR/*.patch 2> /dev/null | grep -oP '\d{5}' | sort -n | tail -1)
if [ -z "$LAST_PATCH" ]; then
    LAST_PATCH=0
fi
# Increment the last patch number
NEW_PATCH_NUM=$(printf "%05d" $((10#$LAST_PATCH + 1)))

# Prompt the user for a descriptive filename
echo -e "\e[33mEnter a descriptive name for the patch file:\e[0m"
read PATCH_NAME

# Create the patch file with the descriptive name
PATCH_FILE="$PATCH_DIR/${NEW_PATCH_NUM}_${PATCH_NAME}.patch"
FULL_PATH="$PWD/$PATCH_FILE"

echo -e "\e[32mCreating patch file: $FULL_PATH\e[0m"

# Generate the patch
cd "$SUBMODULE_DIR"
git diff --ignore-space-at-eol > "$FULL_PATH" 2> /dev/null

# Check if the patch file is empty and delete it if it is
if [ ! -s "$FULL_PATH" ]; then
    rm "$FULL_PATH" 2> /dev/null
    echo -e "\e[31mNo changes detected. Patch file not created.\e[0m"
else
    echo -e "\e[32mPatch file created: $FULL_PATH\e[0m"
fi
