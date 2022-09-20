const std = @import("std");

const os = @cImport({
    @cInclude("dlfcn.h");
});

const testbed_lib = @import("build_options").testbed_lib;

const testbedEntryProto = fn () void;

export fn engine_entry() void {
    std.log.info("Hello from engine module", .{});

    const lib_wrapped = os.dlopen(testbed_lib.ptr, os.RTLD_LAZY);
    std.debug.assert(lib_wrapped != null);

    const lib = lib_wrapped.?;

    const testbed_entry_wrapped = os.dlsym(lib, "testbed_entry");
    std.debug.assert(testbed_entry_wrapped != null);

    const testbed_entry_opaque = testbed_entry_wrapped.?;
    const testbed_entry = @ptrCast(testbedEntryProto, testbed_entry_opaque);
    testbed_entry();
}
