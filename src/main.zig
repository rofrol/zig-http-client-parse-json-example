// https://discord.com/channels/605571803288698900/1023625686327492761
// https://discord.com/channels/605571803288698900/1123338869983686786
// Use parseStreaming https://discord.com/channels/605571803288698900/1123359158469664879/1123362769769599056
const std = @import("std");
const Data = struct {
    id: []const u8,
    text: []const u8,
    source: []const u8,
    source_url: []const u8,
    language: []const u8,
    permalink: []const u8,
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const uri = std.Uri.parse("https://uselessfacts.jsph.pl/api/v2/facts/random") catch unreachable;
    var client = std.http.Client{ .allocator = allocator };
    var headers = std.http.Headers{ .allocator = allocator };
    defer headers.deinit();

    try headers.append("accept", "*/*");
    var req = try client.request(.GET, uri, headers, .{});
    defer req.deinit();

    try req.start();
    try req.wait();

    // const body = try req.reader().readAllAlloc(allocator, 1024);
    // defer allocator.free(body);
    //
    // const stdout_file = std.io.getStdOut().writer();
    // var bw = std.io.bufferedWriter(stdout_file);
    // const stdout = bw.writer();
    //
    // try stdout.print("{s}", .{body});
    //
    // try bw.flush(); // don't forget to flush!

    const json_str = try req.reader().readAllAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(json_str);

    const data = try std.json.parseFromSlice(Data, allocator, json_str, .{});
    defer data.deinit();

    std.debug.print("fact! {s}\n", .{data.value.text});
}
