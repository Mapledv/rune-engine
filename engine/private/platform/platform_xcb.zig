// Platform Implementation for XCB

pub const PlatformXcb = struct {
    const Self = @This();

    a: i32,

    pub fn init(self: *Self) void {
        _ = self;
    }

    pub fn deinit(self: *Self) void {
        _ = self;
    }

    pub fn platform(self: *Self) Platform {
        //TODO(maple)
        return undefined;
    }
};
