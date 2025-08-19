# """
# A Python script to flash firmware using OpenOCD.
# This script is an equivalent of the provided bash script.
# """

# import argparse
# import subprocess
# import sys
# import os


# def main():
#     """Main function to parse arguments and run the flash command."""

#     # --- Set up argument parser ---
#     # This is the Python equivalent of assigning positional arguments ($1, $2, $3)
#     parser = argparse.ArgumentParser(
#         description="Flash a firmware file to a target using OpenOCD."
#     )
#     parser.add_argument("openocd_exe", help="Path to the openocd executable")
#     parser.add_argument("firmware_elf", help="Path to the firmware .elf file")
#     parser.add_argument(
#         "openocd_cfg", help="Path to the root of the openocd scripts directory"
#     )
#     args = parser.parse_args()

#     # --- Print information for clarity ---
#     print("--- Flashing Firmware ---")
#     print(f"Working Directory:  {os.getcwd()}")
#     print(f"OpenOCD Executable: {args.openocd_exe}")
#     print(f"Firmware: {args.firmware_elf}")
#     print(f"OpenOCD Config: {args.openocd_cfg}")
#     print("-------------------------")

#     # --- Construct and execute the command ---
#     # The command is built as a list of strings to avoid shell injection issues.
#     command = [
#         args.openocd_exe,
#         "-f",
#         args.openocd_cfg,
#         "-c",
#         f'program "{args.firmware_elf}" verify reset exit',
#     ]

#     try:
#         # subprocess.run with check=True is the equivalent of `set -e` in bash.
#         # It will raise a CalledProcessError if the command returns a non-zero exit code.
#         subprocess.run(command, check=True)
#         print("--- Flash Complete ---")

#     except FileNotFoundError:
#         print(
#             f"Error: The executable was not found at '{args.openocd_exe}'",
#             file=sys.stderr,
#         )
#         sys.exit(1)
#     except subprocess.CalledProcessError as e:
#         print(
#             f"Error: OpenOCD command failed with exit code {e.returncode}",
#             file=sys.stderr,
#         )
#         sys.exit(e.returncode)
#     except Exception as e:
#         print(f"An unexpected error occurred: {e}", file=sys.stderr)
#         sys.exit(1)


# if __name__ == "__main__":
#     main()

import argparse
import subprocess
import sys
import os

# This library is the key. It knows how to read the MANIFEST file on Windows.
from python.runfiles import runfiles


def main():
    parser = argparse.ArgumentParser(
        description="Flash a firmware file to a target using OpenOCD."
    )
    # These arguments now receive the canonical paths from the BUILD file's args
    parser.add_argument("openocd_canonical_path")
    parser.add_argument("firmware_canonical_path")
    parser.add_argument("config_canonical_path")
    args = parser.parse_args()

    # This creates a runfiles object. On Windows, it finds and parses the MANIFEST.
    r = runfiles.Create()

    # r.Rlocation() acts like a dictionary lookup. It takes the canonical path (the key)
    # and returns the actual, physical path to the file on disk (the value).
    # This works seamlessly on ALL platforms.
    openocd_exe_actual_path = r.Rlocation(
        args.openocd_canonical_path + (".exe" if sys.platform == "win32" else "")
    )
    firmware_elf_actual_path = r.Rlocation(args.firmware_canonical_path)
    openocd_cfg_actual_path = r.Rlocation(args.config_canonical_path)

    # Sanity check for debugging
    if not openocd_exe_actual_path or not os.path.exists(openocd_exe_actual_path):
        print(
            f"FATAL: Runfiles library could not find executable for canonical path '{args.openocd_canonical_path}'",
            file=sys.stderr,
        )
        sys.exit(1)

    print("--- Flashing Firmware (Paths resolved via Runfiles Library) ---")
    print(f"Working Directory:      {os.getcwd()}")
    print(f"Resolved OpenOCD Path:  {openocd_exe_actual_path}")
    print(f"Resolved Firmware Path: {firmware_elf_actual_path}")
    print(f"Resolved Config Path:   {openocd_cfg_actual_path}")
    print("-----------------------------------------------------------------")

    # Normalize the firmware path for the OpenOCD command string
    firmware_elf_arg = firmware_elf_actual_path.replace("\\", "/")

    command = [
        openocd_exe_actual_path,
        "-f",
        openocd_cfg_actual_path,
        "-c",
        f'program "{firmware_elf_arg}" verify reset exit',
    ]

    try:
        subprocess.run(command, check=True)
        print("--- Flash Complete ---")
    except Exception as e:
        print(f"An unexpected error occurred: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
