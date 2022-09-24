const std = @import("std");
const Allocator = std.mem.Allocator;

const Module = @import("module.zig");

const iengine = @import("../../public/engine_interface.zig");
const igame = @import("../../public/game_interface.zig");

//const Platform = @import("platform/platform.zig");

//TODO(maple): Should there be an "EngineModule", which acts
// as the interface to other modules?

pub const EngineInfo = struct {
    global_memory: Allocator,
};

//------------------------------------------------------------------------------

//TODO(maple): Call platform.load_library
const os = @cImport({
    @cInclude("dlfcn.h");
});

const testbed_lib = @import("build_options").testbed_cpp_lib;

fn interfacePrint(i: i32, f: f32) callconv(.C) void {
    std.log.info("Printing from engine interface: {} {}", .{ i, f });
}

pub const Engine = struct {
    const Self = @This();

    global_memory: Allocator,

    //platform: Platform,

    pub fn init(info: EngineInfo) Engine {
        // TODO(maple):
        // - Platform
        // - Platform Logger (Temp)
        // - Input System
        // - Event System

        std.log.info("Opening module {s}", .{testbed_lib});

        const lib_wrapped = os.dlopen(testbed_lib.ptr, os.RTLD_LAZY);
        if (lib_wrapped == null) {
            const err = os.dlerror();
            if (err) |error_string| {
                std.log.err("Error opening lib {s}: {s}", .{ testbed_lib, error_string });
            }
        }

        const lib = lib_wrapped.?;

        const testbed_entry_wrapped = os.dlsym(lib, "module_entry");
        std.debug.assert(testbed_entry_wrapped != null);

        const testbed_entry_opaque = testbed_entry_wrapped.?;

        const testbed_entry = @ptrCast(igame.gameEntry_PFN, testbed_entry_opaque);

        var engine = Engine{
            .global_memory = info.global_memory,
            //.platform = Platform.init_backend(info.global_memory),
        };

        //TODO(maple): the way this is setup, this pointer will not persist
        //outside of this function, which will, uh, crash things quickly
        var engine_interface = engine.interface();

        //std.log.info("BEFOREEE", .{});
        //engine_interface.print.*(0, 0.0);
        //std.log.info("AFTERRR", .{});

        const testbed: *igame.IGame = testbed_entry(&engine_interface);

        //std.debug.assert(testbed.init != null);
        //std.debug.assert(testbed.deinit != null);
        //std.debug.assert(testbed.update != null);

        std.log.info("Callback fn {s}", .{interfacePrint});

        testbed.init(testbed);
        testbed.update(testbed);

        return engine;
    }

    pub fn deinit(self: *Self) void {
        _ = self;
    }

    pub fn run(self: *Self) void {
        _ = self;
    }

    fn reload(self: *Self) void {
        _ = self;
    }

    fn getSelf(self: *Self) *Self {
        return self;
    }

    pub fn getModule(self: *Self) Module {
        return Module.init(
            self,
            reload,
            getSelf,
        );
    }

    fn interface(self: *Self) iengine.IEngine {
        return .{
            .ptr = self,
            .print = interfacePrint,
        };
    }
};
