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

pub fn get_rdn(io: std.Io) std.Random {
    var seed_as_u8: [8]u8 = undefined;
    io.random(&seed_as_u8);
    var prng: std.Random.DefaultPrng = .init(@bitCast(seed_as_u8));
    const rand = prng.random();
    return rand;
}

fn Stack(comptime T: type) type {
    return struct {
        separator: T,
        slice: []T,
    };
}

fn get_stack(comptime T: type, separator: T, slice: []T) Stack(T) {
    var new_stack: Stack(u8) = undefined;
    new_stack.separator = separator;
    new_stack.slice = slice;
    return new_stack;
}

pub fn main(init: std.process.Init) !void {
    const lenght = 10;

    const gpa = init.gpa;
    const args: []const []const u8 = try init.minimal.args.toSlice(gpa);
    defer gpa.free(args);

    var random_slice: [lenght]u8 = undefined;
    for (&random_slice, 0..) |*elem, i| {
        elem.* = @intCast(i);
    }
    const rnd = get_rdn(init.io);
    std.Random.shuffle(rnd, u8, &random_slice);

    const my_stack = get_stack(u8, lenght, &random_slice);
    std.debug.print("stack.slice:\n", .{});
    print_slice(my_stack.slice);
    std.debug.print("stack.separator: {}", .{my_stack.separator});

    std.debug.print("\n", .{});
}
