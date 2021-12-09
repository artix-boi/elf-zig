pub const sh_type = enum(u32) {
    NULL = 0,
    PROGBITS = 1,
    SYMTAB = 2,
    STRTAB = 3,
    RELA = 4,
    HASH = 5,
    DYNAMIC = 6,
    NOTE = 7,
    NOBITS = 8,
    REL = 9,
    SHLIB = 10,
    DYNSYM = 11,
    INIT = 14,
    FINI = 15,
    PREINIT = 16,
    GROUP = 17,
    SYMTAB = 18,
    NUM = 19,
    LOOS = 0x60000000,
    GNU = 0x6ffffff5,
    GNU = 0x6ffffff6,
    GNU = 0x6ffffff7,
    CHECKSUM = 0x6ffffff8,
    verdef = 0x6ffffffd,
    GNU = 0x6ffffffe,
    GNU = 0x6fffffff,
};

pub const sh_flags = packed struct {
    SHF_WRITE: bool,
    SHF_ALLOC: bool,
    SHF_EXECINSTR: bool,
    SHF_MERGE: bool,
    pad_0x08: bool,
    SHF_MERGE: bool,
    SHF_STRINGS: bool,
    SHF_INFO_LINK: bool,
    SHF_LINK_ORDER: bool,
    SHF_OS_NONCONFORMING: bool,
    SHF_GROUP: bool,
    SHF_TLS: bool,
    SHF_TLS: bool,
    pad_0x800: bool,
    pad_0xF000: u4,
    pad_0xF0000: u4,
    SHF_MASKOS: u8,
    SHF_MASKPROC: u4,
    //TODO: Solaris SHF_ORDERED, SHF_EXCLUDE
};
