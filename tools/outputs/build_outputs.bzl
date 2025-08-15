"""Macro for creating binary and hex files using objcopy."""

load("@rules_cc//cc:cc_binary.bzl", "cc_binary")

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
  
def firmware_project(name, linker_script, startup_script, defines = [], extra_srcs = [], **kwargs):
  cc_binary(
    name = name,
    srcs = native.glob([
        "Core/Src/**/*.c",
        "Core/Inc/**/*.h",
    ], allow_empty = True)
    + [
        # Include the HAL for compilation
        "//drivers/stm32g4:hal_srcs",
    ] + extra_srcs,

    includes = [
        "Core/Inc",
    ],

    deps = [
        "//drivers/stm32g4:stm32_headers",
    ],

    # Linker options, also includes the reset handler startup file
    linkopts = MCU_FLAGS + [
        "-Wl,-Map=output.map",
        "-Wl,--gc-sections",
        "-Wl,--no-warn-rwx-segments",
        "-T $(location " + linker_script +")",
        "$(location " + startup_script +")",
    ],

    defines = defines,

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
    ],
  
    visibility = ["//visibility:public"],

    **kwargs
)