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

fn Stack(comptime T: type, comptime len: T) type {
    return struct {
        len: T,
        separator: T,
        arr: [len]T,

        fn init_stack(separator: T, slice: []T) Stack(T, len) {
            var new_stack: Stack(T) = undefined;
            new_stack.separator = separator;
            new_stack.arr = slice;
            return new_stack;
        }
        fn get_zeroed() Stack(T, len) {
            var empty_stack: Stack(T, len) = undefined;
            empty_stack.separator = len;
            empty_stack.arr = [_]T{0} ** len;
            // for (0..len) |i| {
            //     empty_stack.arr[i] = 0;
            // }
            return empty_stack;
        }
        fn fill_normalized(self: *Stack(T, len)) void {
            var slice: [len]T = undefined;
            for (&slice, 0..) |*elem, i| {
                elem.* = @intCast(i);
            }
            self.arr = slice;
        }
        fn shuffle(self: *Stack(T, len), rnd: std.Random) void {
            std.Random.shuffle(rnd, T, &self.arr);
        }
        fn print(self: Stack(T, len)) void {
            std.debug.print("len: {d}, separator: {d}, arr:\n", .{ len, self.separator });
            print_slice(&self.arr);
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

    const stack_type = Stack(u8, 10);
    var random_stack = stack_type.get_zeroed();
    random_stack.print();
    random_stack.fill_normalized();
    random_stack.print();
    random_stack.shuffle(rnd);
    random_stack.print();

    // const my_stack = stack_type.get_stack(lenght, &random_slice);

    // std.debug.print("stack.slice:\n", .{});
    // print_slice(my_stack.slice);
    // std.debug.print("stack.separator: {}", .{my_stack.separator});

    std.debug.print("\n", .{});
}
