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
        separator: T,
        arr: [len]T,

        fn initZeroed() @This() {
            return .{
                .separator = len,
                .arr = [_]T{0} ** len,
            };
        }
        fn fill_normalized(self: *@This()) void {
            for (&self.arr, 0..) |*elem, i| {
                elem.* = @intCast(i);
            }
        }
        fn shuffle(self: *@This(), rnd: std.Random) void {
            std.Random.shuffle(rnd, T, &self.arr);
        }
        fn print(self: @This()) void {
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
    var random_stack = stack_type.initZeroed();
    random_stack.fill_normalized();
    random_stack.shuffle(rnd);
    random_stack.print();
}
