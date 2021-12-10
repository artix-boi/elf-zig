const std = @import("std");
const elf = std.elf;
const arch = @import("./arch.zig");
const table = @import("../table-helper/table-helper.zig");
const SectionHeader = @import("./SectionHeader.zig");
//usingnamespace @import("./arch.zig");
const elfErrors = error{
    CannotTellIfBinaryIs32or64bit,
};

pub const ELF = struct {
    file: std.fs.File,
    is32: bool,
    path: []const u8,
    symbols: std.StringHashMap(arch.Syms),
    //    got: std.StringHashMap(usize),
    //    plt: std.StringHashMap(usize),
    //    functions: std.StringHashMap(usize),
    address: usize = 0x400000,
    ehdr: arch.Ehdr,
    shdrs: []arch.Shdr,
    phdrs: []arch.Phdr,
    relas: []arch.Rela,

    //linker: []const u8,
    //fill_gaps: bool = true,
    const Self = @This();
    pub fn init(path: []const u8, alloc: *std.mem.Allocator) !ELF {
        var f = try openElf(path);
        var is = try is32(f);
        var ehdr = try ehdrParse(f, is);
        var phdrs = try phdrParse(f, ehdr, alloc, is);
        var shdrs = try shdrParse(f, ehdr, alloc, is);
        var syms2 = try getSyms(f, alloc, is, shdrs);
        return ELF{
            .file = f,
            .is32 = is,
            .path = path,
            .symbols = syms2,
            .ehdr = ehdr,
            .shdrs = shdrs,
            .phdrs = phdrs,
        };
    }
};
pub fn ehdrParse(parse_source: anytype, isit32: bool) !arch.Ehdr {
    try parse_source.seekableStream().seekTo(0x00);
    if (!isit32) {
        var ehdr: std.elf.Elf64_arch.Ehdr = undefined;
        const stream = parse_source.reader();
        try stream.readNoEof(std.mem.asBytes(&ehdr));
        //    return try parse_source.reader().readstruct(std.elf.elf64_ehdr);
        return arch.Ehdr{
            .identity = ehdr.e_ident,
            .etype = ehdr.e_type,
            .machine = ehdr.e_machine,
            .version = ehdr.e_version,
            .entry = ehdr.e_entry,
            .phoff = ehdr.e_phoff,
            .shoff = ehdr.e_shoff,
            .flags = ehdr.e_flags,
            .ehsize = ehdr.e_ehsize,
            .phentsize = ehdr.e_phentsize,
            .phnum = ehdr.e_phnum,
            .shentsize = ehdr.e_shentsize,
            .shnum = ehdr.e_shnum,
            .shstrndx = ehdr.e_shstrndx,
        };
    } else {
        var ehdr: std.elf.Elf32_arch.Ehdr = undefined;
        const stream = parse_source.reader();
        try stream.readNoEof(std.mem.asBytes(&ehdr));
        //    return try parse_source.reader().readstruct(std.elf.elf64_ehdr);
        return arch.Ehdr{
            .identity = ehdr.e_ident,
            .etype = ehdr.e_type,
            .machine = ehdr.e_machine,
            .version = ehdr.e_version,
            .entry = ehdr.e_entry,
            .phoff = ehdr.e_phoff,
            .shoff = ehdr.e_shoff,
            .flags = ehdr.e_flags,
            .ehsize = ehdr.e_ehsize,
            .phentsize = ehdr.e_phentsize,
            .phnum = ehdr.e_phnum,
            .shentsize = ehdr.e_shentsize,
            .shnum = ehdr.e_shnum,
            .shstrndx = ehdr.e_shstrndx,
        };
    }
}

fn is32(parse_source: std.fs.File) !bool {
    var ident: [std.elf.EI_NIDENT]u8 = undefined;
    _ = try parse_source.read(ident[0..]);
    if (ident[0x04] == 1) {
        return true;
    } else if (ident[0x04] == 2) {
        return false;
    } else {
        return elfErrors.CannotTellIfBinaryIs32or64bit;
    }
}
pub fn openElf(file: []const u8) !std.fs.File {
    return std.fs.cwd().openFile(file, .{});
}

pub fn phdrParse(parse_source: std.fs.File, ehdr: arch.Ehdr, alloc: *std.mem.Allocator, Is32: bool) ![]arch.Phdr {
    var list = std.ArrayList(arch.Phdr).init(alloc);
    defer list.deinit();
    if (Is32 == false) {
        var phdr: elf.Elf64_arch.Phdr = undefined;
        const stream = parse_source.reader();
        var i: usize = 0;
        while (i <= ehdr.phnum) : (i = i + 1) {
            const offset = ehdr.phoff + @sizeOf(@TypeOf(phdr)) * i;
            try parse_source.seekableStream().seekTo(offset);
            try stream.readNoEof(std.mem.asBytes(&phdr));
            var phdr1: arch.Phdr = undefined;
            phdr1.ptype = phdr.p_type;
            phdr1.flags = phdr.p_flags;
            phdr1.offset = phdr.p_offset;
            phdr1.vaddr = phdr.p_vaddr;
            phdr1.paddr = phdr.p_paddr;
            phdr1.filesz = phdr.p_filesz;
            phdr1.memsz = phdr.p_memsz;
            phdr1.palign = phdr.p_align;
            try list.append(phdr1);
        }
        const a = std.mem.dupe(alloc, arch.Phdr, list.items);
        return a;
    } else {
        var i: usize = 0;
        var phdr: elf.Elf32_arch.Phdr = undefined;
        const stream = parse_source.reader();
        while (i <= ehdr.phnum) : (i = i + 1) {
            const offset = ehdr.phoff + @sizeOf(@TypeOf(phdr)) * i;
            try parse_source.seekableStream().seekTo(offset);
            try stream.readNoEof(std.mem.asBytes(&phdr));
            var phdr1: arch.Phdr = undefined;
            phdr1.ptype = phdr.p_type;
            phdr1.flags = phdr.p_flags;
            phdr1.offset = phdr.p_offset;
            phdr1.vaddr = phdr.p_vaddr;
            phdr1.paddr = phdr.p_paddr;
            phdr1.filesz = phdr.p_filesz;
            phdr1.memsz = phdr.p_memsz;
            phdr1.palign = phdr.p_align;
            try list.append(phdr1);
        }
        const a = std.mem.dupe(alloc, arch.Phdr, list.items);
        return a;
    }
}
fn shdr_get_name_init(parse_source: anytype, ehdr: arch.Ehdr, shstrndx: u64, alloc: *std.mem.Allocator, Is32: bool) ![]const u8 {
    if (!Is32) {
        var shdr: std.elf.Elf64_arch.Shdr = undefined;
        const buf = std.mem.asBytes(&shdr);
        _ = try parse_source.preadAll(buf, ehdr.shoff + @sizeOf(std.elf.Elf64_arch.Shdr) * shstrndx);
        const buffer = try alloc.alloc(u8, shdr.sh_size);
        _ = try parse_source.preadAll(buffer, shdr.sh_offset);
        return buffer;
    } else {
        var shdr: std.elf.Elf32_arch.Shdr = undefined;
        const buf = std.mem.asBytes(&shdr);
        _ = try parse_source.preadAll(buf, ehdr.shoff + @sizeOf(std.elf.Elf32_arch.Shdr) * shstrndx);
        const buffer = try alloc.alloc(u8, shdr.sh_size);
        _ = try parse_source.preadAll(buffer, shdr.sh_offset);
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
pub fn shdrParse(parse_source: std.fs.File, ehdr: arch.Ehdr, alloc: *std.mem.Allocator, Is32: bool) ![]arch.Shdr {
    var list = std.ArrayList(arch.Shdr).init(alloc);
    defer list.deinit();
    const stream = parse_source.reader();
    var section_strtab = try shdr_get_name_init(parse_source, ehdr, ehdr.shstrndx, alloc, Is32);
    //try std.io.getStdOut().writer().print("{x}\n", .{std.fmt.fmtSliceHexLower(section_strtab[0..])});
    var i: usize = 0;
    if (Is32 == false) {
        var shdr: elf.Elf64_arch.Shdr = undefined;
        while (i < ehdr.shnum) : (i = i + 1) {
            const offset = ehdr.shoff + @sizeOf(@TypeOf(shdr)) * i;
            try parse_source.seekableStream().seekTo(offset);

            try stream.readNoEof(std.mem.asBytes(&shdr));
            var shdr1: arch.Shdr = undefined;
            shdr1.name = shdr_get_name(section_strtab, shdr.sh_name);
            shdr1.shtype = shdr.sh_type;
            shdr1.offset = shdr.sh_offset;
            shdr1.entsize = shdr.sh_entsize;
            shdr1.addralign = shdr.sh_addralign;
            shdr1.info = shdr.sh_info;
            shdr1.link = shdr.sh_link;
            shdr1.size = shdr.sh_size;
            shdr1.addr = shdr.sh_addr;
            shdr1.flags = shdr.sh_flags;
            //var data = try alloc.alloc(u8, shdr.sh_size); //[shdr.sh_size]u8 = undefined;
            //try parse_source.seekableStream().seekTo(shdr.sh_offset);
            //_ = try parse_source.reader().read(data[0..]);
            try list.append(shdr1);
        }
        return try alloc.dupe(arch.Shdr, list.items);
    } else {
        var shdr: elf.Elf32_arch.Shdr = undefined;
        while (i < ehdr.shnum) : (i = i + 1) {
            const offset = ehdr.shoff + @sizeOf(@TypeOf(shdr)) * i;
            try parse_source.seekableStream().seekTo(offset);

            try stream.readNoEof(std.mem.asBytes(&shdr));
            var shdr1: arch.Shdr = undefined;
            shdr1.name = shdr_get_name(section_strtab, shdr.sh_name);
            shdr1.shtype = shdr.sh_type;
            shdr1.offset = shdr.sh_offset;
            shdr1.entsize = shdr.sh_entsize;
            shdr1.addralign = shdr.sh_addralign;
            shdr1.info = shdr.sh_info;
            shdr1.link = shdr.sh_link;
            shdr1.size = shdr.sh_size;
            shdr1.addr = shdr.sh_addr;
            shdr1.flags = shdr.sh_flags;
            //var data = try alloc.alloc(u8, shdr.sh_size); //[shdr.sh_size]u8 = undefined;
            //try parse_source.seekableStream().seekTo(shdr.sh_offset);
            //_ = try parse_source.reader().read(data[0..]);
            try list.append(shdr1);
        }
        return try alloc.dupe(arch.Shdr, list.items);
    }
}
pub fn getSyms(parse_source: std.fs.File, alloc: *std.mem.Allocator, Is32: bool, ShdrArray: []arch.Shdr) !std.StringHashMap(arch.Syms) {
    var symtabList = std.ArrayList(*arch.Shdr).init(alloc);
    var strtab: ?*arch.Shdr = null;
    const stream = parse_source.reader();
    var dynstr: ?*arch.Shdr = null;
    for (ShdrArray) |*section| {
        if (section.shtype ==  SectionHeader.sh_type.SYMTAB or section.shtype == SectionHeader.sh_type.DYNSYM) {
            try symtabList.append(section);
        }
        if (section.shtype == SectionHeader.sh_type.STRTAB and (std.mem.eql(u8, section.name, ".strtab"))) {
            strtab = section;
        }
        if (section.shtype == SectionHeader.sh_type.STRTAB and (std.mem.eql(u8, section.name, ".dynstr"))) {
            dynstr = section;
        }
    }
    var list = std.StringHashMap(arch.Syms).init(alloc);
    if (!Is32) {
        for (symtabList.items) |section| {
            var total_syms = section.size / @sizeOf(elf.Elf64_Sym);
            try parse_source.seekableStream().seekTo(section.offset);
            var sym: elf.Elf64_Sym = undefined; //[total_syms]elf.Elf64_Sym = undefined;
            var i: usize = 0;
            while (i <= total_syms - 1) : (i = i + 1) {
                var curr_offset = section.offset + (@sizeOf(elf.Elf64_Sym) * i);
                try parse_source.seekableStream().seekTo(curr_offset);
                try stream.readNoEof(std.mem.asBytes(&sym));
                //const sym = std.mem.bytesToValue(elf.Elf64_Sym, &section_data[curr_offset .. curr_offset + @sizeOf(elf.Elf64_Sym)]);

                var syms2: arch.Syms = undefined;
                syms2.num = i;
                syms2.value = sym.st_value;
                syms2.size = sym.st_size;
                syms2.symtype = switch (ELF32_ST_TYPE(sym.st_info)) {
                    0 => "NOTYPE",
                    1 => "OBJECT",
                    2 => "FUNC",
                    3 => "SECTION",
                    4 => "FILE",
                    6 => "TLS",
                    7 => "NUM",
                    10 => "LOOS",
                    12 => "HIOS",
                    else => "UNKNOWN",
                };
                syms2.bind = switch (ELF32_ST_BIND(sym.st_info)) {
                    0 => "LOCAL",
                    1 => "GLOBAL",
                    2 => "WEAK",
                    3 => "NUM",
                    10 => "UNIQUE",
                    12 => "HIOS",
                    13 => "LOPROC",
                    else => "UNKNOWN",
                };
                syms2.visibility = switch (ELF32_ST_VISIBILITY(sym.st_other)) {
                    0 => "DEFAULT",
                    1 => "INTERNAL",
                    2 => "HIDDEN",
                    3 => "PROTECTED",
                    else => "UNKNOWN",
                };
                syms2.index = try std.fmt.allocPrint(alloc, "0x{x}", .{sym.st_shndx});
                syms2.name = blk: {
                    if (std.mem.eql(u8, section.shtype, "SYMTAB")) {
                        try parse_source.seekableStream().seekTo(strtab.?.offset + sym.st_name);
                        const c = (try stream.readUntilDelimiterOrEofAlloc(alloc, '\x00', 9000000000000000)) orelse "no name";
                        break :blk c;
                    } else {
                        try parse_source.seekableStream().seekTo(dynstr.?.offset + sym.st_name);
                        const c = (try stream.readUntilDelimiterOrEofAlloc(alloc, '\x00', 9000000000000000)) orelse "no name";
                        break :blk c;
                    }
                };
                syms2.section = section.name;
                try list.put(syms2.name, syms2);
                //try std.io.getStdOut().writer().print("{s}\n", .{syms2});
            }
        }
        return list;
    } else {
        for (symtabList.items) |section| {
            var total_syms = section.size / @sizeOf(elf.Elf32_Sym);
            try parse_source.seekableStream().seekTo(section.offset);
            var sym: elf.Elf32_Sym = undefined; //[total_syms]elf.Elf64_Sym = undefined;
            var i: usize = 0;
            while (i <= total_syms - 1) : (i = i + 1) {
                var curr_offset = section.offset + (@sizeOf(elf.Elf32_Sym) * i);
                try parse_source.seekableStream().seekTo(curr_offset);
                try stream.readNoEof(std.mem.asBytes(&sym));
                //const sym = std.mem.bytesToValue(elf.Elf64_Sym, &section_data[curr_offset .. curr_offset + @sizeOf(elf.Elf64_Sym)]);

                var syms2: arch.Syms = undefined;
                syms2.num = i;
                syms2.value = sym.st_value;
                syms2.size = sym.st_size;
                syms2.symtype = switch (ELF32_ST_TYPE(sym.st_info)) {
                    0 => "NOTYPE",
                    1 => "OBJECT",
                    2 => "FUNC",
                    3 => "SECTION",
                    4 => "FILE",
                    6 => "TLS",
                    7 => "NUM",
                    10 => "LOOS",
                    12 => "HIOS",
                    else => "UNKNOWN",
                };
                syms2.bind = switch (ELF32_ST_BIND(sym.st_info)) {
                    0 => "LOCAL",
                    1 => "GLOBAL",
                    2 => "WEAK",
                    3 => "NUM",
                    10 => "UNIQUE",
                    12 => "HIOS",
                    13 => "LOPROC",
                    else => "UNKNOWN",
                };
                syms2.visibility = switch (ELF32_ST_VISIBILITY(sym.st_other)) {
                    0 => "DEFAULT",
                    1 => "INTERNAL",
                    2 => "HIDDEN",
                    3 => "PROTECTED",
                    else => "UNKNOWN",
                };
                syms2.index = try std.fmt.allocPrint(alloc, "0x{x}", .{sym.st_shndx});
                syms2.name = blk: {
                    if (std.mem.eql(u8, section.shtype, "SYMTAB")) {
                        try parse_source.seekableStream().seekTo(strtab.?.offset + sym.st_name);
                        const c = (try stream.readUntilDelimiterOrEofAlloc(alloc, '\x00', 9000000000000000)) orelse "no name";
                        break :blk c;
                    } else {
                        try parse_source.seekableStream().seekTo(dynstr.?.offset + sym.st_name);
                        const c = (try stream.readUntilDelimiterOrEofAlloc(alloc, '\x00', 9000000000000000)) orelse "no name";
                        break :blk c;
                    }
                };
                syms2.section = section.name;
                try list.put(syms2.name, syms2);
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
pub fn ELF32_ST_VISIBILITY(o: anytype) c_int {
    return @as(c_int, o) & @as(c_int, 0x03);
}
pub fn getRela(parse_source: std.fs.File, alloc: *std.mem.Allocator, Is32: bool, shdrList: *[]arch.Shdr, dynsymlist: []arch.Syms) []arch.Rela {
    var list = std.ArrayList(arch.Rela).init(alloc);
    //defer list.deinit();
    const stream = parse_source.reader();
    for (shdrList) |*section| {
        if (std.mem.eql(u8, section.shtype, "SHT_RELA")) {
            if (!Is32) {
                try parse_source.seekableStream().seekTo(section.offset);
                var total_rela = section.size / @sizeOf(elf.Elf64_Rela);
                var i: usize = 0;
                while (i <= total_rela - 1) : (i = i + 1) {
                    var curr_offset = section.offset + (@sizeOf(elf.Elf64_Rela) * i);
                    try parse_source.seekableStream().seekTo(curr_offset);
                    var rela: elf.Elf64_Rela = undefined;
                    try stream.readNoEof(std.mem.asBytes(&rela));
                    var rela2: arch.Rela = undefined;
                    rela2.offset = rela.r_offset;
                    rela2.info = rela.r_info;
                    rela2.reltype = switch (rela.r_type) {
                        0 => "R_X86_64_NONE",
                        1 => "R_X86_64_64",
                        2 => "R_X86_64_PC32",
                        3 => "R_X86_64_GOT32",
                        4 => "R_X86_64_PLT32",
                        5 => "R_X86_64_COPY",
                        6 => "R_X86_64_GLOB_DAT",
                        7 => "R_X86_64_JUMP_SLOT",
                        8 => "R_X86_64_RELATIVE",
                        9 => "R_X86_64_GOTPCREL",
                        10 => "R_X86_64_32",
                        11 => "R_X86_64_32S",
                        12 => "R_X86_64_16",
                        13 => "R_X86_64_PC16",
                        14 => "R_X86_64_8",
                        15 => "R_X86_64_PC8",
                        16 => "R_X86_64_DTPMOD64",
                        17 => "R_X86_64_DTPOFF64",
                        18 => "R_X86_64_TPOFF64",
                        19 => "R_X86_64_TLSGD",
                        20 => "R_X86_64_TLSLD",
                        21 => "R_X86_64_DTPOFF32",
                        22 => "R_X86_64_GOTTPOFF",
                        23 => "R_X86_64_TPOFF32",
                        24 => "R_X86_64_PC64",
                        25 => "R_X86_64_GOTOFF64",
                        26 => "R_X86_64_GOTPC32",
                        27 => "R_X86_64_GOT64",
                        28 => "R_X86_64_GOTPCREL64",
                        29 => "R_X86_64_GOTPC64",
                        30 => "R_X86_64_GOTPLT64",
                        31 => "R_X86_64_PLTOFF64",
                        32 => "R_X86_64_SIZE32",
                        33 => "R_X86_64_SIZE64",
                        34 => "R_X86_64_GOTPC32_TLSDESC",
                        35 => "R_X86_64_TLSDESC_CALL",
                        36 => "R_X86_64_TLSDESC",
                        37 => "R_X86_64_IRELATIVE",
                        38 => "R_X86_64_RELATIVE64",
                        41 => "R_X86_64_GOTPCRELX",
                        42 => "R_X86_64_REX_GOTPCRELX",
                        43 => "R_X86_64_NUM",
                    };
                    rela2.symbol_name = blk: {
                        var symvalue = rela.r_sym();
                        var symbol = dynsymlist[symvalue].name;
                        break :blk symbol;
                    };
                    rela2.symbol_value = rela.r_sym();
                    rela2.section_name = dynsymlist[rela2.symbol_value].section;
                    try list.append(rela2);
                }
            } else {
                try parse_source.seekableStream().seekTo(section.offset);
                var total_rela = section.size / @sizeOf(elf.Elf32_Rela);
                var i: usize = 0;
                while (i <= total_rela - 1) : (i = i + 1) {
                    var curr_offset = section.offset + (@sizeOf(elf.Elf32_Rela) * i);
                    try parse_source.seekableStream().seekTo(curr_offset);
                    var rela: elf.Elf32_Rela = undefined;
                    try stream.readNoEof(std.mem.asBytes(&rela));
                    var rela2: arch.Rela = undefined;
                    rela2.offset = rela.r_offset;
                    rela2.info = rela.r_info;
                    rela2.reltype = switch (rela.r_type) {
                        0 => "R_386_NONE",
                        1 => "R_386_32",
                        2 => "R_386_PC32",
                        3 => "R_386_GOT32",
                        4 => "R_386_PLT32",
                        5 => "R_386_COPY",
                        6 => "R_386_GLOB_DAT",
                        7 => "R_386_JMP_SLOT",
                        8 => "R_386_RELATIVE",
                        9 => "R_386_GOTOFF",
                        10 => "R_386_GOTPC",
                        11 => "R_386_32PLT",
                        12 => "R_386_TLS_TPOFF",
                        13 => "R_386_TLS_IE",
                        14 => "R_386_TLS_GOTIE",
                        15 => "R_386_TLS_LE",
                        16 => "R_386_TLS_GD",
                        17 => "R_386_TLS_LDM",
                        18 => "R_386_16",
                        19 => "R_386_PC16",
                        20 => "R_386_8",
                        21 => "R_386_PC8",
                        22 => "R_386_TLS_GD_32",
                        23 => "R_386_TLS_GD_PUSH",
                        24 => "R_386_TLS_GD_CALL",
                        25 => "R_386_TLS_GD_POP",
                        26 => "R_386_TLS_LDM_32",
                        27 => "R_386_TLS_LDM_PUSH",
                        28 => "R_386_TLS_LDM_CALL",
                        29 => "R_386_TLS_LDM_POP",
                        30 => "R_386_TLS_LDO_32",
                        31 => "R_386_TLS_IE_32",
                        32 => "R_386_TLS_LE_32",
                        33 => "R_386_TLS_DTPMOD32",
                        34 => "R_386_TLS_DTPOFF32",
                        35 => "R_386_TLS_TPOFF32",
                        36 => "R_386_SIZE32",
                        37 => "R_386_TLS_GOTDESC",
                        38 => "R_386_TLS_DESC_CALL",
                        41 => "R_386_TLS_DESC",
                        42 => "R_386_IRELATIVE",
                        43 => "R_386_GOT32X",
                        44 => "R_386_NUM",
                    };
                    rela2.symbol_name = blk: {
                        var symvalue = rela.r_sym();
                        var symbol = dynsymlist[symvalue].name;
                        break :blk symbol;
                    };
                    rela2.symbol_value = rela.r_sym();
                    rela2.section_name = dynsymlist[rela2.symbol_value].section;
                    try list.append(rela2);
                }
            }
        }
    }
    return list;
}
