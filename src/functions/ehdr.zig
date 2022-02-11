const std = @import("std");
const ehdr = @import("../data-structures/ehdr.zig");
const ELF = @import("../elf.zig");
fn ehdrParse64(elf: ELF.ELF) !ehdr.Ehdr {
    try elf.file.seekableStream().seekTo(0x00);
    var ehdr1: std.elf.Elf64_Ehdr = undefined;
    const stream = elf.file.reader();
    try stream.readNoEof(std.mem.asBytes(&ehdr1));
    //    return try parse_source.reader().readstruct(std.elf.elf64_ehdr);
    var a = @enumToInt(ehdr1.e_type);
    var b = @enumToInt(ehdr1.e_machine);
    return ehdr.Ehdr{
        .identity = ehdr1.e_ident,
        .etype = @intToEnum(ehdr.e_type, a),
        .machine = @intToEnum(ehdr.e_machine, b),
        .version = ehdr1.e_version,
        .entry = ehdr1.e_entry,
        .phoff = ehdr1.e_phoff,
        .shoff = ehdr1.e_shoff,
        .flags = ehdr1.e_flags,
        .ehsize = ehdr1.e_ehsize,
        .phentsize = ehdr1.e_phentsize,
        .phnum = ehdr1.e_phnum,
        .shentsize = ehdr1.e_shentsize,
        .shnum = ehdr1.e_shnum,
        .shstrndx = ehdr1.e_shstrndx,
    };
}
fn ehdrParse32(elf: ELF.ELF) !ehdr.Ehdr {
    try elf.file.seekableStream().seekTo(0x00);
    var ehdr1: std.elf.Elf32_Ehdr = undefined;
    const stream = elf.file.reader();
    try stream.readNoEof(std.mem.asBytes(&ehdr));
    //    return try parse_source.reader().readstruct(std.elf.elf64_ehdr);
    var a = @enumToInt(ehdr1.e_type);
    var b = @enumToInt(ehdr1.e_machine);
    return ehdr.Ehdr{
        .identity = ehdr1.e_ident,
        .etype = @intToEnum(ehdr.Elf64_Ehdr.e_type, a),
        .machine = @intToEnum(ehdr.Elf64_Ehdr.e_machine, b),
        .version = ehdr1.e_version,
        .entry = ehdr1.e_entry,
        .phoff = ehdr1.e_phoff,
        .shoff = ehdr1.e_shoff,
        .flags = ehdr1.e_flags,
        .ehsize = ehdr1.e_ehsize,
        .phentsize = ehdr1.e_phentsize,
        .phnum = ehdr1.e_phnum,
        .shentsize = ehdr1.e_shentsize,
        .shnum = ehdr1.e_shnum,
        .shstrndx = ehdr1.e_shstrndx,
    };
}

pub fn ehdrParse(elf: ELF.ELF) !ehdr.Ehdr {
    if (!elf.is32) {
        return ehdrParse64(elf);
    } else {
        return ehdrParse64(elf);
    }
}

// convert high level ehdr to packed struct, easy writing! Am i stupid? possibly
fn ehdrToPacked32(a: ELF.ELF) ehdr.Elf32_Ehdr {
    var ehdr2: ehdr.Elf32_Ehdr = undefined;
    ehdr2.e_ident = a.ehdr.identity;
    ehdr2.e_type = a.ehdr.etype;
    ehdr2.e_machine = a.ehdr.machine;
    ehdr2.e_version = @intCast(std.elf.Elf32_Word, a.ehdr.version);
    ehdr2.e_entry = @intCast(std.elf.Elf32_Addr, a.ehdr.entry);
    ehdr2.e_phoff = @intCast(std.elf.Elf32_Off, a.ehdr.phoff);
    ehdr2.e_shoff = @intCast(std.elf.Elf32_Off, a.ehdr.shoff);
    ehdr2.e_flags = @intCast(std.elf.Elf32_Word, a.ehdr.flags);
    ehdr2.e_ehsize = @intCast(std.elf.Elf32_Half, a.ehdr.ehsize);
    ehdr2.e_phentsize = @intCast(std.elf.Elf32_Half, a.ehdr.phentsize);
    ehdr2.e_phnum = @intCast(std.elf.Elf32_Half, ehdr2.e_phnum);
    ehdr2.e_shentsize = @intCast(std.elf.Elf32_Half, a.ehdr.shentsize);
    ehdr2.e_shnum = @intCast(std.elf.Elf32_Half, a.ehdr.shnum);
    ehdr2.e_shstrndx = @intCast(std.elf.Elf32_Half, ehdr2.e_shstrndx);
    return ehdr2;
}

fn ehdrToPacked64(a: ELF.ELF) ehdr.Elf64_Ehdr {
    var ehdr2: ehdr.Elf64_Ehdr = undefined;
    ehdr2.e_ident = a.ehdr.identity;
    ehdr2.e_type = a.ehdr.etype;
    ehdr2.e_machine = a.ehdr.machine;
    ehdr2.e_version = @intCast(std.elf.Elf64_Word, a.ehdr.version);
    ehdr2.e_entry = @intCast(std.elf.Elf64_Addr, a.ehdr.entry);
    ehdr2.e_phoff = @intCast(std.elf.Elf64_Off, a.ehdr.phoff);
    ehdr2.e_shoff = @intCast(std.elf.Elf64_Off, a.ehdr.shoff);
    ehdr2.e_flags = @intCast(std.elf.Elf64_Word, a.ehdr.flags);
    ehdr2.e_ehsize = @intCast(std.elf.Elf64_Half, a.ehdr.ehsize);
    ehdr2.e_phentsize = @intCast(std.elf.Elf64_Half, a.ehdr.phentsize);
    ehdr2.e_phnum = @intCast(std.elf.Elf64_Half, a.ehdr.phnum);
    ehdr2.e_shentsize = @intCast(std.elf.Elf64_Half, a.ehdr.shentsize);
    ehdr2.e_shnum = @intCast(std.elf.Elf64_Half, a.ehdr.shnum);
    ehdr2.e_shstrndx = @intCast(std.elf.Elf64_Half, a.ehdr.shstrndx);
    return ehdr2;
}

pub fn writeEhdr(a: ELF.ELF) !void {
    try a.file.seekableStream().seekTo(0x00);

    // ehdr to ;acked struct
    if (!a.is32) {
        var ehdr2 = ehdrToPacked64(a);
        std.log.info("ehdr2{}\n", .{ehdr2});
        try a.file.writer().writeStruct(ehdr2);
    } else {
        var ehdr2 = ehdrToPacked32(a);
        std.log.info("ehdr2{}\n", .{ehdr2});
        try a.file.writer().writeStruct(ehdr2);
    }
}
