const std = @import("std");
const Allocator = std.mem.Allocator;

const engine_core = @import("private/core/engine_module.zig");

//------------------------------------------------------------------------
// Global data - should this be wrapped in the engine type and we return
// that to the caller to engine_entry?

var g_heap_gpa = std.heap.GeneralPurposeAllocator(.{}){};
var g_heap_allocator: Allocator = undefined;

var g_engine: ?*engine_core.Engine = null;
//------------------------------------------------------------------------

export fn engine_entry() bool {
    std.log.info("Hello from engine module", .{});

    g_heap_allocator = g_heap_gpa.allocator();

    //The engine should not be initialized right now, but I guess check just in case
    if (g_engine == null) {
        if (g_heap_allocator.create(engine_core.Engine)) |eng| {
            g_engine = eng;
        } else |_| {
            return false;
        }

        // This dereferince syntax is weird...is this the correct way to do this?
        const engine_info = engine_core.EngineInfo{
            .global_memory = g_heap_allocator,
        };

        g_engine.?.* = engine_core.Engine.init(engine_info);
    }

    return true;
}

export fn engine_run() void {
    if (g_engine) |engine| {
        engine.run();
    }
}

export fn engine_deinit() void {
    if (g_engine) |engine| {
        engine.deinit();
        g_heap_allocator.destroy(engine);

        g_engine = null;
    }

    _ = g_heap_gpa.deinit();
}
