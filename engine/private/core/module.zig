///
/// Prototyping the private module interface 
///
/// NOTE(maple): this is currently untested.
///
const std = @import("std");

pub const Module = @This();

//------------------------------------------------------------------------------
// Module data

// type erased pointer to the renderer implementation
ptr: *anyopaque,
vtable: *const VTable,
name: []const u8,
//TODO(maple): comptime computation of the name
name_hash: u64,
// TODO(maple): A list of objects that are "fetched" from the module

pub const Object = struct {
    ptr: *anyopaque,
    //TODO(maple): reload function pointer
};

//------------------------------------------------------------------------------

pub const VTable = struct {
    reload: reloadProto,
    getSelf: getSelfProto,
};

//TODO(maple):
// instead of returning T, can I have the function header
// set *anyopaque and the impl is @TypeOf(pointer)

//TODO(maple): any data that needs to get passed to reload?
const reloadProto = fn (ptr: *anyopaque) void;
// Returns a ptr to the underlying type.
const getSelfProto = fn (ptr: *anyopaque) *type;

pub fn init(
    pointer: anytype,
    comptime name: []const u8,
    comptime reloadFn: fn (ptr: @TypeOf(pointer)) void,
    comptime getSelfFn: fn (ptr: @TypeOf(pointer)) void,
) Module {
    const Ptr = @TypeOf(pointer);
    const ptr_info = @typeInfo(Ptr);

    std.debug.assert(ptr_info == .Pointer); // Must be a pointer
    std.debug.assert(ptr_info.Pointer.size == .One); // Must be a single-item pointer

    const alignment = ptr_info.Pointer.alignment;

    const gen = struct {
        fn reloadImpl(ptr: *anyopaque) void {
            const self = @ptrCast(Ptr, @alignCast(alignment, ptr));
            return @call(.{ .modifier = .always_inline }, reloadFn, .{self});
        }

        fn getSelfImpl(ptr: *anyopaque) *type {
            const self = @ptrCast(Ptr, @alignCast(alignment, ptr));
            return @call(.{ .modifier = .always_inline }, getSelfFn, .{self});
        }

        const vtable = VTable{
            .reload = reloadImpl,
            .getSelf = getSelfImpl,
        };
    };

    return .{
        .ptr = pointer,
        .vtable = &gen.vtable,
        .name = name,
    };
}

pub fn reload(self: Module) void {
    return self.vtable.reload(self.ptr);
}

pub fn getSelf(self: Module) *type {
    return self.vtable.getSelf(self.ptr);
}
