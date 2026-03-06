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
            var biggest = get_len_a(self);
            if (get_len_b(self) > biggest) {
                biggest = get_len_b(self);
            }

            std.debug.print("len: {d}, separator: {d}\n", .{ len, self.separator });

            for (0..biggest) |index| {
                const elem_a = get_elem_from_a(self, index);
                const elem_b = get_elem_from_b(self, index);

                std.debug.print("|", .{});
                if (elem_a != null) {
                    std.debug.print("{d: >4}", .{elem_a.?});
                } else {
                    std.debug.print("{s: >4}", .{" "});
                }

                std.debug.print("| |", .{});

                if (elem_b != null) {
                    std.debug.print("{d: >4}|", .{elem_b.?});
                } else {
                    std.debug.print("{s: >4}|", .{" "});
                }

                std.debug.print("\n", .{});
            }
        }
        pub fn get_len_a(self: *const @This()) usize {
            return self.separator;
        }
        pub fn get_len_b(self: *const @This()) usize {
            return len - self.separator;
        }
        pub fn print_raw_reverse(self: *const @This()) void {
            std.debug.print("len: {d}, separator: {d}\n", .{ len, self.separator });
            for (self.arr[0..len]) |elem| {
                std.debug.print("{d} ", .{elem});
            }
            std.debug.print("\n", .{});
        }
        pub fn print_raw_order(self: *const @This()) void {
            std.debug.print("len: {d}, separator: {d}\n", .{ len, self.separator });
            var index: usize = len - 1;
            while (index >= 0) {
                std.debug.print("{d} ", .{self.arr[index]});
                if (index > 0) {
                    index -= 1;
                } else {
                    break;
                }
            }
            std.debug.print("\n", .{});
        }
        pub fn get_elem_from_a(self: *const @This(), index: usize) ?T {
            if (index >= self.separator)
                return null;
            std.debug.assert(self.separator - index - 1 >= 0);
            return self.arr[self.separator - index - 1];
        }
        pub fn get_elem_from_b(self: *const @This(), index: usize) ?T {
            if (self.separator + index >= len) {
                return null;
            }
            return self.arr[self.separator + index];
        }
        pub fn count_inversions(self: *const @This()) usize {
            var inversions: usize = 0;
            for (self.arr, 0..) |ai, i| {
                for (self.arr[i + 1 ..]) |aj| {
                    if (ai < aj) {
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
        pub fn is_move_valid(self: *@This(), move: Moves, previous: Moves) bool {
            if ((self.separator < 2 or (len - self.separator) < 2) and (move == Moves.rr or move == Moves.rrr or move == Moves.ss)) return false;
            if (self.separator < 2 and (move == Moves.pb or move == Moves.ra or move == Moves.rra or move == Moves.sa)) return false;
            if ((len - self.separator) < 2 and (move == Moves.pa or move == Moves.rb or move == Moves.rrb or move == Moves.sb)) return false;
            switch (move) {
                .pa => if (previous == Moves.pb) return false,
                .pb => if (previous == Moves.pa) return false,
                .sa => if (previous == Moves.sa or move == Moves.ss) return false,
                .sb => if (previous == Moves.sb or move == Moves.ss) return false,
                .ss => if (previous == Moves.ss or move == Moves.sa or move == Moves.sb) return false,
                .ra => if (previous == Moves.rra or move == Moves.rrr) return false,
                .rb => if (previous == Moves.rrb or move == Moves.rrr) return false,
                .rr => if (previous == Moves.rrr or move == Moves.rra or move == Moves.rrb) return false,
                .rra => if (previous == Moves.ra or move == Moves.rr) return false,
                .rrb => if (previous == Moves.rb or move == Moves.rr) return false,
                .rrr => if (previous == Moves.rr or move == Moves.ra or move == Moves.rb) return false,
            }
            return true;
        }
    };
}
