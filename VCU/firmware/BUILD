load("@rules_cc//cc:defs.bzl", "cc_binary")

filegroup(
    name = "linker_script",
    srcs = ["stm32g474vetx_flash.ld"],
)

filegroup(
    name = "startup_file",
    srcs = ["startup_stm32g474xx.s"],
)

cc_binary(
    name = "vcu_firmware_2026",
    srcs = glob(
        [
            "Core/Src/**/*.c",
            "Drivers/*HAL_Driver/**/*.c",
            "Middlewares/**/*.c",
            "USB_DEVICE/**/*.c",
            "Core/Inc/**/*.h",
            "Drivers/**/*.h",
            "Middlewares/**/*.h",
            "USB_DEVICE/**/*.h",
        ],

        allow_empty = True # allows empty globs, so the codebase can grow without refactoring
    ),

    includes = [
        "Core/Inc",
        "Drivers/STM32G4xx_HAL_Driver/Inc",
        "Drivers/STM32G4xx_HAL_Driver/Inc/Legacy",
        "Drivers/CMSIS/Device/ST/STM32G4xx/Include",
        "Drivers/CMSIS/Include",
        "USB_DEVICE/App",
        "USB_DEVICE/Target",
        "Middlewares/ST/STM32_USB_Device_Library/Core/Inc",
        "Middlewares/ST/STM32_USB_Device_Library/Class/CDC/Inc",
        "//longhorn-lib:longhorn_lib"
    ],

    # Compiler options
    copts = [
        "-mcpu=cortex-m4",
        "-mthumb",
        "-mthumb-interwork",
        "-ffunction-sections",
        "-fdata-sections",
    ],

    # Linker options
    linkopts = [
        "-T $(location :linker_script)",
        "$(location :startup_file)",
        "-Wl,-Map=output.map",
        "-Wl,--gc-sections",
        "-Wl,--no-warn-rwx-segments",
    ],

    # Defines for the C preprocessor
    defines = [
        "DEBUG",
        "USE_HAL_DRIVER",
        "STM32G474xx",
    ],

    additional_linker_inputs = [
        ":linker_script",
        ":startup_file",
    ],

    # Target platform constraints
    target_compatible_with = [
        "@platforms//cpu:arm",
        "@platforms//os:none",
    ],
)

genrule(
    name = "bin",
    srcs = [":vcu_firmware_2026"],
    outs = ["vcu_firmware_2026.bin"],
    cmd = "$(execpath @arm_none_eabi//:objcopy) -O binary $< $@",
    cmd_bat = "copy \"$(location @arm_none_eabi//:objcopy)\" objcopy.exe && objcopy.exe -O binary $< $@",
    tools = ["@arm_none_eabi//:objcopy"],
)

genrule(
    name = "hex",
    srcs = [":vcu_firmware_2026"],
    outs = ["vcu_firmware_2026.hex"],
    cmd = "$(execpath @arm_none_eabi//:objcopy) -O ihex $< $@",
    cmd_bat = "copy \"$(location @arm_none_eabi//:objcopy)\" objcopy.exe && objcopy.exe -O ihex $< $@",
    tools = ["@arm_none_eabi//:objcopy"],
)