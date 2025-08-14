load("@rules_cc//cc:defs.bzl", "cc_library")

filegroup(
    name = "hal_srcs",
    srcs = glob([
        "STM32G4xx_HAL_Driver/Src/**/*.c",
    ],         
    exclude = [
            # don't export templates (firmware provides its own)
            "STM32G4xx_HAL_Driver/Src/*template.c",
        ],),
    visibility = ["//visibility:public"],
)

# Makes the HAL available to consumers, the include paths will automatically
# be passed to the compiler
cc_library(
    name = "stm32_headers",
    hdrs = glob([
        "STM32G4xx_HAL_Driver/Inc/**/*.h",
        "STM32G4xx_HAL_Driver/Inc/Legacy/**/*.h",
        "CMSIS/Device/ST/STM32G4xx/Include/**/*.h",
        "CMSIS/Include/**/*.h",
    ]),

    includes = [
        "STM32G4xx_HAL_Driver/Inc",
        "STM32G4xx_HAL_Driver/Inc/Legacy",
        "CMSIS/Device/ST/STM32G4xx/Include",
        "CMSIS/Include",
    ],
    visibility = ["//visibility:public"],
)
