const std = @import("std");
const elf = std.elf;
pub const ds = @import("./ds.zig");
pub const funcs = @import("./funcs.zig");
const elfErrors = error{
    CannotTellIfBinaryIs32or64bit,
};

pub const ELF = struct {
    file: std.fs.File = undefined,
    is32: bool = undefined,
    address: usize = 0x400000,
    ehdr: ds.Ehdr = undefined,
    shdrs: std.ArrayList(ds.Shdr) = undefined,
    phdrs: std.ArrayList(ds.Phdr) = undefined,
    data: []u8,
    symbols: std.ArrayList(ds.Syms) = undefined,
    relas: std.ArrayList(ds.Rela) = undefined,
    const Self = @This();
    pub fn init() !ELF {
        return ELF{};
    }
    pub fn readElf(file: std.fs.File, alloc: std.mem.Allocator) !ELF {
        var e: ELF = undefined;
        e.file = file;
        e.ehdr = try funcs.ehdrParse(e);
        e.is32 = try is32(e);
        e.data = try e.file.reader().readAllAlloc(alloc, std.math.maxInt(u64));
        e.phdrs = try funcs.phdrParse(e, alloc);
        e.shdrs = try funcs.shdrParse(e, alloc);
        e.symbols = try funcs.getSyms(e, alloc);
        return e;
    }

    fn is32(parse_source: ELF) !bool {
        var ident: [std.elf.EI_NIDENT]u8 = undefined;
        try parse_source.file.seekableStream().seekTo(0);
        _ = try parse_source.file.read(ident[0..]);
        if (ident[0x04] == 1) {
            return true;
        } else if (ident[0x04] == 2) {
            return false;
        } else {
            return elfErrors.CannotTellIfBinaryIs32or64bit;
        }
    } // have a deinit and update function
    pub fn deinit(self: Self) void {
        self.file.close();
        self.relas.deinit();
        self.shdrs.deinit();
        self.phdrs.deinit();
    }
    pub fn writeElf(self: Self, alloc: std.mem.Allocator) !void {
        try funcs.writeEhdr(self);
        try funcs.writePhdrList(self, alloc);
        {
            try self.file.seekTo((self.ehdr.phnum * self.ehdr.phentsize) + self.ehdr.phoff);
            //try self.file.writeAll(self.data);
            if ((self.ehdr.phnum * self.ehdr.phentsize) + self.ehdr.phoff > self.ehdr.shoff - 1) {
                @panic("the offset of the end of phdrs should be smaller than the offset of the start of shdrs, but that is not the case, idk whats up");
            } else {
                //try self.file.writer().writeAll(self.data[((self.ehdr.phnum * self.ehdr.phentsize) + self.ehdr.phoff) .. self.ehdr.shoff - 1]);
                try self.file.writer().writeAll(self.data[((self.ehdr.phnum * self.ehdr.phentsize) + self.ehdr.phoff)..]);
            }
        }
        try funcs.writeShdrList(self, alloc);
    }
};
