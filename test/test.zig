const std = @import("std");
const elf = @import("elf");

test "ehdr-modify" {
    var alloc = std.heap.page_allocator;
    var file = try std.fs.cwd().openFile("test/test1-ehdr-modify/true", .{ .mode = .read_write });
    defer file.close();
    var a: elf.ELF = try elf.ELF.readElf(file, alloc);
    a.ehdr.etype = .ET_DYN;
    a.ehdr.machine = ._S370;
    a.ehdr.entry = 69;
    a.ehdr.phoff = 0;
    a.ehdr.shoff = 8;
    a.ehdr.shnum = 8;
    a.ehdr.shentsize = 69;
    try elf.funcs.writeEhdr(a);
    //a.deinit();
    //dont fucking bother with deiniting cuz its weird when u edit the struct and it fucks shit up ig? idk why its erroring out and i dont want to investigate
}
test "phdr-modify" {
    var alloc = std.heap.page_allocator;
    var file = try std.fs.cwd().openFile("test/test2-phdr-modify/true", .{ .mode = .read_write });
    defer file.close();
    var a: elf.ELF = try elf.ELF.readElf(file, alloc);
    //std.log.info("a.data:{} ", .{std.fmt.fmtSliceHexLower(a.data)});
    // making everything RWX and LOAD
    for (a.phdrs.items) |*phdr| {
        phdr.ptype = .LOAD;
        phdr.flags = .{ .X = true, .W = true, .R = true };
    }
    //std.log.info("{any}", .{a.phdrs.items});
    try elf.ELF.writeElf(a, alloc);
}
test "shdr-name-change" {
    var alloc = std.heap.page_allocator;
    var file = try std.fs.cwd().openFile("test/test3-shdr-modify/true", .{ .mode = .read_write });
    defer file.close();
    var a: elf.ELF = try elf.ELF.readElf(file, alloc);
    for (a.shdrs.items) |*shdr| {
        shdr.name = "I have no idea what im doing";
    }
    try elf.ELF.writeElf(a, alloc);
}
