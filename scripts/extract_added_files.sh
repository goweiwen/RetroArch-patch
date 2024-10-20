#!/bin/bash

PATCH_DIR="patches"
SRC_DIR="src"

# Ensure the src directory exists
mkdir -p $SRC_DIR

# Loop through all patch files in the PATCH_DIR
for patch in $PATCH_DIR/*.patch; do
    echo "Processing patch: $patch"
    # Extract added files from the patch
    awk '/^diff --git/ { file=$3; next } /^new file mode/ { print file }' $patch | sed 's|^a/||' | while read -r file; do
        # Create the directory structure in the src directory
        mkdir -p "$SRC_DIR/$(dirname "$file")"
        # Extract the file content from the patch and save it in the src directory
        awk "/^diff --git a\/$(echo $file | sed 's/\//\\\//g') b\/$(echo $file | sed 's/\//\\\//g')/,/^diff --git/" $patch | sed -n "/^@@/,/^diff --git/ p" | sed '/^diff --git/ d' | sed 's/^+//' > "$SRC_DIR/$file"
    done
done

echo "All added files have been extracted to the $SRC_DIR directory."
