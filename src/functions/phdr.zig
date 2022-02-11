const std = @import("std");
const ELF = @import("../elf.zig");
const phdr = @import("../data-structures/phdr.zig");
const ehdr = @import("../data-structures/ehdr.zig");

const PhdrErrors = error{
    E_Phoff_Phentsize_or_Phnum_is_zero,
};

fn phdrParse32(
    elf: ELF.ELF,
    alloc: std.mem.Allocator,
) !std.ArrayList(phdr.Phdr) {
    var list = std.ArrayList(phdr.Phdr).init(alloc);
    var phdr1: phdr.Elf32_Phdr = undefined;
    const stream = elf.file.reader();
    var i: u64 = 0;
    while (i < elf.ehdr.phnum) : (i = i + 1) {
        const offset = elf.ehdr.phoff + @sizeOf(@TypeOf(phdr1)) * i;
        try elf.file.seekableStream().seekTo(offset);
        try stream.readNoEof(std.mem.asBytes(&phdr1));
        var phdr2: phdr.Phdr = undefined;
        phdr2.ptype = @intToEnum(phdr.p_type, phdr1.p_type);
        phdr2.flags = @bitCast(phdr.p_flags, phdr1.p_flags);
        phdr2.offset = phdr1.p_offset;
        phdr2.vaddr = phdr1.p_vaddr;
        phdr2.paddr = phdr1.p_paddr;
        phdr2.filesz = phdr1.p_filesz;
        phdr2.memsz = phdr1.p_memsz;
        phdr2.palign = phdr1.p_align;
        try list.append(phdr2);
    }
    return list;
}
fn phdrParse64(
    elf: ELF.ELF,
    alloc: std.mem.Allocator,
) !std.ArrayList(phdr.Phdr) {
    var list = std.ArrayList(phdr.Phdr).init(alloc);
    var phdr1: phdr.Elf64_Phdr = undefined;
    const stream = elf.file.reader();
    var i: u64 = 0;
    while (i < elf.ehdr.phnum) : (i = i + 1) {
        const offset = elf.ehdr.phoff + @sizeOf(@TypeOf(phdr1)) * i;
        try elf.file.seekableStream().seekTo(offset);
        try stream.readNoEof(std.mem.asBytes(&phdr1));
        var phdr2: phdr.Phdr = undefined;
        phdr2.ptype = @intToEnum(phdr.p_type, phdr1.p_type);
        phdr2.flags = @bitCast(phdr.p_flags, phdr1.p_flags);
        phdr2.offset = phdr1.p_offset;
        phdr2.vaddr = phdr1.p_vaddr;
        phdr2.paddr = phdr1.p_paddr;
        phdr2.filesz = phdr1.p_filesz;
        phdr2.memsz = phdr1.p_memsz;
        phdr2.palign = phdr1.p_align;
        try list.append(phdr2);
    }
    return list;
}
pub fn phdrParse(
    elf: ELF.ELF,
    alloc: std.mem.Allocator,
) !std.ArrayList(phdr.Phdr) {
    if (elf.is32 == false) {
        return phdrParse64(elf, alloc);
    } else {
        return phdrParse32(elf, alloc);
    }
}
fn phdrsToPacked32(
    phdrs: std.ArrayList(phdr.Phdr),
    alloc: std.mem.Allocator,
) ![]phdr.Elf32_Phdr {
    var arraylist = std.ArrayList(phdr.Elf32_Phdr).init(alloc);
    defer arraylist.deinit();
    for (phdrs.items) |p| {
        var x: phdr.Elf32_Phdr = undefined;
        x.p_align = @truncate(std.elf.Elf32_Word, p.palign);
        x.p_filesz = @truncate(std.elf.Elf32_Word, p.filesz);
        x.p_flags = @bitCast(std.elf.Elf32_Word, p.flags);
        x.p_memsz = @truncate(std.elf.Elf32_Word, p.memsz);
        x.p_offset = @truncate(std.elf.Elf32_Off, p.offset);
        x.p_paddr = @truncate(std.elf.Elf32_Addr, p.paddr);
        x.p_type = @enumToInt(p.ptype);
        x.p_vaddr = @truncate(std.elf.Elf32_Word, p.vaddr);

        try arraylist.append(x);
    }
    return alloc.dupe(phdr.Elf32_Phdr, arraylist.items);
}
fn phdrsToPacked64(
    phdrs: std.ArrayList(phdr.Phdr),
    alloc: std.mem.Allocator,
) ![]phdr.Elf64_Phdr {
    var arraylist = std.ArrayList(phdr.Elf64_Phdr).init(alloc);
    defer arraylist.deinit();
    for (phdrs.items) |p| {
        var x: phdr.Elf64_Phdr = undefined;
        x.p_align = @truncate(std.elf.Elf64_Xword, p.palign);
        x.p_filesz = @truncate(std.elf.Elf64_Xword, p.filesz);
        x.p_flags = @bitCast(std.elf.Elf64_Word, p.flags);
        x.p_memsz = @truncate(std.elf.Elf64_Word, p.memsz);
        x.p_offset = @truncate(std.elf.Elf64_Off, p.offset);
        x.p_paddr = @truncate(std.elf.Elf64_Addr, p.paddr);
        x.p_type = @enumToInt(p.ptype);
        x.p_vaddr = @truncate(std.elf.Elf64_Addr, p.vaddr);

        try arraylist.append(x);
    }
    return alloc.dupe(phdr.Elf64_Phdr, arraylist.items);
}

pub fn writePhdrList(
    a: ELF.ELF,
    alloc: std.mem.Allocator,
) !void {
    if (a.ehdr.phoff == 0 or a.ehdr.phnum == 0 or a.ehdr.phentsize == 0) {
        return PhdrErrors.E_Phoff_Phentsize_or_Phnum_is_zero;
    }
    if (a.is32) {
        var phdr2 = try phdrsToPacked32(a.phdrs, alloc);
        try a.file.pwriteAll(std.mem.sliceAsBytes(phdr2), a.ehdr.phoff);
    } else {
        var phdr2 = try phdrsToPacked64(a.phdrs, alloc);
        try a.file.pwriteAll(std.mem.sliceAsBytes(phdr2), a.ehdr.phoff);
    }
}
