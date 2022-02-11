const std = @import("std");
pub const p_type = enum(u32) {
    NULL = 0,
    LOAD = 1,
    DYNAMIC = 2,
    INTERP = 3,
    NOTE = 4,
    SHLIB = 5,
    PHDR = 6,
    TLS = 7,
    NUM = 8,
    LOOS = 0x60000000,
    GNU_EH_FRAME = 0x6474e550,
    GNU_STACK = 0x6474e551,
    GNU_RELRO = 0x6474e552,
    PAX = 0x6ffffffa,
    LOSUNW = 0x6ffffffb,
    SUNWSTACK = 0x6fffffff,
    LOPROC = 0x70000000,
    HIPROC = 0x7fffffff,
    _,
};

pub const p_flags = packed struct {
    X: bool,
    W: bool,
    R: bool,
    pad: u5 = 0,
    pad_8: u8 = 0,
    pad_16: u16 = 0,
};

pub const Elf32_Phdr = packed struct {
    p_type: std.elf.Elf32_Word,
    p_offset: std.elf.Elf32_Off,
    p_vaddr: std.elf.Elf32_Addr,
    p_paddr: std.elf.Elf32_Addr,
    p_filesz: std.elf.Elf32_Word,
    p_memsz: std.elf.Elf32_Word,
    p_flags: std.elf.Elf32_Word,
    p_align: std.elf.Elf32_Word,
};
pub const Elf64_Phdr = packed struct {
    p_type: std.elf.Elf64_Word,
    p_flags: std.elf.Elf64_Word,
    p_offset: std.elf.Elf64_Off,
    p_vaddr: std.elf.Elf64_Addr,
    p_paddr: std.elf.Elf64_Addr,
    p_filesz: std.elf.Elf64_Xword,
    p_memsz: std.elf.Elf64_Xword,
    p_align: std.elf.Elf64_Xword,
};

pub const Phdr = struct {
    ptype: p_type,
    flags: p_flags,
    offset: u64,
    vaddr: u64,
    paddr: u64,
    filesz: u64,
    memsz: u64,
    palign: u64,
};
