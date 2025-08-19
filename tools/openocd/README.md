# OpenOCD Toolchain

This package exposes an OpenOCD toolchain for programming and debugging ARM microcontrollers via
STLink.

This package is added to the `MODULE.bazel` file as a repo, so you can simply use it in your
`BUILD` files with `@openocd//:openocd`. This works on both Windows and macOS/Linux.

However, there is a flashing script (`flash.py`) that is included in this package.
You can use this script to make sure OpenOCD works fine cross-platform, as it uses Bazel's
Python interpreter as well. The setup for that looks something like this:

```bazel
py_binary(
    name = "openocd",
    srcs = ["//tools/openocd:openocd_flashing_script"],
    main = "flash.py",
    data = [
        ":" + target_name + ".elf",
        "@openocd//:openocd",
        "//tools/openocd:g4_flashing_cfg", # choose your openocd config if it's different
    ],

    args = [
    "$(rlocationpath @openocd//:openocd)",
    "$(rlocationpath :" + target_name + ".elf" + ")", # change this to your output target file
    "$(rlocationpath //tools/openocd:g4_flashing_cfg)",
    ],

    deps = [
    "@rules_python//python/runfiles"
    ],

    tags=["local"] # to prevent caching
)
```
