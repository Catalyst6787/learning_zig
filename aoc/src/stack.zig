const std = @import("std");
const aoc = @import("aoc");
const main = @import("main.zig");

pub const Moves = enum {
    pa,
    pb,
    sa,
    sb,
    ss,
    ra,
    rb,
    rr,
    rra,
    rrb,
    rrr,
};

pub fn Stack(comptime T: type, comptime len: usize) type {
    std.debug.assert(len > 1);
    std.debug.assert(len <= std.math.maxInt(T));
    return struct {
        separator: T,
        arr: [len]T,

        pub fn initZeroed() @This() {
            return .{
                .separator = @intCast(len),
                .arr = [_]T{0} ** len,
            };
        }
        pub fn fill_normalized(self: *@This()) void {
            for (&self.arr, 0..) |*elem, i| {
                elem.* = @intCast(i);
            }
        }
        pub fn shuffle(self: *@This(), rnd: *const std.Random) void {
            std.Random.shuffle(rnd.*, T, &self.arr);
        }
        pub fn print(self: *const @This()) void {
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
        pub fn count_inversions(self: *const @This()) usize {
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
        pub fn push_a(self: *@This()) void {
            std.debug.assert(self.separator < len);
            self.separator += 1;
        }
        pub fn push_b(self: *@This()) void {
            std.debug.assert(self.separator > 0);
            self.separator -= 1;
        }
        pub fn swap_a(self: *@This()) void {
            std.debug.assert(self.separator > 1);
            std.mem.swap(T, &self.arr[self.separator - 1], &self.arr[self.separator - 2]);
        }
        pub fn swap_b(self: *@This()) void {
            std.debug.assert(len - self.separator > 1);
            std.mem.swap(T, &self.arr[self.separator], &self.arr[self.separator + 1]);
        }
        pub fn swap_s(self: *@This()) void {
            self.swap_a();
            self.swap_b();
        }
        pub fn rotate_a(self: *@This()) void {
            std.debug.assert(self.separator > 1);
            const tmp = self.arr[self.separator - 1];
            var i: T = self.separator - 1;
            while (i > 0) : (i -= 1) {
                self.arr[i] = self.arr[i - 1];
            }
            self.arr[0] = tmp;
        }
        pub fn rotate_b(self: *@This()) void {
            std.debug.assert(len - self.separator > 1);
            const tmp = self.arr[self.separator];
            for (self.separator..len - 1) |i| {
                self.arr[i] = self.arr[i + 1];
            }
            self.arr[len - 1] = tmp;
        }
        pub fn rotate_r(self: *@This()) void {
            self.rotate_a();
            self.rotate_b();
        }
        pub fn rev_rotate_a(self: *@This()) void {
            std.debug.assert(self.separator > 1);
            const tmp = self.arr[0];
            for (0..(self.separator - 1)) |i| {
                self.arr[i] = self.arr[i + 1];
            }
            self.arr[self.separator - 1] = tmp;
        }
        pub fn rev_rotate_b(self: *@This()) void {
            std.debug.assert(len - self.separator > 1);
            const tmp = self.arr[len - 1];
            var i = len - 1;
            while (i > self.separator) : (i -= 1) {
                self.arr[i] = self.arr[i - 1];
            }
            self.arr[self.separator] = tmp;
        }
        pub fn rev_rotate_r(self: *@This()) void {
            self.rev_rotate_a();
            self.rev_rotate_b();
        }
        pub fn apply_move(self: *@This(), move: Moves) void {
            switch (move) {
                .pa => self.push_a(),
                .pb => self.push_b(),
                .sa => self.swap_a(),
                .sb => self.swap_b(),
                .ss => self.swap_s(),
                .ra => self.rotate_a(),
                .rb => self.rotate_b(),
                .rr => self.rotate_r(),
                .rra => self.rev_rotate_a(),
                .rrb => self.rev_rotate_b(),
                .rrr => self.rev_rotate_r(),
            }
        }
    };
}
