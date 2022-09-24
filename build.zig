const builtin = @import("builtin");
const std = @import("std");

const driver = @import("driver/build.zig");
const engine_core = @import("engine/build.zig");
const testbed = @import("testbed/zig_testbed/build.zig");
const testbed_cpp = @import("testbed/cpp_testbed/build.zig");

//TODO(maple): move options to its own file
pub const Options = struct {
    engine_path: []const u8,
    engine_lib: []const u8,
    testbed_lib: []const u8,
    testbed_cpp_lib: []const u8,
};

pub fn build(b: *std.build.Builder) void {

    //TODO(maple):
    // - Is there a way to get the output path w/out hardcoding?
    // - Account for other build platforms!
    const options = Options{
        .engine_path = thisDir() ++ "/engine/public",
        .engine_lib = "zig-out/lib/libengine_core.so.0",
        .testbed_lib = "zig-out/lib/libtestbed.so.0",
        .testbed_cpp_lib = thisDir() ++ "/zig-out/lib/libcpp_testbed.so.0.0.1",
    };

    installModule(b, driver.build(b, options), true, "driver");
    installModule(b, engine_core.build(b, options), false, "engine_core");
    installModule(b, testbed.build(b, options), false, "testbed");
    installModule(b, testbed_cpp.build(b, options), false, "testbed_cpp");
}

fn installModule(
    b: *std.build.Builder,
    exe: *std.build.LibExeObjStep,
    has_run_step: bool,
    comptime name: []const u8,
) void {
    // TODO: Problems with LTO on Windows.
    // NOTE(maple): I have idea what this means ^
    exe.want_lto = false;
    if (exe.build_mode == .ReleaseFast)
        exe.strip = true;

    comptime var desc_name: [256]u8 = [_]u8{0} ** 256;
    comptime _ = std.mem.replace(u8, name, "_", " ", desc_name[0..]);
    comptime var desc_size = std.mem.indexOf(u8, &desc_name, "\x00").?;

    const install = b.step(name, "Build '" ++ desc_name[0..desc_size] ++ "' demo");
    install.dependOn(&b.addInstallArtifact(exe).step);

    //TODO(maple): remove cmd step
    if (has_run_step) {
        const run_step = b.step(name ++ "-run", "Run '" ++ desc_name[0..desc_size] ++ "' demo");
        const run_cmd = exe.run();
        run_cmd.step.dependOn(install);
        run_step.dependOn(&run_cmd.step);
    }

    b.getInstallStep().dependOn(install);
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
