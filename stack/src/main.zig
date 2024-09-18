const std = @import("std");

fn Stack(comptime T: type) type {
    return struct {
        pub const Frame = struct {
            data: T,
            next: ?*Frame,
        };

        head: ?*Frame,
        size: usize,

        const Self = @This();

        fn push(self: *Self, data: T, allocator: *const std.mem.Allocator) !void {
            const new_head = try allocator.create(Frame);
            new_head.* = Frame{
                .data = data,
                .next = self.head,
            };
            self.head = new_head;
            self.size += 1;
            std.debug.print("Pushed to stack\n", .{});
        }

        fn pop(self: *Self, allocator: *const std.mem.Allocator) error{ UnexpectedErr, UnderflowError }!T {
            if (self.head == null) return error.UnderflowError;
            const ret = self.head orelse return error.UnexpectedErr;
            const data = ret.data;
            self.head = self.head.?.next;
            self.size -= 1;

            allocator.destroy(ret);
            return data;
        }
    };
}

pub fn main() !void {
    const stack_i32 = Stack(i32);
    var stack = stack_i32{
        .size = 0,
        .head = null,
    };

    const allocator = std.heap.page_allocator;

    stack.push(20, &allocator) catch |err| return err;
    std.debug.print("stack size: {d}\n", .{stack.size});

    std.debug.print("popped value: {any}\n", .{stack.pop(&allocator)});
    std.debug.print("stack size: {d}\n", .{stack.size});

    stack.push(10, &allocator) catch |err| return err;
    std.debug.print("stack size: {d}\n", .{stack.size});

    stack.push(50, &allocator) catch |err| return err;
    std.debug.print("stack size: {d}\n", .{stack.size});

    std.debug.print("popped value: {any}\n", .{stack.pop(&allocator)});
    std.debug.print("stack size: {d}\n", .{stack.size});
}
