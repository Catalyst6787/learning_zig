const std = @import("std");
const aoc = @import("aoc");

fn Stack(comptime T: type, comptime len: usize) type {
    std.debug.assert(len > 1);
    return struct {
        separator: T,
        arr: [len]T,

        fn initZeroed() @This() {
            return .{
                .separator = @intCast(len),
                .arr = [_]T{0} ** len,
            };
        }
        fn fill_normalized(self: *@This()) void {
            for (&self.arr, 0..) |*elem, i| {
                elem.* = @intCast(i);
            }
        }
        fn shuffle(self: *@This(), rnd: *const std.Random) void {
            std.Random.shuffle(rnd.*, T, &self.arr);
        }
        fn print(self: *const @This()) void {
            std.debug.print("len: {d}, separator: {d}, a:\n", .{ len, self.separator });
            if (self.separator == 0) {
                std.debug.print("|empty|\n", .{});
            }
            if (self.separator > 0) {
                for (self.arr[0..self.separator]) |elem| {
                    std.debug.print("|{d}", .{elem});
                }
                std.debug.print("|\n", .{});
            }
            std.debug.print("b:\n", .{});
            if (self.separator == len) {
                std.debug.print("|empty|\n", .{});
                return;
            }
            var i: usize = len - 1;
            while (i >= self.separator) : (i -= 1) {
                std.debug.print("|{d}", .{self.arr[i]});
                if (i == 0) break;
            }
            std.debug.print("|\n", .{});
        }
        fn count_inversions(self: *const @This()) usize {
            var inversions: usize = 0;
            for (self.arr, 0..) |ai, i| {
                for (self.arr[i + 1 ..]) |aj| {
                    if (ai > aj) {
                        inversions += 1;
                    }
                }
            }
            return inversions;
        }
        fn push_a(self: *@This()) void {
            std.debug.assert(self.separator < len);
            self.separator += 1;
        }
        fn push_b(self: *@This()) void {
            std.debug.assert(self.separator > 0);
            self.separator -= 1;
        }
        fn swap_a(self: *@This()) void {
            std.debug.assert(self.separator > 1);
            std.mem.swap(T, &self.arr[self.separator - 1], &self.arr[self.separator - 2]);
        }
        fn swap_b(self: *@This()) void {
            std.debug.assert(len - self.separator > 1);
            std.mem.swap(T, &self.arr[self.separator], &self.arr[self.separator + 1]);
        }
        fn swap_s(self: *@This()) void {
            self.swap_a();
            self.swap_b();
        }
        fn rotate_a(self: *@This()) void {
            std.debug.assert(self.separator > 1);
            const tmp = self.arr[self.separator - 1];
            var i: T = self.separator - 1;
            while (i > 0) : (i -= 1) {
                self.arr[i] = self.arr[i - 1];
            }
            self.arr[0] = tmp;
        }
        fn rotate_b(self: *@This()) void {
            std.debug.assert(len - self.separator > 1);
            const tmp = self.arr[self.separator];
            for (self.separator..len - 1) |i| {
                self.arr[i] = self.arr[i + 1];
            }
            self.arr[len - 1] = tmp;
        }
        fn rotate_r(self: *@This()) void {
            self.rotate_a();
            self.rotate_b();
        }
        fn rev_rotate_a(self: *@This()) void {
            std.debug.assert(self.separator > 1);
            const tmp = self.arr[0];
            for (0..(self.separator - 1)) |i| {
                self.arr[i] = self.arr[i + 1];
            }
            self.arr[self.separator - 1] = tmp;
        }
        fn rev_rotate_b(self: *@This()) void {
            std.debug.assert(len - self.separator > 1);
            const tmp = self.arr[len - 1];
            var i = len - 1;
            while (i > self.separator) : (i -= 1) {
                self.arr[i] = self.arr[i - 1];
            }
            self.arr[self.separator] = tmp;
        }
    };
}

pub fn main(init: std.process.Init) !void {
    // const gpa = init.gpa;
    // const args: []const []const u8 = try init.minimal.args.toSlice(gpa);
    // defer gpa.free(args);
    var seed: u64 = undefined;
    init.io.random(std.mem.asBytes(&seed));
    var prng = std.Random.DefaultPrng.init(seed);
    const rnd = prng.random();

    var random_stack = Stack(u8, 10).initZeroed();
    random_stack.fill_normalized();
    random_stack.shuffle(&rnd);
    random_stack.print();
}

test "test push" {
    var stack = Stack(u8, 10).initZeroed();
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
        var stack = Stack(u8, 2).initZeroed();
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
        var stack = Stack(u8, 10).initZeroed();
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
        var stack = Stack(u8, 2).initZeroed();
        stack.fill_normalized();
        stack.rotate_a();
        try std.testing.expectEqual(stack.arr[0], 1);
        try std.testing.expectEqual(stack.arr[1], 0);
    }
    {
        var stack = Stack(u8, 5).initZeroed();
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
        var stack = Stack(u8, 5).initZeroed();
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
        var stack = Stack(u8, 2).initZeroed();
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
        var stack = Stack(u8, 4).initZeroed();
        stack.fill_normalized();
        stack.rev_rotate_a();
        try std.testing.expectEqual(stack.arr[0], 1);
        try std.testing.expectEqual(stack.arr[1], 2);
        try std.testing.expectEqual(stack.arr[2], 3);
        try std.testing.expectEqual(stack.arr[3], 0);
    }
    {
        var stack = Stack(u8, 2).initZeroed();
        stack.fill_normalized();
        stack.rev_rotate_a();
        try std.testing.expectEqual(stack.arr[0], 1);
        try std.testing.expectEqual(stack.arr[1], 0);
    }
    {
        var stack = Stack(u8, 4).initZeroed();
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
        var stack = Stack(u8, 2).initZeroed();
        stack.fill_normalized();
        stack.push_b();
        stack.push_b();
        stack.rev_rotate_b();
        try std.testing.expectEqual(stack.arr[0], 1);
        try std.testing.expectEqual(stack.arr[1], 0);
    }
}

test "test inversion count" {
    var stack = Stack(u8, 4).initZeroed();
    stack.fill_normalized();
    try std.testing.expectEqual(stack.count_inversions(), 0);
    stack.arr[0] = 9;
    stack.arr[1] = 5;
    stack.arr[2] = 7;
    stack.arr[3] = 6;
    try std.testing.expectEqual(stack.count_inversions(), 4);
}

test "inversion count: reverse sorted" {
    var stack = Stack(u8, 5).initZeroed();
    stack.arr = [_]u8{ 5, 4, 3, 2, 1 };
    try std.testing.expectEqual(@as(usize, 10), stack.count_inversions());
}
