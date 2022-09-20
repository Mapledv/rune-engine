const std = @import("std");

const Options = @import("../build.zig").Options;

pub fn build(b: *std.build.Builder, options: Options) *std.build.LibExeObjStep {
    _ = options;

    const lib = b.addSharedLibrary("engine_core", thisDir() ++ "/src/engine_module.zig", b.version(0, 0, 1));

    //const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    //lib.setTarget(target);
    lib.setBuildMode(mode);

    const lib_options = b.addOptions();
    lib.addOptions("build_options", lib_options);
    lib_options.addOption([]const u8, "engine_lib", options.engine_lib);
    lib_options.addOption([]const u8, "testbed_lib", options.testbed_lib);

    lib.linkSystemLibrary("c");

    return lib;
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
