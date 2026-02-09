const std = @import("std");

const aoc = @import("aoc");

fn print_slice(slice: []const u8) void {
    if (slice.len == 0) return;
    std.debug.print("|", .{});
    for (slice) |elem| {
        std.debug.print("{d}|", .{elem});
    }
    std.debug.print("\n", .{});
}

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const args: []const []const u8 = try init.minimal.args.toSlice(gpa);
    defer gpa.free(args);

    for (1..args.len) |i| {
        std.debug.print("{s}\n", .{args[i]});
    }
    var random: [5]u8 = undefined;
    for (&random, 0..) |*elem, i| {
        elem.* = @intCast(i);
    }
    var seed_as_u8: [8]u8 = undefined;
    init.io.random(&seed_as_u8);
    var prng: std.Random.DefaultPrng = .init(@bitCast(seed_as_u8));
    const rand = prng.random();
    std.Random.shuffle(rand, u8, &random);
    std.debug.print("random:\n", .{});
    print_slice(&random);
    std.debug.print("\n", .{});
}

// test "simple test" {
//     const gpa = std.testing.allocator;
//     var list: std.ArrayList(i32) = .empty;

//     defer list.deinit(gpa); // Try commenting this out and see if zig detects the memory leak!
//     try list.append(gpa, 42);
//     try std.testing.expectEqual(@as(i32, 42), list.pop());
// }

// test "fuzz example" {
//     const Context = struct {
//         fn testOne(context: @This(), input: []const u8) anyerror!void {
//             _ = context;
//             // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
//             try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
//         }
//     };
//     try std.testing.fuzz(Context{}, Context.testOne, .{});
// }
