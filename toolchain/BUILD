load("@arm_none_eabi//toolchain:toolchain.bzl", "arm_none_eabi_toolchain")

MCU_FLAGS = [
    "-mcpu=cortex-m4",
    "-mthumb",
    "-mfpu=fpv4-sp-d16",
    "-mfloat-abi=hard",
]

filegroup (
    name = "stm32g474vetx_flash_script",
    srcs = [
        "stm32g474vetx_flash.ld",
    ],
    visibility = ["//visibility:public"],
)

filegroup (
    name = "stm32g474_startup",
    srcs = [
        "startup_stm32g474xx.s",
    ],
    visibility = ["//visibility:public"],
)

arm_none_eabi_toolchain(
    name = "stm_g4_toolchain",
    target_compatible_with = [
        "@platforms//cpu:arm",
        "@platforms//os:none",
    ],
    
    copts = MCU_FLAGS + [
        "-mthumb-interwork",
        "-ffunction-sections",
        "-fdata-sections",
    ],
    linkopts = MCU_FLAGS + [
        "-Wl,-Map=output.map",
        "-Wl,--gc-sections",
        "-Wl,--no-warn-rwx-segments",
    ],
)