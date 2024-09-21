const std = @import("std");

fn hashTable(comptime KeyType: type, comptime ValueType: type) type {
    return struct {
        array_list: std.ArrayList(ValueType),
        key: ?*KeyType,
        value: ?*ValueType,

        const Self = @This();

        pub fn init(allocator: std.mem.Allocator) !*Self {
            const ht = try allocator.create(Self);
            ht.* = Self{
                .array_list = std.ArrayList(ValueType).init(allocator),
                .key = null,
                .value = null,
            };
            return ht;
        }

        fn deinit(self: *Self) void {
            self.array_list.deinit();
        }

        fn hashFn(self: *Self, key: KeyType) usize {
            var result: usize = 0;
            for (key) |c| {
                result = (result << 5) - result + @as(usize, c);
            }

            if (self.array_list.capacity == 0) {
                return 0;
            }

            return result % self.array_list.capacity;
        }

        fn insertAt(self: *Self, key: KeyType, value: ValueType) !void {
            const index = hashFn(self, key);
            try self.array_list.ensureTotalCapacity(index + 1);

            if (index >= self.array_list.items.len) {
                while (self.array_list.items.len <= index) {
                    try self.array_list.append(@as(ValueType, 0));
                }
            }

            self.array_list.items[index] = value;
        }

        fn find(self: *Self, key: KeyType) ValueType {
            const index = hashFn(self, key);
            return self.array_list.items[index];
        }

        fn remove(self: *Self, key: KeyType) ValueType {
            const index = hashFn(self, key);
            return self.array_list.swapRemove(index);
        }

        fn getSize(self: *Self) usize {
            return self.array_list.items.len;
        }
    };
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const hashtable_type = hashTable([]const u8, i32);

    const hashtable = try hashtable_type.init(allocator);
    defer hashtable.deinit();

    std.debug.print("hashtable size: {d}\n", .{hashtable.getSize()});
    try hashtable.insertAt("ABC", 24);

    std.debug.print("hashtable size: {d}\n", .{hashtable.getSize()});
    try hashtable.insertAt("DEF", 16);

    std.debug.print("hashtable size: {d}\n", .{hashtable.getSize()});

    const foundItem = hashtable.find("DEF");
    std.debug.print("hashtable at DEF: {any}\n", .{foundItem});

    std.debug.print("hashtable size: {d}\n", .{hashtable.getSize()});

    const deletedItem = hashtable.remove("DEF");
    std.debug.print("removed: {any}\n", .{deletedItem});

    std.debug.print("hashtable size: {d}\n", .{hashtable.getSize()});
}
