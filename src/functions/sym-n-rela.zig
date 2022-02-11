const std = @import("std");
const ELF = @import("../elf.zig");
const phdr = @import("../data-structures/phdr.zig");
const shdr = @import("../data-structures/shdr.zig");
const ehdr = @import("../data-structures/ehdr.zig");
const sym_n_rela = @import("../data-structures/sym-n-rela.zig");

pub fn getSyms(
    a: ELF.ELF,
    alloc: std.mem.Allocator,
) !std.ArrayList(sym_n_rela.Syms) {
    var symtabList = std.ArrayList(shdr.Shdr).init(alloc);
    var strtab: ?shdr.Shdr = null;
    const stream = a.file.reader();
    var dynstr: ?shdr.Shdr = null;
    for (a.shdrs.items) |section| {
        if (section.shtype == .SYMTAB) {
            try symtabList.append(section);
        }
        if (section.shtype == .STRTAB and (std.mem.eql(u8, section.name, ".strtab"))) {
            strtab = section;
        }
    }
    var list = std.ArrayList(sym_n_rela.Syms).init(alloc);
    if (!a.is32) {
        for (symtabList.items) |section| {
            var total_syms = section.size / @sizeOf(std.elf.Elf64_Sym);
            try a.file.seekableStream().seekTo(section.offset);
            var sym: std.elf.Elf64_Sym = undefined; //[total_syms]elf.Elf64_Sym = undefined;
            var i: usize = 0;
            while (i <= total_syms - 1) : (i = i + 1) {
                var curr_offset = section.offset + (@sizeOf(std.elf.Elf64_Sym) * i);
                try a.file.seekableStream().seekTo(curr_offset);
                try stream.readNoEof(std.mem.asBytes(&sym));
                var syms2: sym_n_rela.Syms = undefined;
                syms2.num = i;
                syms2.value = sym.st_value;
                syms2.size = sym.st_size;
                syms2.symtype = @intToEnum(sym_n_rela.Symtype, (ELF32_ST_TYPE(sym.st_info)));
                syms2.bind = @intToEnum(sym_n_rela.Bind, (ELF32_ST_BIND(sym.st_info)));
                syms2.visibility = @intToEnum(sym_n_rela.Visiblity, sym.st_other);
                syms2.index = sym.st_shndx;
                syms2.name = blk: {
                    if (section.shtype == .SYMTAB) {
                        try a.file.seekableStream().seekTo(strtab.?.offset + sym.st_name);
                        const c = (try stream.readUntilDelimiterOrEofAlloc(alloc, '\x00', 9000000000000000)) orelse "no name";
                        break :blk c;
                    } else {
                        try a.file.seekableStream().seekTo(dynstr.?.offset + sym.st_name);
                        const c = (try stream.readUntilDelimiterOrEofAlloc(alloc, '\x00', 9000000000000000)) orelse "no name";
                        break :blk c;
                    }
                };
                try list.append(syms2);
                //try std.io.getStdOut().writer().print("{s}\n", .{syms2});
            }
        }
        return list;
    } else {
        for (symtabList.items) |section| {
            var total_syms = section.size / @sizeOf(std.elf.Elf32_Sym);
            try a.file.seekableStream().seekTo(section.offset);
            var sym: std.elf.Elf32_Sym = undefined; //[total_syms]elf.Elf64_Sym = undefined;
            var i: usize = 0;
            while (i <= total_syms - 1) : (i = i + 1) {
                var curr_offset = section.offset + (@sizeOf(std.elf.Elf32_Sym) * i);
                try a.file.seekableStream().seekTo(curr_offset);
                try stream.readNoEof(std.mem.asBytes(&sym));
                //const sym = std.mem.bytesToValue(elf.Elf64_Sym, &section_data[curr_offset .. curr_offset + @sizeOf(elf.Elf64_Sym)]);

                var syms2: sym_n_rela.Syms = undefined;
                syms2.num = i;
                syms2.value = sym.st_value;
                syms2.size = sym.st_size;
                syms2.symtype = @intToEnum(sym_n_rela.Symtype, (ELF32_ST_TYPE(sym.st_info)));
                syms2.bind = @intToEnum(sym_n_rela.Bind, (ELF32_ST_BIND(sym.st_info)));
                syms2.visibility = @intToEnum(sym_n_rela.Visiblity, sym.st_other);
                syms2.index = sym.st_shndx;
                syms2.name = blk: {
                    if (section.shtype == .SYMTAB) {
                        try a.file.seekableStream().seekTo(strtab.?.offset + sym.st_name);
                        const c = (try stream.readUntilDelimiterOrEofAlloc(alloc, '\x00', 9000000000000000)) orelse "no name";
                        break :blk c;
                    } else {
                        try a.file.seekableStream().seekTo(dynstr.?.offset + sym.st_name);
                        const c = (try stream.readUntilDelimiterOrEofAlloc(alloc, '\x00', 9000000000000000)) orelse "no name";
                        break :blk c;
                    }
                };
                try list.append(syms2);
                //try std.io.getStdOut().writer().print("{s}\n", .{syms2});
            }
        }
        return list;
    }
}

pub fn ELF32_ST_BIND(val: u8) u8 {
    return val >> 4;
}
pub fn ELF32_ST_TYPE(val: anytype) c_int {
    return (@as(c_int, val) & @as(c_int, 0xf));
}
pub fn ELF32_ST_INFO(bind: anytype, type_1: anytype) c_int {
    return (bind << @as(c_int, 4)) + (type_1 & @as(c_int, 0xf));
}

// PARSER IS 100% COMPLETE!!!!
// writer needs some work
// then i need to connect everything
const returnSym = union {
    bit32: std.elf.Elf32_Sym,
    bit64: std.elf.Elf64_Sym,
};
pub fn fixRawSyms(a: ELF.ELF, alloc: std.mem.Allocator) ![]returnSym {
    var shstrtab_offset: usize = undefined;
    for (a.shdrs.items) |s| {
        if (s.sh_type == .STRTAB) {
            shstrtab_offset = s.sh_offset;
            break;
        }
    }
    if (a.is32) {
        var c = std.mem.ArrayList(std.elf.Elf32_Sym).init(alloc);
        defer c.deinit();
        var arraylist = std.mem.ArrayList(u8).init(alloc);
        defer arraylist.deinit();
        try arraylist.append("\x00");
        for (a.symbols) |sym| {
            if (sym.name == "") {
                continue;
            }
            try arraylist.appendSlice(sym.name);
            try arraylist.append("\x00");
        }
        for (a.symbols) |sym| {
            var b: std.elf.Elf32_Sym = undefined;
            if (std.mem.eql(u8, sym.name, "")) {
                b.st_name = 0;
            } else {
                b.st_name = try std.mem.indexOf(u8, arraylist.items, sym.name);
            }
            b.st_size = @intCast(std.elf.Elf32_Word, sym.size);
            b.st_info = ELF32_ST_INFO(sym.bind, sym.symtype);
            b.st_value = @intCast(std.elf.Elf32_Addr, sym.value);
            b.st_other = @intCast(u8, sym.visibility);
            try c.append(b);
        }
        try a.file.seekableStream().seekTo(shstrtab_offset);
        try a.file.writer().writeAll(arraylist.items);
        return alloc.dupe(std.elf.Elf32_Sym, arraylist.items);
    } else { // fix this
        var c = std.mem.ArrayList(std.elf.Elf64_Sym).init(alloc);
        defer c.deinit();
        var arraylist = std.mem.ArrayList(u8).init(alloc);
        defer arraylist.deinit();
        try arraylist.append("\x00");
        for (a.symbols) |sym| {
            if (sym.name == "") {
                continue;
            }
            try arraylist.appendSlice(sym.name);
            try arraylist.append("\x00");
        }
        for (a.symbols) |sym| {
            var b: std.elf.Elf64_Sym = undefined;
            if (std.mem.eql(u8, sym.name, "")) {
                b.st_name = 0;
            } else {
                b.st_name = try std.mem.indexOf(u8, arraylist.items, sym.name);
            }
            b.st_size = @intCast(std.elf.Elf64_Xword, sym.size);
            b.st_info = ELF32_ST_INFO(sym.bind, sym.symtype);
            b.st_value = @intCast(std.elf.Elf64_Addr, sym.value);
            b.st_other = @intCast(u8, sym.visibility);
            try c.append(b);
        }
        try a.file.seekableStream().seekTo(shstrtab_offset);
        try a.file.writer().writeAll(arraylist.items);
        return alloc.dupe(std.elf.Elf64_Sym, arraylist.items);
    }
}
// idk how to write and i prolly wont try for now
