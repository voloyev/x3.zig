//! By convention, root.zig is the root source file when making a library.
const std = @import("std");
const httpz = @import("httpz");
const fs = std.fs;

const ContentType = enum { json, txt, xml };

pub fn health_endpoind_handler(_: *httpz.Request, res: *httpz.Response) !void {
    res.status = 200;
    res.body = "OK";
}

pub fn put_bucket(req: *httpz.Request, res: *httpz.Response) !void {
    res.header("x-amz-bucket-arn", "some_arn");
    const cwd = fs.cwd();
    if (req.param("bucket_name")) |bucket_name| {
        if (cwd.makeDir(bucket_name)) |_| {
            res.status = 200;
            res.body = "OK";
        } else |err| switch (err) {
            error.PathAlreadyExists => {
                res.status = 400;
                res.body = "Already exists";
            },
            else => |other_err| return other_err,
        }
    } else {
        res.status = 400;
    }
}

pub fn put_object(req: *httpz.Request, res: *httpz.Response) !void {
    const bucket = try req.param("bucket_name");
    const bucket_dir = try fs.cwd().openDir(bucket);

    if (req.param("object_name")) |object_name| {
        const file = try bucket_dir.createFile(object_name);
        errdefer file.close();
        
        res.status = 200;
        res.body = "OK";
    } else {
        res.status = 400;
        res.body = "Can't create a bucket";
    }
}
