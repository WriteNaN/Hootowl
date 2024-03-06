const std = @import("std");
const webui = @import("webui");

const Allocator = std.mem.Allocator;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    const allocator = gpa.allocator();

    var win = webui.newWindow();
}