///
/// Prototyping a public engine interface, and what this might look like
/// when interacting with different modules.
///
const print_PFN = fn (i: i32, f: f32) callconv(.C) void;

pub const IEngine = struct {
    ptr: *anyopaque,
    print: print_PFN,
};
