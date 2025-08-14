# LHRe 2025-2026 Monorepo

[![Postsubmit](https://github.com/LonghornRacingElectric/lhre-2026/actions/workflows/postsubmit.yml/badge.svg)](https://github.com/LonghornRacingElectric/lhre-2026/actions/workflows/postsubmit.yml)

This repository is a monorepo for the LHRe 2025-2026 codebase. It contains all of the code for the season,
including firmware, telemetry server code, documentation, tests, and build configurations.

The preferred build tool is Bazel. However, other build tools are supported depending on the project.
Firmware projects still support using `make` for compatibility and each `Makefile` is located in the root
of each firmware project directory.

Because Bazel automatically manages dependencies and toolchains, it is our preferred tool for
allowing quick code updates without needing to worry about other machines having the same build environment.

By default, Bazel will attempt to build all targets for the `arm_none_eabi` architecture.
This can be changed by specifying a different target platform or config in the build command. For example,
`--config=firmware` will force the `arm_none_eabi` toolchain to be used. Check the `.bazelrc` file to
see the other available configurations.

To build all targets: `bazel build //...` (will only build firmware by default)

To test all targets: `bazel test //...` (will only test firmware by default)

## Contributing

Note: Code cannot be pushed directly to the main branch.

We now require that the code being written be tested and approved by a reviewer before it can be merged.
This will allow us to make sure builds are not breaking due to untested code, and will enforce style
and code-quality checks. Create a new branch for each feature you work on, and then open a pull request
(PR) for your changes. Reviewers will not be assigned automatically, so make sure to request a review from
someone on the team.

Each PR will go through a review and presubmit, if the presubmit fails, you will not be able to merge the code.
If you need to make changes to your code after opening a PR, you can push new commits to the same branch and the PR will be updated automatically.
