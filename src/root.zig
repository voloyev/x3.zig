//! By convention, root.zig is the root source file when making a library.
const std = @import("std");
const httpz = @import("httpz");
const fs = std.fs;
pub fn health_endpoind_handler(_: *httpz.Request, res: *httpz.Response) !void {
    res.status = 200;
    res.body = "OK";
}

pub fn put_bucket(req: *httpz.Request, res: *httpz.Response) !void {
    // const bucket_name = req.param("bucket_name").?;
    res.header("x-amz-bucket-arn", "some_arn");
    const cwd = fs.cwd();
    if (req.param("bucket_name")) |bucket_name| {
        try cwd.makeDir(bucket_name);

        res.status = 200;
        res.body = bucket_name;
    } else {
        res.status = 400;
    }
}
