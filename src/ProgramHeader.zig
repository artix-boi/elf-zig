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
    GNU = 0x6474e550,
    GNU = 0x6474e551,
    GNU = 0x6474e552,
    PAX = 0x6ffffffa,
    LOSUNW = 0x6ffffffb,
    SUNWSTACK = 0x6fffffff,
    LOPROC = 0x70000000,
    HIPROC = 0x7fffffff,
};

pub const p_flags = packed struct {
    X: bool,
    W: bool,
    R: bool,
    pad: u5 = 0,
    pad_8: u8 = 0,
    pad_16: u16 = 0,
};
