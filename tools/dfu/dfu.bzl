# bzl/dfu.bzl
"""Module extension and repository rule for downloading dfu-util."""

# Configuration for the single dfu-util binaries archive.
# This archive contains pre-compiled binaries for multiple platforms.
# URL and checksum are for version 0.11.
DFU_UTIL_ARCHIVE_CONFIG = {
    "url": "https://downloads.sourceforge.net/project/dfu-util/dfu-util-0.11/dfu-util-0.11-binaries.tar.xz",
    "sha256": "36e33a7238b6889871a4f07a25529065600c606253456b3a0333344e9302e196",
    # The strip_prefix is the top-level directory inside the tarball, which we want to remove.
    # If the tarball extracts to ./dfu-util-0.11-binaries/*, we set this. If it extracts directly,
    # this should be an empty string. Let's assume for now it doesn't have a single root folder.
    "strip_prefix": "",
}

def _dfu_util_repo_impl(ctx):
    """
    This rule implementation downloads and extracts the dfu-util binaries archive.
    
    selects the correct binary for the host OS/architecture, and creates a BUILD
    file to expose it as a target.
    """
    # Determine the path to the binary inside the archive based on platform.
    arch = ctx.os.arch
    os_name = ctx.os.name

    binary_path_in_archive = ""
    binary_name = "dfu-util"

    if os_name == "linux":
        if arch == "x86_64":
            binary_path_in_archive = "linux-x86_64/dfu-util"
        elif arch == "aarch64":
            binary_path_in_archive = "linux-aarch64/dfu-util"
        elif arch == "arm":
            binary_path_in_archive = "linux-arm/dfu-util"
    elif os_name == "darwin":
        # The archive contains a single macOS binary, likely a universal one.
        binary_path_in_archive = "osx-10.12/dfu-util"
    elif os_name == "windows":
        binary_name = "dfu-util.exe"
        if arch == "x86_64":
            binary_path_in_archive = "win64-mingw/dfu-util.exe"
        elif arch == "x86":
            binary_path_in_archive = "win32-mingw/dfu-util.exe"

    if not binary_path_in_archive:
        fail("Unsupported platform for dfu-util: {}/{}".format(os_name, arch))

    # Download and extract the archive.
    ctx.download_and_extract(
        url = DFU_UTIL_ARCHIVE_CONFIG["url"],
        sha256 = DFU_UTIL_ARCHIVE_CONFIG["sha256"],
        strip_prefix = DFU_UTIL_ARCHIVE_CONFIG["strip_prefix"],
    )

    # Create a BUILD file inside the new repository (@dfu_util).
    # This makes the correct binary available as a consistent target name.
    # We use a filegroup to make the binary executable.
    ctx.file("BUILD.bazel", """
package(default_visibility = ["//visibility:public"])

# This filegroup makes the selected binary available and ensures it's executable.
filegroup(
    name = "dfu-util_bin",
    srcs = ["{binary_path}"],
    executable = True,
)

# We create an alias so the target name is consistent across all platforms.
alias(
    name = "dfu-util",
    actual = ":dfu-util_bin",
)
""".format(binary_path = binary_path_in_archive))

# Define the repository rule
_dfu_util_repository = repository_rule(
    implementation = _dfu_util_repo_impl,
)

# Define the module extension tag
_dfu_tool_tag = tag(
    attrs = {"name": attr.string(mandatory = True)},
)

def _dfu_extension_impl(ctx):
    """Implementation of the module extension."""
    for mod in ctx.modules:
        for tool in mod.tags.tool:
            _dfu_util_repository(name = tool.name)

# This is the public interface for our module extension.
dfu_extension = module_extension(
    implementation = _dfu_extension_impl,
    tag_classes = {"tool": _dfu_tool_tag},
)

lddkakfdp[as;]