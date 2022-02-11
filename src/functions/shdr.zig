const std = @import("std");
const ELF = @import("../elf.zig");
const phdr = @import("../data-structures/phdr.zig");
const shdr = @import("../data-structures/shdr.zig");
const ehdr10 = @import("../data-structures/ehdr.zig");

const shdrErrors = error{
    no_string_table,
    E_Shoff_shnum_shentsize_is_zero,
};

fn shdr_get_name_init(
    elf: ELF.ELF,
    alloc: std.mem.Allocator,
) ![]const u8 {
    if (!elf.is32) {
        var shdr1: std.elf.Elf64_Shdr = undefined;
        const buf = std.mem.asBytes(&shdr1);
        _ = try elf.file.preadAll(buf, elf.ehdr.shoff + @sizeOf(std.elf.Elf64_Shdr) * elf.ehdr.shstrndx);
        const buffer = try alloc.alloc(u8, shdr1.sh_size);
        _ = try elf.file.preadAll(buffer, shdr1.sh_offset);
        return buffer;
    } else {
        var shdr1: std.elf.Elf32_Shdr = undefined;
        const buf = std.mem.asBytes(&shdr1);
        _ = try elf.file.preadAll(buf, elf.ehdr.shoff + @sizeOf(std.elf.Elf32_Shdr) * elf.ehdr.shstrndx);
        const buffer = try alloc.alloc(u8, shdr1.sh_size);
        _ = try elf.file.preadAll(buffer, shdr1.sh_offset);
        return buffer;
    }
}
fn shdr_get_name(list: []const u8, offset: u64) []const u8 {
    if (offset < list.len) {
        const slice = list[offset..];
        const len = std.mem.indexOf(u8, slice, "\x00") orelse 0;
        return slice[0..len];
    } else {
        return "";
    }
}
pub fn shdrParse64(
    elf: ELF.ELF,
    alloc: std.mem.Allocator,
) !std.ArrayList(shdr.Shdr) {
    var list = std.ArrayList(shdr.Shdr).init(alloc);
    const stream = elf.file.reader();
    var section_strtab = try shdr_get_name_init(elf, alloc);
    //    defer alloc.free(section_strtab);
    //try std.io.getStdOut().writer().print("{x}\n", .{std.fmt.fmtSliceHexLower(section_strtab[0..])});
    var i: usize = 0;
    var shdr1: std.elf.Elf64_Shdr = undefined;
    while (i < elf.ehdr.shnum) : (i = i + 1) {
        const offset = elf.ehdr.shoff + (@sizeOf(@TypeOf(shdr1)) * i);
        try elf.file.seekableStream().seekTo(offset);

        try stream.readNoEof(std.mem.asBytes(&shdr1));
        var shdr2: shdr.Shdr = undefined;
        shdr2.name = shdr_get_name(section_strtab, shdr1.sh_name);
        shdr2.shtype = @intToEnum(shdr.sh_type, shdr1.sh_type);
        shdr2.offset = shdr1.sh_offset;
        shdr2.entsize = shdr1.sh_entsize;
        shdr2.addralign = shdr1.sh_addralign;
        shdr2.info = shdr1.sh_info;
        shdr2.link = shdr1.sh_link;
        shdr2.size = shdr1.sh_size;
        shdr2.addr = shdr1.sh_addr;
        shdr2.flags = @bitCast(shdr.sh_flags, @as(u64, shdr1.sh_flags));
        //var data = try alloc.alloc(u8, shdr.sh_size); //[shdr.sh_size]u8 = undefined;
        //try parse_source.seekableStream().seekTo(shdr.sh_offset);
        //_ = try parse_source.reader().read(data[0..]);
        try list.append(shdr2);
    }
    return list;
}

pub fn shdrParse32(
    elf: ELF.ELF,
    alloc: std.mem.Allocator,
) !std.ArrayList(shdr.Shdr) {
    var list = std.ArrayList(shdr.Shdr).init(alloc);
    const stream = elf.file.reader();
    var section_strtab = try shdr_get_name_init(elf, alloc);
    //   defer alloc.free(section_strtab);
    //try std.io.getStdOut().writer().print("{x}\n", .{std.fmt.fmtSliceHexLower(section_strtab[0..])});
    var i: usize = 0;
    var shdr1: std.elf.Elf32_Shdr = undefined;
    while (i < elf.ehdr.shnum) : (i = i + 1) {
        const offset = elf.ehdr.shoff + (@sizeOf(@TypeOf(shdr1)) * i);
        try elf.file.seekableStream().seekTo(offset);

        try stream.readNoEof(std.mem.asBytes(&shdr1));
        var shdr2: shdr.Shdr = undefined;
        shdr2.name = shdr_get_name(section_strtab, shdr1.sh_name);
        shdr2.shtype = @intToEnum(shdr.sh_type, shdr1.sh_type);
        shdr2.offset = shdr1.sh_offset;
        shdr2.entsize = shdr1.sh_entsize;
        shdr2.addralign = shdr1.sh_addralign;
        shdr2.info = shdr1.sh_info;
        shdr2.link = shdr1.sh_link;
        shdr2.size = shdr1.sh_size;
        shdr2.addr = shdr1.sh_addr;
        shdr2.flags = @bitCast(shdr.sh_flags, @intCast(u64, shdr1.sh_flags));
        //var data = try alloc.alloc(u8, shdr.sh_size); //[shdr.sh_size]u8 = undefined;
        //try parse_source.seekableStream().seekTo(shdr.sh_offset);
        //_ = try parse_source.reader().read(data[0..]);
        try list.append(shdr2);
    }
    return list;
}
pub fn shdrParse(elf: ELF.ELF, alloc: std.mem.Allocator) !std.ArrayList(shdr.Shdr) {
    if (elf.is32) {
        return @call(.{ .modifier = .always_inline }, shdrParse32, .{ elf, alloc });
    } else {
        return @call(.{ .modifier = .always_inline }, shdrParse64, .{ elf, alloc });
    }
}
// autoupdate string table at the end, use this last
fn updateStrtab(a: ELF.ELF, alloc: std.mem.Allocator) !?[]u8 {
    if (a.ehdr.shstrndx == 0) {
        return null;
    }
    var b = a.shdrs.items[a.ehdr.shstrndx];
    //    try parse_source.preadAll(buf, b.offset);
    var c = std.ArrayList(u8).init(alloc);
    try c.append('\x00');
    for (a.shdrs.items) |s| {
        try c.appendSlice(s.name);
        try c.append('\x00');
    }
    try a.file.seekableStream().seekTo(b.offset);
    try a.file.writer().writeAll(c.items);
    return c.items;
}
// its not packed but i named it like this for some reason sorry
fn shdrToPacked32(a: ELF.ELF, alloc: std.mem.Allocator) ![]std.elf.Elf32_Shdr {
    var ar = std.ArrayList(std.elf.Elf32_Shdr).init(alloc);
    defer ar.deinit();
    const section_names = try updateStrtab(a, alloc);
    var b: std.elf.Elf32_Shdr = undefined;
    for (a.shdrs.items) |s| {
        b.sh_type = @enumToInt(s.shtype);
        b.sh_info = @intCast(std.elf.Elf32_Word, s.info);
        b.sh_link = @intCast(std.elf.Elf32_Word, s.link);
        if (section_names != null) {
            b.sh_name = @truncate(u32, std.mem.indexOf(u8, section_names.?, s.name) orelse 0);
        }
        b.sh_size = @intCast(std.elf.Elf32_Word, s.size);
        b.sh_addr = @intCast(std.elf.Elf32_Addr, s.addr);
        b.sh_flags = @truncate(std.elf.Elf32_Word, @bitCast(u64, s.flags));
        b.sh_offset = @intCast(std.elf.Elf32_Off, s.offset);
        b.sh_entsize = @intCast(std.elf.Elf32_Word, s.entsize);
        b.sh_addralign = @intCast(std.elf.Elf32_Word, s.addralign);
        try ar.append(b);
    }
    return alloc.dupe(std.elf.Elf32_Shdr, ar.items);
}
fn shdrToPacked64(a: ELF.ELF, alloc: std.mem.Allocator) ![]std.elf.Elf64_Shdr {
    var ar = std.ArrayList(std.elf.Elf64_Shdr).init(alloc);
    defer ar.deinit();
    const section_names = try updateStrtab(a, alloc);
    var b: std.elf.Elf64_Shdr = undefined;
    for (a.shdrs.items) |s| {
        b.sh_type = @enumToInt(s.shtype);
        b.sh_info = @intCast(std.elf.Elf64_Word, s.info);
        b.sh_link = @intCast(std.elf.Elf64_Word, s.link);
        if (section_names != null) {
            b.sh_name = @truncate(std.elf.Elf64_Word, std.mem.indexOf(u8, section_names.?, s.name) orelse 0);
        }
        b.sh_size = @intCast(std.elf.Elf64_Xword, s.size);
        b.sh_addr = @intCast(std.elf.Elf64_Addr, s.addr);
        b.sh_flags = @bitCast(std.elf.Elf64_Xword, s.flags);
        b.sh_offset = @intCast(std.elf.Elf64_Off, s.offset);
        b.sh_entsize = @intCast(std.elf.Elf64_Xword, s.entsize);
        b.sh_addralign = @intCast(std.elf.Elf64_Xword, s.addralign);
        try ar.append(b);
    }
    return alloc.dupe(std.elf.Elf64_Shdr, ar.items);
}
pub fn writeShdrList(
    a: ELF.ELF,
    alloc: std.mem.Allocator,
) !void {
    if (a.ehdr.shoff == 0 or a.ehdr.shnum == 0 or a.ehdr.shentsize == 0) {
        return shdrErrors.E_Shoff_shnum_shentsize_is_zero;
    }
    var sec_names = try updateStrtab(a, alloc);
    if (sec_names != null) {
        var writeoffset = a.shdrs.items[a.ehdr.shstrndx].offset;
        try a.file.pwriteAll(sec_names.?, writeoffset);
        std.mem.copy(u8, a.data[writeoffset..], sec_names.?);
    }
    if (a.is32) {
        var shdr2 = try shdrToPacked32(a, alloc);
        try a.file.pwriteAll(std.mem.sliceAsBytes(shdr2), a.ehdr.shoff);
    } else {
        var shdr2 = try shdrToPacked64(a, alloc);
        try a.file.pwriteAll(std.mem.sliceAsBytes(shdr2), a.ehdr.shoff);
    }
}
