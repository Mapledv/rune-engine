const std = @import("std");

const Options = @import("../../build.zig").Options;

pub fn build(b: *std.build.Builder, options: Options) *std.build.LibExeObjStep {
    _ = options;

    const lib = b.addSharedLibrary("testbed", thisDir() ++ "/src/testbed.zig", b.version(0, 0, 1));

    //const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    //lib.setTarget(target);
    lib.setBuildMode(mode);

    return lib;
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
