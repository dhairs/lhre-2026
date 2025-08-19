"""Macro for creating binary and hex files using objcopy."""

load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("@aspect_bazel_lib//lib:transitions.bzl", "platform_transition_filegroup")

def firmware_outputs(name, src, project_name, visibility = None, **kwargs):
    """
    Runs objcopy to convert a source file into both .bin and .hex files.

    Args:
      name: The name of the output target.
      src: The label of the single source file to convert.
      project_name: The name of the project.
      visibility: visibility of the target,
      **kwargs: extra args to pass to genrule.
    """
    # Define the output filenames based on the rule's name
    bin_out = project_name + ".bin"
    hex_out = project_name + ".hex"

    command = ("$(execpath @arm_none_eabi//:objcopy) -O binary $< $(location %s) && " +
               "$(execpath @arm_none_eabi//:objcopy) -O ihex $< $(location %s)") % (bin_out, hex_out)

    native.genrule(
        name = name,
        srcs = [src],
        outs = [
            bin_out,
            hex_out,
        ],
        cmd = command,
        tools = ["@arm_none_eabi//:objcopy"],
        visibility = visibility,
        **kwargs
    )

def binary_out(name, src, visibility = None, **kwargs):
    """
    Runs objcopy to convert a source file (e.g., an ELF) into a raw binary.

    Args:
      name: The name of the output target. The output filename will be `name + ".bin"`.
      src: The label of the single source file to convert.
      visibility: The visibility of the generated rule.
      **kwargs: Additional arguments to pass to the underlying genrule.
    """
    native.genrule(
        name = name,
        srcs = [src],
        outs = [src + ".bin"],
        cmd = "$(execpath @arm_none_eabi//:objcopy) -O binary $< $@",
        cmd_bat = "copy \"$(location @arm_none_eabi//:objcopy)\" objcopy.exe && objcopy.exe -O binary $< $@",
        tools = ["@arm_none_eabi//:objcopy"],
        visibility = visibility,
        **kwargs
    )

def hex_out(name, src, visibility = None, **kwargs):
    """
    Runs objcopy to convert a source file (e.g., an ELF) into a hex binary.

    Args:
      name: The name of the output target. The output filename will be `name + ".hex"`.
      src: The label of the single source file to convert.
      visibility: The visibility of the generated rule.
      **kwargs: Additional arguments to pass to the underlying genrule.
    """
    native.genrule(
        name = name,
        srcs = [src],
        outs = [src + ".hex"],
        cmd = "$(execpath @arm_none_eabi//:objcopy) -O ihex $< $@",
        cmd_bat = "copy \"$(location @arm_none_eabi//:objcopy)\" objcopy.exe && objcopy.exe -O ihex $< $@",
        tools = ["@arm_none_eabi//:objcopy"],
        visibility = visibility,
        **kwargs
    )

MCU_FLAGS = [
    "-mcpu=cortex-m4",
    "-mthumb",
    "-mfpu=fpv4-sp-d16",
    "-mfloat-abi=hard",
]

def firmware_project_g4(name, linker_script, startup_script, enable_usb = False,
                            defines = [], extra_srcs = [], extra_deps = [],
                            usb_device_name = None, extra_includes = [],
                            enable_freertos = False, locations = [], **kwargs):
  """Creates a firmware project for the STM32G4 family of chips.

  Args:
      name (string): name of the project
      linker_script (path): the location of the linker script being used (.ld file)
      startup_script (path): the location of the startup script being used (.s file)
      enable_usb (bool, optional): Whether or not to use USB drivers. Defaults to False.
      defines (list, optional): defines to pass to the compiler. Defaults to [].
      extra_srcs (list, optional): extra sources to compile with. Defaults to [].
      extra_deps (list, optional): extra dependencies to compile with. Defaults to [].
      usb_device_name (_type_, optional): name you want the USB driver to have. Defaults to None.
      extra_includes (list, optional): extra include paths to compile with. Defaults to [].
      enable_freertos (bool, optional): Whether or not to use FreeRTOS. Defaults to False.
      locations (list, optional): A list of location identifiers (e.g., ["FR", "FL"]).
                                  For each location, a separate binary will be generated
                                  with a "BOARD_<location>" define. Defaults to [].
      **kwargs: extra args to pass to cc_binary.
  """

  # --- Base configuration that applies to all variants ---
  if(usb_device_name == None):
    usb_device_name = name

  final_extra_srcs = extra_srcs[:]
  final_extra_deps = extra_deps[:]
  final_defines = defines[:]

  if(enable_usb):
    final_extra_srcs.append("//drivers/stm32g4:usb_device_srcs")
    final_extra_deps.append("//drivers/stm32g4:usb_device_headers")
    final_defines.append('USB_DEVICE_NAME_TOKEN="ELC ' + usb_device_name + '"')

  if(enable_freertos):
    final_extra_srcs.append("//drivers/stm32g4:freertos_srcs")
    final_extra_deps.append("//drivers/stm32g4:freertos_headers")

  # --- Target generation logic ---
  release_srcs = []

  # If no locations are specified, run the original logic once.
  if not locations:
    locations_to_build = [None]
  else:
    locations_to_build = locations

  for location in locations_to_build:
    target_name = name
    project_name = name
    location_defines = []

    # If a location is specified, modify names and add the define
    if location:
      target_name = name + "_" + location
      project_name = name + "_" + location
      location_defines.append("BOARD_" + location)

    # Main cc_binary target for the elf file
    cc_binary(
      name = target_name + "_project",
      srcs = native.glob([
          "Core/Src/**/*.c",
          "Core/Inc/**/*.h",
      ], allow_empty = True)
      + [
          # Include the HAL for compilation
          "//drivers/stm32g4:hal_srcs",
      ] + final_extra_srcs,
      includes = [
          "Core/Inc",
      ] + extra_includes,
      deps = final_extra_deps + [
          "//drivers/stm32g4:stm32_headers",
      ],
      linkopts = MCU_FLAGS + [
          "-Wl,-Map=" + target_name + ".map,--cref", # Use unique map file
          "-Wl,--gc-sections",
          "-T $(location " + linker_script + ")",
          "$(location " + startup_script + ")",
          "-specs=nano.specs",
          "-lnosys",
          "-lc",
          "-lm"
      ],
      defines = final_defines + location_defines + ["USE_HAL_DRIVER"],
      additional_linker_inputs = [
          linker_script,
          startup_script,
      ],
      target_compatible_with = [
          "@platforms//cpu:arm",
          "@platforms//os:none",
      ],
      copts = MCU_FLAGS + [
          "-mthumb-interwork",
          "-ffunction-sections",
          "-fdata-sections",
          "-Og"
      ],
      visibility = ["//visibility:private"],
      features = ["generate_linkmap"],
      **kwargs
    )

    # Filegroup for the linkmap
    native.filegroup(
      name = target_name + ".out.map",
      srcs = [":" + target_name + "_project"],
      output_group = "linkmap",
    )

    # Platform transition to get the correct toolchain
    platform_transition_filegroup(
      name = target_name,
      srcs = [target_name + "_project"],
      target_platform = "//:arm_none_eabi",
      visibility = ["//visibility:public"],
    )

    # Generate .bin and .hex files
    firmware_outputs(
      name = target_name + "_out",
      src = target_name,
      project_name = project_name, # Pass the unique project name for file naming
    )

    release_srcs.append(target_name + "_out")

  native.filegroup (
    name = name + "_release",
    srcs = release_srcs,
    visibility = ["//visibility:public"],
  )