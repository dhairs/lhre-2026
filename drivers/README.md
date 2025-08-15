# Drivers

Drivers for LHRe boards are defined here. This includes the STM32G4 HAL drivers,
ST's FreeRTOS implementation, and any other middleware that may be necessary for
boards.

To add this library to your Bazel build file, follow the VCU/firmware/BUILD.bazel file structure.
Make sure that CubeMX is generating the code related to the drivers, and you have enabled the
necessary components.
