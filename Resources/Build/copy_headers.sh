#!/bin/bash
# Recursively copy .h, .hpp, and .inl files from one directory to another,
# preserving directory structure.

# Exit on any error
set -e

# --- Usage ---
# ./copy_headers.sh /path/to/source /path/to/destination
# Example:
# ./copy_headers.sh ./Jolt ./include

SRC_DIR="$1"
DEST_DIR="$2"

# Check parameters
if [ -z "$SRC_DIR" ] || [ -z "$DEST_DIR" ]; then
    echo "Usage: $0 <source_directory> <destination_directory>"
    exit 1
fi

# Normalize paths
SRC_DIR=$(cd "$SRC_DIR"; pwd)
DEST_DIR=$(cd "$DEST_DIR"; pwd)

# Create destination directory if it doesn’t exist
mkdir -p "$DEST_DIR"

echo "Copying headers from:"
echo "  Source: $SRC_DIR"
echo "  Target: $DEST_DIR"
echo

# Find and copy files preserving hierarchy
find "$SRC_DIR" \( -name "*.h" -o -name "*.hpp" -o -name "*.inl" \) | while read -r file; do
    rel_path="${file#$SRC_DIR/}"
    dest_path="$DEST_DIR/$rel_path"
    mkdir -p "$(dirname "$dest_path")"
    cp "$file" "$dest_path"
done

echo
echo "✅ Header files copied successfully!"