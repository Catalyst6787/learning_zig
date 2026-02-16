const std = @import("std");
const aoc = @import("aoc");
const stack_type = @import("stack.zig");

fn SolveStruct(Stack: type, max_depth: usize) type {
    return struct {
        max_depth: usize,
        buffer: [max_depth]Stack,
        moves_buff: [max_depth]stack_type.Moves,
        best_count: usize,
        best_moves: [max_depth]stack_type.Moves,
        best_moves_detph: usize,
    };
}

fn solve_rec(comptime Stack: type, comptime max_depth: usize, solve_st: *SolveStruct(Stack, max_depth), depth: usize, move: stack_type.Moves) usize {
    solve_st.buffer[depth].apply_move(move);
    // std.debug.print("solving at depht={d}, move={d}, stack:\n", .{ depth, move });
    // solve_st.buffer[depth].print();
    solve_st.moves_buff[depth] = move;

    const current_count: usize = solve_st.buffer[depth].count_inversions();
    // std.debug.print("current count: {d}\n", .{current_count});
    if (current_count < solve_st.best_count) {
        solve_st.best_count = current_count;
        solve_st.best_moves = solve_st.moves_buff;
        solve_st.best_moves_detph = depth;
        if (current_count == 0) return current_count;
    }
    if (depth == max_depth - 1) return current_count;

    for (std.enums.values(stack_type.Moves)) |next_move| {
        if (solve_st.buffer[depth].is_move_valid(next_move, move)) {
            std.mem.copyForwards(u8, &solve_st.buffer[depth + 1].arr, &solve_st.buffer[depth].arr);
            solve_st.buffer[depth + 1].separator = solve_st.buffer[depth].separator;
            if (solve_rec(Stack, max_depth, solve_st, depth + 1, next_move) == 0) return 0;
        }
    }
    return solve_st.best_count;
}

fn solve(comptime Stack: type, stack: Stack, comptime max_depth: usize) void {
    var solve_st: SolveStruct(Stack, max_depth) = undefined;
    var best: usize = undefined;
    for (std.enums.values(stack_type.Moves)) |move| {
        std.mem.copyForwards(u8, &solve_st.buffer[0].arr, &stack.arr);
        solve_st.buffer[0].separator = stack.separator;
        if (solve_st.buffer[0].is_move_valid(move, stack_type.Moves.sb)) { // hardcode swap b as first move to prevent colisions
            best = solve_rec(Stack, max_depth, &solve_st, 0, move);
        }
    }
    std.debug.print("best result: {d}, depth: {d}, moves:\n", .{ best, solve_st.best_moves_detph });
    for (0..solve_st.best_moves_detph) |i| {
        std.debug.print("{d}", .{solve_st.best_moves[i]});
    }
    std.debug.print("\n", .{});
}

pub fn main(init: std.process.Init) !void {
    // const gpa = init.gpa;
    // const args: []const []const u8 = try init.minimal.args.toSlice(gpa);
    // defer gpa.free(args);
    // var seed: u64 = undefined;
    // init.io.random(std.mem.asBytes(&seed));
    _ = init;
    var prng = std.Random.DefaultPrng.init(42421337);
    const rnd = prng.random();

    var random_stack = stack_type.Stack(u8, 7).initZeroed();
    random_stack.fill_normalized();
    random_stack.shuffle(&rnd);
    random_stack.print();
    solve(stack_type.Stack(u8, 7), random_stack, 9);
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
