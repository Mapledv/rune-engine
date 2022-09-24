const std = @import("std");

const Options = @import("../build.zig").Options;

pub fn build(b: *std.build.Builder, options: Options) *std.build.LibExeObjStep {
    _ = options;

    const exe = b.addExecutable("RuneEngine", thisDir() ++ "/src/driver.zig");

    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    exe.setTarget(target);
    exe.setBuildMode(mode);

    const exe_options = b.addOptions();
    exe.addOptions("build_options", exe_options);
    exe_options.addOption([]const u8, "engine_lib", options.engine_lib);

    exe.linkSystemLibrary("c");

    return exe;
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
