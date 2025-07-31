#!/bin/bash
# Script to generate a compliant JWT key for Slurm authentication

set -e

# Default output location
OUTPUT_DIR="./keys"
OUTPUT_FILE="jwt_hs256.key"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -o|--output)
      OUTPUT_FILE="$2"
      shift 2
      ;;
    -d|--dir)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  -o, --output FILE    Output file name (default: jwt_hs256.key)"
      echo "  -d, --dir DIR        Output directory (default: ./keys)"
      echo "  -h, --help           Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Full path to the output file
FULL_PATH="$OUTPUT_DIR/$OUTPUT_FILE"

# Generate the key
echo "Generating JWT key at $FULL_PATH..."
dd if=/dev/random of="$FULL_PATH" bs=32 count=1 2>/dev/null
chmod 0600 "$FULL_PATH"

echo "JWT key generated successfully!"
echo ""
echo "For .env file, add:"
echo "JWT_KEY_PATH=/var/spool/slurm/statesave/jwt_hs256.key"
echo "JWT_KEY_VOLUME=$FULL_PATH:/var/spool/slurm/statesave/jwt_hs256.key:ro"
echo ""
echo "Note: The key will be mounted as read-only in the container."
