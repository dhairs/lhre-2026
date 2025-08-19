#!/bin/bash
# Exit immediately if a command exits with a non-zero status.
set -e

# --- Assign arguments to named variables for clarity ---
# $1: Path to the openocd executable
# $2: Path to the firmware .elf file
# $3: Path to the root of the openocd scripts directory
OPENOCD_EXE="$1"
FIRMWARE_ELF="$2"
OPENOCD_CFG="$3"

# The location of the scripts filegroup points to .../share/openocd/scripts
# The openocd `-s` flag needs the directory that CONTAINS the `scripts` folder.
# So we must point it to the parent directory.
SCRIPTS_SEARCH_PATH="${SCRIPTS_DIR}/.."

echo "--- Flashing Firmware ---"
echo "OpenOCD Executable: ${OPENOCD_EXE}"
echo "Firmware: ${FIRMWARE_ELF}"
echo "OpenOCD Config: ${OPENOCD_CFG}"
echo "-------------------------"

# --- Execute the command ---
"${OPENOCD_EXE}" \
    -f ${OPENOCD_CFG} \
    -c "program \"${FIRMWARE_ELF}\" verify reset exit"

echo "--- Flash Complete ---"
