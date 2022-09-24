// NOTE(maple): I am not sure if using an interface is the correct aproach here.
// The alternative is to include the platform of choice by function using a
// compile time switch.
//
// The main motivation of doing an interface is so the internal implementation
// does not have to have global state. Platform specific state can be wrapped in
// the interface and passed to function that need it, without the user having to
// really worry about it.
//
// NOTE(maple): this is currently untested/uncompiled.
//
// Platform Interface

pub const Platform = @This();

//------------------------------------------------------------------------------
// Interface data
ptr: *anyopaque,
vtable: *const VTable,
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Platform types

const Error = error{
    FileNotFound,
};

const Window = ?*anyopaque;
const FileHandle = ?*anyopaque;

// Filetime info - while this is a u64, the actual data contained
// is platform dependent. Do not rely on this data actually meaning anything.
const FileTime = u64;

const FileType = struct {
    unknown,
    file,
    directory,
};

const FileInfo = struct {
    size: u64,
    type: FileType,
    last_write: FileTime,
};

const WindowDims = struct {
    width: u32,
    height: u32,
};

//------------------------------------------------------------------------------

pub init_backend(allocator: Allocator) Platform {
    const builtin = @import("builtin");
    switch (builtin.target.os.tag) {
        .windows => {
            // TODO(maple): implement the Win32 path
            unreachable;
        },
        .linux => {
            const xcb = @import("platform_xcb.zig");
            var platform_backend = allocator.create(xcb.PlatformXcb) catch unreachable;
            platform_backend.init();
            return platform_backend.platform();
        },
        else => unreachable, // unsupported platform
    };
}

pub deinit_backend(platform: Platform) void {
    switch (builtin.target.os.tag) {
        .windows => {
            // TODO(maple): implement the Win32 path
            unreachable;
        },
        .linux => {
            const xcb = @import("platform_xcb.zig");
            
            const Ptr = @TypeOf(self.ptr);
            const ptr_info = @typeInfo(Ptr);

            assert(ptr_info == .Pointer); // Must be a pointer
            assert(ptr_info.Pointer.size == .One); // Must be a single-item pointer

            const self = @ptrCast(Ptr, @alignCast(alignment, ptr));
        },
        else => unreachable, // unsupported platform
    };
}

//------------------------------------------------------------------------------
// Prototype functions

//
// Windowing API
//

/// Creates a platform window with the given dimensions + Window name
const createWindowProto = fn (ptr: *anyopaque, width: u32, height: u32, window_name: []const u8) Window;
/// Destroys an existing window
const destroyWindowProto = fn (ptr: *anyopaque, window: Window) void;
/// Get the dimensions of the window
const getWindowDimsProto = fn (ptr: *anyopaque, window: Window) WindowDims;
/// Pump all client messges from a client window.
///
/// TODO(maple): Pass the input and event system to the function?
const pumpMessagesProto = fn (ptr: *anyopaque, window: Window) bool;

//
// File API
//

/// Write an entire buffer to a file
///
/// Error returns:
/// -
const writeEntireFileProto = fn (ptr: *anyopaque, filename: []const u8, size: u64, buffer: *anyopaque) Error!void;
/// Read a file into a buffer. There are a few ways to call this functions:
/// 1. C-like: If "buffer" is null, then the size of the file will be set. This way,
///    the function can be called twice: first to get the size to allocate a buffer
///    and a second time to read into the newly allocated buffer.
/// 2. Call get_fileinfo to pre-emptively get the file size. This is equivilant to
///    Step 1, but just calling a simpler function.
///
/// Error returns:
/// -
const readEntireFileProto = fn (ptr: *anyopaque, filename: []const u8, size: *u64, buffer: ?*anyopaque) Error!void;
/// Get file last write
///
/// Error returns:
/// -
const getFileLastWriteProto = fn (ptr: *anyopaque, filename: []const u8) Error!void;
/// Get the number of files in a directory
///
/// Error returns:
/// -
const getFileCountInDirectoryProto = fn (ptr: *anyopaque, directory: []const u8) Error!void;
/// Opens a directory, and returns a handle to the file. The handle is platform dependent.
/// This function is primarily used to collect all of the files in a directory.
///
/// Error returns:
/// -
const openDirProto = fn (ptr: *anyopaque, directory: []const u8) Error!FileHandle;
/// Reads the next file in the directory and returns the filename. This will skip the
/// directories "." and "..".
///
/// Error returns:
/// -
const readDirProto = fn (ptr: *anyopaque, file: FileHandle) Error![]const u8;

//
// Timing API
//

/// Retrieves the clock time
/// Win32:
/// Linux:
const getAbsoluteTimeProto = fn (ptr: *anyopaque) f32;
/// Sleeps the thread in MS. Usually used to meet the framerate.
const sleepProto = fn (ptr: *anyopaque, time_in_ms: u32) void;
/// Retrieves the refresh rate of the active monitor.
const getMonitorRefreshRateProto = fn (ptr: *anyopaque) f32;

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// VTable

pub const VTable = struct {
    createWindow: createWindowProto,
    destroyWindow: destroyWindowProto,
    getWindowDims: getWindowDimsProto,
    pumpMessages: pumpMessagesProto,
    writeEntireFile: writeEntireFileProto,
    readEntireFile: readEntireFileProto,
    getFileLastWrite: getFileLastWriteProto,
    getFileCountInDirectory: getFileCountInDirectoryProto,
    openDir: openDirProto,
    readDir: readDirProto,
    getAbsoluteTime: getAbsoluteTimeProto,
    sleep: sleepProto,
    getMonitorRefreshRate: getMonitorRefreshRateProto,
};

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Interface implementation

pub fn init(
    pointer: anytype,
    comptime createWindowFn: fn (ptr: *anyopaque, width: u32, height: u32, window_name: []const u8) Window,
    comptime destroyWindowFn: fn (ptr: *anyopaque, window: Window) void,
    comptime getWindowDimsFn: fn (ptr: *anyopaque, window: Window) WindowDims,
    comptime pumpMessagesFn: fn (ptr: *anyopaque, window: Window) bool,
    comptime writeEntireFileFn: fn (ptr: *anyopaque, filename: []const u8, size: u64, buffer: *anyopaque) Error!void,
    comptime readEntireFileFn: fn (ptr: *anyopaque, filename: []const u8, size: *u64, buffer: ?*anyopaque) Error!void,
    comptime getFileLastWriteFn: fn (ptr: *anyopaque, filename: []const u8) Error!void,
    comptime getFileCountInDirectoryFn: fn (ptr: *anyopaque, directory: []const u8) Error!void,
    comptime openDirFn: fn (ptr: *anyopaque, directory: []const u8) Error!FileHandle,
    comptime readDirFn: fn (ptr: *anyopaque, file: FileHandle) Error![]const u8,
    comptime getAbsoluteTimeFn: fn (ptr: *anyopaque) f32,
    comptime sleepFn: fn (ptr: *anyopaque, time_in_ms: u32) void,
    comptime getMonitorRefreshRateFn: fn (ptr: *anyopaque) f32,
) Platform {
    const Ptr = @TypeOf(pointer);
    const ptr_info = @typeInfo(Ptr);

    assert(ptr_info == .Pointer); // Must be a pointer
    assert(ptr_info.Pointer.size == .One); // Must be a single-item pointer

    const alignment = ptr_info.Pointer.alignment;

    const gen = struct {
        fn createWindowImpl(ptr: *anyopaque, width: u32, height: u32, window_name: []const u8) Window {
            const self = @ptrCast(Ptr, @alignCast(alignment, ptr));
            return @call(.{ .modifier = .always_inline }, createWindowFn, .{ self, width, height, window_name });
        }

        fn destroyWindowImpl(ptr: *anyopaque, window: Window) void {
            const self = @ptrCast(Ptr, @alignCast(alignment, ptr));
            return @call(.{ .modifier = .always_inline }, destroyWindowFn, .{ self, window });
        }

        fn getWindowDimsImpl(ptr: *anyopaque, window: Window) WindowDims {
            const self = @ptrCast(Ptr, @alignCast(alignment, ptr));
            return @call(.{ .modifier = .always_inline }, getWindowDimsFn, .{ self, window });
        }

        fn pumpMessagesImpl(ptr: *anyopaque, window: Window) bool {
            const self = @ptrCast(Ptr, @alignCast(alignment, ptr));
            return @call(.{ .modifier = .always_inline }, pumpMessagesFn, .{ self, window });
        }

        fn writeEntireFileImpl(ptr: *anyopaque, filename: []const u8, size: u64, buffer: *anyopaque) Error!void {
            const self = @ptrCast(Ptr, @alignCast(alignment, ptr));
            return @call(.{ .modifier = .always_inline }, writeEntireFileFn, .{ self, filename, size, buffer });
        }

        fn readEntireFileImpl(ptr: *anyopaque, filename: []const u8, size: *u64, buffer: ?*anyopaque) Error!void {
            const self = @ptrCast(Ptr, @alignCast(alignment, ptr));
            return @call(.{ .modifier = .always_inline }, readEntireFileFn, .{ self, filename, size, buffer });
        }

        fn getFileLastWriteImpl(ptr: *anyopaque, filename: []const u8) Error!void {
            const self = @ptrCast(Ptr, @alignCast(alignment, ptr));
            return @call(.{ .modifier = .always_inline }, readEntireFileFn, .{ self, filename });
        }

        fn getFileCountInDirectoryImpl(ptr: *anyopaque, directory: []const u8) Error!void {
            const self = @ptrCast(Ptr, @alignCast(alignment, ptr));
            return @call(.{ .modifier = .always_inline }, getFileCountInDirectoryFn, .{ self, directory });
        }

        fn openDirImpl(ptr: *anyopaque, directory: []const u8) Error!FileHandle {
            const self = @ptrCast(Ptr, @alignCast(alignment, ptr));
            return @call(.{ .modifier = .always_inline }, openDirFn, .{ self, directory });
        }

        fn readDirImpl(ptr: *anyopaque, file: FileHandle) Error![]const u8 {
            const self = @ptrCast(Ptr, @alignCast(alignment, ptr));
            return @call(.{ .modifier = .always_inline }, readDirFn, .{ self, file });
        }

        fn getAbsoluteTimeImpl(ptr: *anyopaque) f32 {
            const self = @ptrCast(Ptr, @alignCast(alignment, ptr));
            return @call(.{ .modifier = .always_inline }, getAbsoluteTimeFn, .{self});
        }

        fn sleepImpl(ptr: *anyopaque, time_in_ms: u32) void {
            const self = @ptrCast(Ptr, @alignCast(alignment, ptr));
            return @call(.{ .modifier = .always_inline }, sleepFn, .{ self, time_in_ms });
        }

        fn getMonitorRefreshRateImpl(ptr: *anyopaque) f32 {
            const self = @ptrCast(Ptr, @alignCast(alignment, ptr));
            return @call(.{ .modifier = .always_inline }, getMonitorRefreshRateFn, .{self});
        }

        const vtable = VTable{
            .createWindow = createWindowImpl,
            .destroyWindow = destroyWindowImpl,
            .getWindowDims = getWindowDimsImpl,
            .pumpMessages = pumpMessagesImpl,
            .writeEntireFile = writeEntireFileImpl,
            .readEntireFile = readEntireFileImpl,
            .getFileLastWrite = getFileLastWriteImpl,
            .getFileCountInDirectory = getFileCountInDirectoryImpl,
            .openDir = openDirImpl,
            .readDir = readDirImpl,
            .getAbsoluteTime = getAbsoluteTimeImpl,
            .getMonitorRefreshRate = getMonitorRefreshRateImpl,
        };
    };

    return .{
        .ptr = pointer,
        .vtable = &gen.vtable,
    };
}

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Platform Implementation Wrapper

pub fn createWindow(ptr: *anyopaque, width: u32, height: u32, window_name: []const u8) Window {
    return self.vtable.createWindow(self.ptr);
}

pub fn destroyWindow(ptr: *anyopaque, window: Window) void {
    return self.vtable.destroyWindow(self.ptr);
}

pub fn getWindowDims(ptr: *anyopaque, window: Window) WindowDims {
    return self.vtable.getWindowDims(self.ptr);
}

pub fn pumpMessages(ptr: *anyopaque, window: Window) bool {
    return self.vtable.pumpMessages(self.ptr);
}

pub fn writeEntireFile(ptr: *anyopaque, filename: []const u8, size: u64, buffer: *anyopaque) Error!void {
    return self.vtable.writeEntireFile(self.ptr);
}

pub fn readEntireFile(ptr: *anyopaque, filename: []const u8, size: *u64, buffer: ?*anyopaque) Error!void {
    return self.vtable.readEntireFile(self.ptr);
}

pub fn getFileLastWrite(ptr: *anyopaque, filename: []const u8) Error!void {
    return self.vtable.getFileLastWrite(self.ptr);
}

pub fn getFileCountInDirectory(ptr: *anyopaque, directory: []const u8) Error!void {
    return self.vtable.getFileCountInDirectory(self.ptr);
}

pub fn openDir(self: Module) Error!FileHandle {
    return self.vtable.openDir(self.ptr);
}

pub fn readDir(self: Module) Error![]const u8 {
    return self.vtable.readDir(self.ptr);
}

pub fn getAbsoluteTime(self: Module) f32 {
    return self.vtable.getAbsoluteTime(self.ptr);
}

pub fn sleep(self: Module) void {
    return self.vtable.sleep(self.ptr);
}

pub fn getMonitorRefreshRate(self: Module) f32 {
    return self.vtable.getMonitorRefreshRate(self.ptr);
}

//------------------------------------------------------------------------------
