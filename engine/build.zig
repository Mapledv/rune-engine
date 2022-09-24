const std = @import("std");

const Options = @import("../build.zig").Options;

pub fn build(b: *std.build.Builder, options: Options) *std.build.LibExeObjStep {
    const lib = b.addSharedLibrary("engine_core", thisDir() ++ "/engine_entry.zig", b.version(0, 0, 1));

    const mode = b.standardReleaseOptions();

    lib.setBuildMode(mode);

    const lib_options = b.addOptions();
    lib.addOptions("build_options", lib_options);
    lib_options.addOption([]const u8, "engine_lib", options.engine_lib);
    lib_options.addOption([]const u8, "testbed_lib", options.testbed_lib);
    lib_options.addOption([]const u8, "testbed_cpp_lib", options.testbed_cpp_lib);

    lib.addIncludeDir(thisDir());
    lib.addIncludeDir(thisDir() ++ "/private");
    lib.addIncludeDir(thisDir() ++ "/public");

    lib.linkSystemLibrary("c");

    return lib;
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
