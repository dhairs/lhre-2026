platform(
    name = "arm_none_eabi",
    constraint_values = [
        "@platforms//cpu:arm",
        "@platforms//os:none",
    ],

    visibility = ["//visibility:public"]
)

filegroup (
    name = "release",
    srcs = [
        "//VCU/firmware:release",
        "//HDV/firmware:release",
    ]
)

config_setting(
    name = "windows",
    constraint_values = ["@platforms//os:windows"],
)