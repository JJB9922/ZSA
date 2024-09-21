const std = @import("std");

fn Queue(comptime T: type) type {
    return struct {
        pub const Frame = struct {
            data: T,
            next: ?*Frame,
            prev: ?*Frame,
        };

        head: ?*Frame,
        tail: ?*Frame,
        size: usize,

        const Self = @This();

        fn enqueue(self: *Self, data: T, allocator: *const std.mem.Allocator) !void {
            const new_tail = try allocator.create(Frame);
            if (self.tail == null) {
                new_tail.* = Frame{
                    .data = data,
                    .next = null,
                    .prev = null,
                };

                self.tail = new_tail;
                self.head = new_tail;
            } else {
                new_tail.* = Frame{
                    .data = data,
                    .next = self.tail,
                    .prev = null,
                };

                self.head.?.prev = new_tail;
                self.tail = new_tail;
            }

            self.size += 1;
            std.debug.print("Enqueued {d}\n", .{data});
        }

        fn dequeue(self: *Self, allocator: *const std.mem.Allocator) error{ UnexpectedErr, UnderflowError }!T {
            if (self.head == null) return error.UnderflowError;
            const ret = self.head orelse return error.UnexpectedErr;
            const data = ret.data;
            self.size -= 1;

            if (self.tail != self.head) {
                self.head = self.head.?.prev;
            }

            allocator.destroy(ret);
            return data;
        }
    };
}

pub fn main() !void {
    const queue_i32 = Queue(i32);

    var queue = queue_i32{
        .size = 0,
        .head = null,
        .tail = null,
    };

    const allocator = std.heap.page_allocator;

    queue.enqueue(20, &allocator) catch |err| return err;
    std.debug.print("queue size: {d}\n", .{queue.size});

    std.debug.print("dequeued value: {any}\n", .{queue.dequeue(&allocator)});
    std.debug.print("queue size: {d}\n", .{queue.size});

    queue.enqueue(10, &allocator) catch |err| return err;
    std.debug.print("queue size: {d}\n", .{queue.size});

    queue.enqueue(50, &allocator) catch |err| return err;
    std.debug.print("queue size: {d}\n", .{queue.size});

    std.debug.print("dequeued value: {any}\n", .{queue.dequeue(&allocator)});
    std.debug.print("queue size: {d}\n", .{queue.size});

    std.debug.print("dequeued value: {any}\n", .{queue.dequeue(&allocator)});
    std.debug.print("queue size: {d}\n", .{queue.size});
}
