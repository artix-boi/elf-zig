const std = @import("std");
pub const Syms = struct {
    num: u64,
    value: u64,
    size: u64,
    symtype: []const u8,
    bind: []const u8,
    visibility: []const u8,
    index: []const u8,
    section: []const u8,
    name: []const u8,
};

pub const Shdr = struct {
    name: []const u8,
    shtype: []const u8,
    flags: usize,
    addr: usize,
    offset: usize,
    size: usize,
    link: usize,
    info: usize,
    addralign: usize,
    entsize: usize,
}; 
pub const Rela = struct {
    offset: usize,
    info: usize,
    symbol_value: usize,
    reltype: []const u8,
    symbol_name: []const u8,
    section_name: []const u8,
    plt_addr: ?usize,
};
pub const Phdr = struct {
    ptype: []const u8,
    flags: []const u8,
    offset: usize,
    vaddr: usize,
    paddr: usize,
    filesz: usize,
    memsz: usize,
    palign: usize,
};
pub const Ehdr = struct {
    identity: [std.elf.EI_NIDENT]u8,
    etype: std.elf.ET,
    machine: std.elf.EM,
    version: usize,
    entry: usize,
    phoff: usize,
    shoff: usize,
    flags: usize,
    ehsize: usize,
    phentsize: usize,
    phnum: usize,
    shentsize: usize,
    shnum: usize,
    shstrndx: usize,
};
