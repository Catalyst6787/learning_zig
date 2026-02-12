const std = @import("std");
const aoc = @import("aoc");
const stack_type = @import("stack.zig");

pub fn main(init: std.process.Init) !void {
    // const gpa = init.gpa;
    // const args: []const []const u8 = try init.minimal.args.toSlice(gpa);
    // defer gpa.free(args);
    var seed: u64 = undefined;
    init.io.random(std.mem.asBytes(&seed));
    var prng = std.Random.DefaultPrng.init(seed);
    const rnd = prng.random();

    var random_stack = stack_type.Stack(u8, 10).initZeroed();
    random_stack.fill_normalized();
    random_stack.shuffle(&rnd);
    random_stack.print();
}

test "test push" {
    var stack = stack_type.Stack(u8, 10).initZeroed();
    stack.fill_normalized();
    stack.push_b();
    stack.push_b();
    try std.testing.expectEqual(stack.separator, stack.arr.len - 2);
    stack.push_a();
    try std.testing.expectEqual(stack.separator, stack.arr.len - 1);
    stack.push_a();
    try std.testing.expectEqual(stack.separator, stack.arr.len);
    for (0..9) |i| {
        _ = i;
        stack.push_b();
    }
    stack.push_b();
    try std.testing.expectEqual(stack.separator, 0);
}

test "test swap" {
    {
        var stack = stack_type.Stack(u8, 2).initZeroed();
        stack.fill_normalized();
        stack.swap_a();
        try std.testing.expectEqual(stack.arr[0], 1);
        try std.testing.expectEqual(stack.arr[1], 0);
        stack.push_b();
        stack.push_b();

        stack.swap_b();
        try std.testing.expectEqual(stack.arr[0], 0);
        try std.testing.expectEqual(stack.arr[1], 1);
    }
    {
        var stack = stack_type.Stack(u8, 10).initZeroed();
        stack.fill_normalized();
        stack.push_b();
        stack.push_b();

        try std.testing.expectEqual(stack.arr[stack.separator - 1], 7);
        stack.swap_a();
        try std.testing.expectEqual(stack.arr[stack.separator - 1], 6);
        try std.testing.expectEqual(stack.arr[stack.separator - 2], 7);

        stack.push_b();
        stack.push_b();
        stack.push_b();
        stack.push_b();
        try std.testing.expectEqual(stack.arr[stack.separator], 4);
        try std.testing.expectEqual(stack.arr[stack.separator + 1], 5);
        try std.testing.expectEqual(stack.arr[stack.separator + 2], 7);
        try std.testing.expectEqual(stack.arr[stack.separator + 3], 6);
    }
}

test "test rotate" {
    {
        var stack = stack_type.Stack(u8, 2).initZeroed();
        stack.fill_normalized();
        stack.rotate_a();
        try std.testing.expectEqual(stack.arr[0], 1);
        try std.testing.expectEqual(stack.arr[1], 0);
    }
    {
        var stack = stack_type.Stack(u8, 5).initZeroed();
        stack.fill_normalized();
        stack.rotate_a();
        stack.rotate_a();
        try std.testing.expectEqual(stack.arr[0], 3);
        try std.testing.expectEqual(stack.arr[1], 4);
        try std.testing.expectEqual(stack.arr[2], 0);
        try std.testing.expectEqual(stack.arr[3], 1);
        try std.testing.expectEqual(stack.arr[4], 2);
    }
    {
        var stack = stack_type.Stack(u8, 5).initZeroed();
        stack.fill_normalized();
        for (0..5) |i| {
            _ = i;
            stack.push_b();
        }
        try std.testing.expectEqual(stack.separator, 0);
        stack.rotate_b();
        try std.testing.expectEqual(stack.arr[4], 0);
        stack.rotate_b();
        try std.testing.expectEqual(stack.arr[3], 0);
    }
    {
        var stack = stack_type.Stack(u8, 2).initZeroed();
        stack.fill_normalized();
        stack.push_b();
        stack.push_b();
        stack.rotate_b();
        try std.testing.expectEqual(stack.arr[1], 0);
        try std.testing.expectEqual(stack.arr[0], 1);
        stack.rotate_b();
        try std.testing.expectEqual(stack.arr[1], 1);
        try std.testing.expectEqual(stack.arr[0], 0);
    }
}

test "test rev rotate" {
    {
        var stack = stack_type.Stack(u8, 4).initZeroed();
        stack.fill_normalized();
        stack.rev_rotate_a();
        try std.testing.expectEqual(stack.arr[0], 1);
        try std.testing.expectEqual(stack.arr[1], 2);
        try std.testing.expectEqual(stack.arr[2], 3);
        try std.testing.expectEqual(stack.arr[3], 0);
    }
    {
        var stack = stack_type.Stack(u8, 2).initZeroed();
        stack.fill_normalized();
        stack.rev_rotate_a();
        try std.testing.expectEqual(stack.arr[0], 1);
        try std.testing.expectEqual(stack.arr[1], 0);
    }
    {
        var stack = stack_type.Stack(u8, 4).initZeroed();
        stack.fill_normalized();
        stack.push_b();
        stack.push_b();
        stack.push_b();
        stack.push_b();
        stack.rev_rotate_b();
        try std.testing.expectEqual(stack.arr[0], 3);
        try std.testing.expectEqual(stack.arr[1], 0);
        try std.testing.expectEqual(stack.arr[2], 1);
        try std.testing.expectEqual(stack.arr[3], 2);
    }
    {
        var stack = stack_type.Stack(u8, 2).initZeroed();
        stack.fill_normalized();
        stack.push_b();
        stack.push_b();
        stack.rev_rotate_b();
        try std.testing.expectEqual(stack.arr[0], 1);
        try std.testing.expectEqual(stack.arr[1], 0);
    }
}

test "test inversion count" {
    var stack = stack_type.Stack(u8, 4).initZeroed();
    stack.fill_normalized();
    try std.testing.expectEqual(stack.count_inversions(), 0);
    stack.arr[0] = 9;
    stack.arr[1] = 5;
    stack.arr[2] = 7;
    stack.arr[3] = 6;
    try std.testing.expectEqual(stack.count_inversions(), 4);
}

test "inversion count: reverse sorted" {
    var stack = stack_type.Stack(u8, 5).initZeroed();
    stack.arr = [_]u8{ 5, 4, 3, 2, 1 };
    try std.testing.expectEqual(stack.count_inversions(), 10);
}
