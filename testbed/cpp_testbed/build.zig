const std = @import("std");

const Options = @import("../../build.zig").Options;

pub fn build(b: *std.build.Builder, options: Options) *std.build.LibExeObjStep {
    const lib = b.addSharedLibrary("cpp_testbed", null, b.version(0, 0, 1));

    const mode = b.standardReleaseOptions();

    lib.addCSourceFile(thisDir() ++ "/src/entry.cpp", &[_][]const u8{ "-std=c++17", "-Wl,--no-undefined", "-g" });

    lib.addIncludeDir(options.engine_path);

    lib.setBuildMode(mode);
    lib.linkSystemLibrary("c++");

    return lib;
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
