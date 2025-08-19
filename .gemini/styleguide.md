# Style Guide

This document outlines the style guide for the monorepo. It includes conventions for code
formatting, naming, and documentation to ensure consistency and readability across the codebase.

## Code Formatting

- Use 2 spaces for indentation.
- Keep lines no longer than 100 characters.
- Ignore format styling in Bazel files.

## Naming Conventions

- Generally, use camelCase for variable and function names.
- In C, use snake_case for function names.
- Use PascalCase for class names.
- Use UPPER_SNAKE_CASE for constants.
- Ignore naming conventions in Bazel BUILD and starlark files (e.g. `BUILD.bazel` or `*.bzl`)

## Documentation

- Include examples in documentation where applicable.
- All top-level folders that define a module/library should have a README.md file.
  - It should define how to use the module/library and provide information on building the code.
  - If the module is built by Bazel (e.g. has a `BUILD` file), include the target and any special
    instructions for building the module with Bazel.
