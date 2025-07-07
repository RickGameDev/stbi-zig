const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // const use_custom_alloc = b.option(bool, "custom-alloc", "Assign custom allocator for stbi to use") orelse false;

    const stb_dep = b.dependency("stb", .{
        .target = target,
        .optimize = optimize,
    });

    const lib_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const flags: []const []const u8 = if (optimize == .Debug) &.{ "-g", "-O0" } else &.{};

    lib_mod.addCSourceFiles(.{
        .files = &.{"src/stb_image.c"},
        .flags = flags,
    });

    // if (use_custom_alloc) {
    // lib_mod.addCMacro("PLUGINZ_STBI_CUSTOM_ALLOC", "1");
    // }

    lib_mod.addIncludePath(stb_dep.path("."));

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "stb",
        .root_module = lib_mod,
    });
    lib.installHeadersDirectory(stb_dep.path("."), "stb", .{});

    b.installArtifact(lib);

    const lib_unit_tests = b.addTest(.{
        .root_module = lib_mod,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
