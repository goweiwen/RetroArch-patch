#!/bin/bash

# Define directories, only if not given as environment variables
SUBMODULE_DIR="${SUBMODULE_DIR:-submodules/RetroArch}"
BUILD_DIR="${BUILD_DIR:-build}"
PATCH_DIR="${PATCH_DIR:-patches}"
SRC_DIR="${SRC_DIR:-src}"
TEMP_DIR=$(mktemp -d)

# Create patches directory if it doesn't exist
mkdir -p $PATCH_DIR

# Get the last patch number
LAST_PATCH=$(ls $PATCH_DIR/*.patch 2> /dev/null | grep -oP '\d{5}' | sort -n | tail -1)
if [ -z "$LAST_PATCH" ]; then
    LAST_PATCH=0
fi
NEW_PATCH_NUM=$(printf "%05d" $((LAST_PATCH + 1)))

# Prompt the user for a descriptive filename
echo -e "\e[33mEnter a descriptive name for the patch file:\e[0m"
read PATCH_NAME

# Generate a timestamp for the patch file
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create the patch file with the descriptive name
PATCH_FILE="$PATCH_DIR/${NEW_PATCH_NUM}_${TIMESTAMP}_${PATCH_NAME}.patch"

echo -e "\e[32mCreating patch file: $PATCH_FILE\e[0m"

# Run make assemble using the temporary directory as the build directory
make assemble \
    BUILD_DIR=$TEMP_DIR \
    SUBMODULE_DIR=$SUBMODULE_DIR \
    PATCH_DIR=$PATCH_DIR \
    SRC_DIR=$SRC_DIR \
    > /dev/null 2>&1 ||
    exit 1

cd $BUILD_DIR && make -f Makefile.miyoomini clean > /dev/null 2>&1 && cd ..

# Generate the patch, ignoring files in the src directory
rsync -a --exclude-from=<(cd $SRC_DIR && find . -type f) $TEMP_DIR/ $BUILD_DIR/ --delete
git diff --no-index --ignore-space-at-eol $TEMP_DIR $BUILD_DIR > $PATCH_FILE 2> /dev/null

# Delete the temporary directory
rm -rf $TEMP_DIR

# Check if the patch file is empty and delete it if it is
if [ ! -s $PATCH_FILE ]; then
    rm $PATCH_FILE
    echo -e "\e[31mNo changes detected. Patch file not created.\e[0m"
else
    echo -e "\e[32mPatch file created: $PATCH_FILE\e[0m"
fi
