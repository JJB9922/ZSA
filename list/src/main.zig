const std = @import("std");

fn linkedList(comptime T: type) type {
    return struct {
        pub const Node = struct {
            prev: ?*Node,
            next: ?*Node,
            data: T,
        };

        first_node: ?*Node,
        last_node: ?*Node,

        const Self = @This();

        fn traverseForward(self: *Self) void {
            var node = self.first_node;
            while (node) |n| {
                std.debug.print("Node found: {d}\n", .{n.data});
                node = n.next;
            }
        }

        fn traverseBackward(self: *Self) void {
            var node = self.last_node;
            while (node) |n| {
                node = n.prev;
            }
        }

        fn insertAfter(self: *Self, node: *Node, newNode: *Node) void {
            newNode.prev = node;
            if (node.next) |next| {
                newNode.next = next;
                next.prev = newNode;
            } else {
                newNode.next = null;
                self.last_node = newNode;
            }

            node.next = newNode;
        }

        fn insertBefore(self: *Self, node: *Node, newNode: *Node) void {
            newNode.next = node;
            if (node.prev) |prev| {
                newNode.prev = prev;
                prev.next = newNode;
            } else {
                newNode.prev = null;
                self.first_node = newNode;
            }

            node.prev = newNode;
        }

        fn insertBeginning(self: *Self, newNode: *Node) void {
            if (self.first_node) |first| {
                self.insertBefore(first, newNode);
            } else {
                self.first_node = newNode;
                self.last_node = newNode;
                newNode.prev = null;
                newNode.next = null;
            }
        }

        fn insertEnd(self: *Self, newNode: *Node) void {
            if (self.last_node) |last| {
                self.insertAfter(last, newNode);
            } else self.insertBeginning(newNode);
        }

        fn remove(self: *Self, node: *Node) void {
            if (node.prev) |prev| {
                prev.next = node.next;
            } else {
                self.first_node = node.next;
            }

            if (node.next) |next| {
                next.prev = node.prev;
            } else {
                self.last_node = node.prev;
            }
        }
    };
}

pub fn main() !void {
    const linked_list_type = linkedList(i32);

    var linked_list = linked_list_type{
        .first_node = null,
        .last_node = null,
    };

    const allocator = std.heap.page_allocator;

    const initialNode = allocator.create(linked_list_type.Node) catch unreachable;

    initialNode.* = linked_list_type.Node{ .next = null, .prev = null, .data = 10 };

    const secondNode = allocator.create(linked_list_type.Node) catch unreachable;

    secondNode.* = linked_list_type.Node{ .next = null, .prev = null, .data = 15 };

    const thirdNode = allocator.create(linked_list_type.Node) catch unreachable;

    thirdNode.* = linked_list_type.Node{ .next = null, .prev = null, .data = 20 };

    linked_list.insertBeginning(initialNode);

    linked_list.insertBeginning(secondNode);

    linked_list.insertAfter(secondNode, thirdNode);

    linked_list.remove(secondNode);

    linked_list.traverseForward();
}
