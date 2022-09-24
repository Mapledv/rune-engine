///
/// Prototyping a public game interface, and what this might look like
/// when interacting with different modules.
///
const IEngine = @import("engine_interface.zig").IEngine;

pub const gameEntry_PFN = fn (engine: *IEngine) *IGame;

const gameInit_PFN = fn (game: *IGame) callconv(.C) void;
const gameUpdate_PFN = fn (game: *IGame) callconv(.C) void;
const gameDeinit_PFN = fn (game: *IGame) callconv(.C) void;

pub const IGame = struct {
    ptr: *anyopaque,
    init: gameInit_PFN,
    deinit: gameDeinit_PFN,
    update: gameUpdate_PFN,
};
