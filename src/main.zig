const std = @import("std");
const x3_zig = @import("x3_zig");
const httpz = @import("httpz");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var server = try httpz.Server(void).init(allocator, .{ .port = 3000 }, {});
    defer {
        server.stop();
        server.deinit();
    }

    var router = try server.router(.{});
    router.get("/api/user/:id", get_user, .{});
    router.get("/health", x3_zig.health_endpoind_handler, .{});
    router.put("/:bucket_name", x3_zig.put_bucket, .{});
    router.put("/:bucket_name/:object_name", x3_zig.put_object, .{});

    try server.listen();
}

fn get_user(req: *httpz.Request, res: *httpz.Response) !void {
    res.status = 200;
    try res.json(.{ .id = req.param("id").?, .name = "Bob" }, .{});
}
