#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
A Python script to flash firmware using OpenOCD.
This script is an equivalent of the provided bash script.
"""

import argparse
import subprocess
import sys
import os


def main():
    """Main function to parse arguments and run the flash command."""

    # --- Set up argument parser ---
    # This is the Python equivalent of assigning positional arguments ($1, $2, $3)
    parser = argparse.ArgumentParser(
        description="Flash a firmware file to a target using OpenOCD."
    )
    parser.add_argument("openocd_exe", help="Path to the openocd executable")
    parser.add_argument("firmware_elf", help="Path to the firmware .elf file")
    parser.add_argument(
        "openocd_cfg", help="Path to the root of the openocd scripts directory"
    )
    args = parser.parse_args()

    # --- Print information for clarity ---
    print("--- Flashing Firmware ---")
    print(f"Working Directory:  {os.getcwd()}")
    print(f"OpenOCD Executable: {args.openocd_exe}")
    print(f"Firmware: {args.firmware_elf}")
    print(f"OpenOCD Config: {args.openocd_cfg}")
    print("-------------------------")

    # --- Construct and execute the command ---
    # The command is built as a list of strings to avoid shell injection issues.
    command = [
        args.openocd_exe if "exe" not in args.openocd_exe else "../openocd.exe",
        "-f",
        args.openocd_cfg,
        "-c",
        f'program "{args.firmware_elf}" verify reset exit',
    ]

    try:
        # subprocess.run with check=True is the equivalent of `set -e` in bash.
        # It will raise a CalledProcessError if the command returns a non-zero exit code.
        subprocess.run(command, check=True)
        print("--- Flash Complete ---")

    except FileNotFoundError:
        print(
            f"Error: The executable was not found at '{args.openocd_exe}'",
            file=sys.stderr,
        )
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        print(
            f"Error: OpenOCD command failed with exit code {e.returncode}",
            file=sys.stderr,
        )
        sys.exit(e.returncode)
    except Exception as e:
        print(f"An unexpected error occurred: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
