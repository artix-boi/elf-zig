const std = @import("std");
pub const Rela = struct {
    offset: usize,
    info: usize,
    symbol_value: usize,
    reltype: Reltype,
    symbol_name: []const u8,
    section_index: u16,
    plt_addr: ?usize,
};
pub const Syms = struct {
    num: u64,
    value: u64,
    size: u64,
    symtype: Symtype,
    bind: Bind,
    visibility: Visiblity,
    index: u16,
    name: []const u8,
};
pub const Symtype = enum(c_int) {
    NOTYPE = 0,
    OBJECT = 1,
    FUNC = 2,
    SECTION = 3,
    FILE = 4,
    TLS = 6,
    NUM = 7,
    LOOS = 10,
    HIOS = 12,
    _,
};
pub const Bind = enum(c_int) {
    LOCAL = 0,
    GLOBAL = 1,
    WEAK = 2,
    NUM = 3,
    UNIQUE = 10,
    HIOS = 12,
    LOPROC = 13,
    _,
};
pub const Visiblity = enum(c_int) {
    DEFAULT = 0,
    INTERNAL = 1,
    HIDDEN = 2,
    PROTECTED = 3,
    _,
};
pub const Reltype = enum(u32) {
    R_X86_64_OR_386_NONE = 0,
    R_X86_64_OR_386_64 = 1,
    R_X86_64_OR_386_PC32 = 2,
    R_X86_64_OR_386_GOT32 = 3,
    R_X86_64_OR_386_PLT32 = 4,
    R_X86_64_OR_386_COPY = 5,
    R_X86_64_OR_386_GLOB_DAT = 6,
    R_X86_64_OR_386_JUMP_SLOT = 7,
    R_X86_64_OR_386_RELATIVE = 8,
    R_X86_64_OR_386_GOTPCREL = 9,
    R_X86_64_OR_386_32 = 10,
    R_X86_64_OR_386_32S = 11,
    R_X86_64_OR_386_16 = 12,
    R_X86_64_OR_386_PC16 = 13,
    R_X86_64_OR_386_8 = 14,
    R_X86_64_OR_386_PC8 = 15,
    R_X86_64_OR_386_DTPMOD64 = 16,
    R_X86_64_OR_386_DTPOFF64 = 17,
    R_X86_64_OR_386_TPOFF64 = 18,
    R_X86_64_OR_386_TLSGD = 19,
    R_X86_64_OR_386_TLSLD = 20,
    R_X86_64_OR_386_DTPOFF32 = 21,
    R_X86_64_OR_386_GOTTPOFF = 22,
    R_X86_64_OR_386_TPOFF32 = 23,
    R_X86_64_OR_386_PC64 = 24,
    R_X86_64_OR_386_GOTOFF64 = 25,
    R_X86_64_OR_386_GOTPC32 = 26,
    R_X86_64_OR_386_GOT64 = 27,
    R_X86_64_OR_386_GOTPCREL64 = 28,
    R_X86_64_OR_386_GOTPC64 = 29,
    R_X86_64_OR_386_GOTPLT64 = 30,
    R_X86_64_OR_386_PLTOFF64 = 31,
    R_X86_64_OR_386_SIZE32 = 32,
    R_X86_64_OR_386_SIZE64 = 33,
    R_X86_64_OR_386_GOTPC32_TLSDESC = 34,
    R_X86_64_OR_386_TLSDESC_CALL = 35,
    R_X86_64_OR_386_TLSDESC = 36,
    R_X86_64_OR_386_IRELATIVE = 37,
    R_X86_64_OR_386_RELATIVE64 = 38,
    R_X86_64_OR_386_GOTPCRELX = 41,
    R_X86_64_OR_386_REX_GOTPCRELX = 42,
    R_X86_64_OR_386_NUM = 43,
    _,
};
