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
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();

    const endpoint = "https://uselessfacts.jsph.pl/api/v2/facts/random";
    const uri = try std.Uri.parse(endpoint);

    const headers = std.http.Client.Request.Headers{
        .content_type = std.http.Client.Request.Headers.Value{
            .override = "application/json",
        },
    };

    const server_header_buffer: []u8 = try allocator.alloc(u8, 8 * 1024 * 4);

    var req = try client.open(.GET, uri, std.http.Client.RequestOptions{
        .server_header_buffer = server_header_buffer,
        .headers = headers,
    });
    defer req.deinit();

    try req.send(.{});
    try req.wait();

    const json_str = try req.reader().readAllAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(json_str);

    const data = try std.json.parseFromSlice(Data, allocator, json_str, .{});
    defer data.deinit();

    std.debug.print("fact! {s}\n", .{data.value.text});
}
