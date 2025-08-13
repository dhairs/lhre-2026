# VCU Firmware and Model

VCU Firmware will live in the `VCU/Firmware` directory, while the model files will be located in the `VCU/Model` directory.

This directory can be recursively built by running `bazel build //VCU/...`. Additionally, the generated files will be placed in the `bazel-bin/VCU/` directory.

The firmware target is `//VCU/Firmware:vcu_firmware_2026`.

Model firmware target: `//VCU/Model:vcu_model_2026`.
