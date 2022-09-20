const std = @import("std");

const os = @cImport({
    @cInclude("dlfcn.h");
});

const engine_lib = @import("build_options").engine_lib;

const engineEntryProto = fn () void;

pub fn main() anyerror!void {
    std.log.info("Hello from driver executable", .{});

    const lib_wrapped = os.dlopen(engine_lib.ptr, os.RTLD_LAZY);
    std.debug.assert(lib_wrapped != null);

    const lib = lib_wrapped.?;

    const engine_entry_wrapped = os.dlsym(lib, "engine_entry");
    std.debug.assert(engine_entry_wrapped != null);

    const engine_entry_opaque = engine_entry_wrapped.?;
    const engine_entry = @ptrCast(engineEntryProto, engine_entry_opaque);
    engine_entry();
}
