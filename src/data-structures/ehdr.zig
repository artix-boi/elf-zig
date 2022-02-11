const std = @import("std");

pub const e_type = enum(u16) {
    ET_NONE = 0x00,
    ET_REL = 0x01,
    ET_EXEC = 0x02,
    ET_DYN = 0x03,
    ET_CORE = 0x04,
    ET_LOOS = 0xFE00,
    ET_HIOS = 0xFEFF,
    ET_LOPROC = 0xFF00,
    ET_HIPROC = 0xFFFF,
    _,
};
// code taken from  https://github.com/ziglang/zig/blob/77836e08a2384450b5e7933094511b61e3c22140/lib/std/elf.zig#L948
pub const e_machine = enum(u16) {

    /// No machine
    _NONE = 0,

    /// AT&T WE 32100
    _M32 = 1,

    /// SPARC
    _SPARC = 2,

    /// Intel 386
    _386 = 3,

    /// Motorola 68000
    _68K = 4,

    /// Motorola 88000
    _88K = 5,

    /// Intel MCU
    _IAMCU = 6,

    /// Intel 80860
    _860 = 7,

    /// MIPS R3000
    _MIPS = 8,

    /// IBM System/370
    _S370 = 9,

    /// MIPS RS3000 Little-endian
    _MIPS_RS3_LE = 10,

    /// SPU Mark II
    _SPU_2 = 13,

    /// Hewlett-Packard PA-RISC
    _PARISC = 15,

    /// Fujitsu VPP500
    _VPP500 = 17,

    /// Enhanced instruction set SPARC
    _SPARC32PLUS = 18,

    /// Intel 80960
    _960 = 19,

    /// PowerPC
    _PPC = 20,

    /// PowerPC64
    _PPC64 = 21,

    /// IBM System/390
    _S390 = 22,

    /// IBM SPU/SPC
    _SPU = 23,

    /// NEC V800
    _V800 = 36,

    /// Fujitsu FR20
    _FR20 = 37,

    /// TRW RH-32
    _RH32 = 38,

    /// Motorola RCE
    _RCE = 39,

    /// ARM
    _ARM = 40,

    /// DEC Alpha
    _ALPHA = 41,

    /// Hitachi SH
    _SH = 42,

    /// SPARC V9
    _SPARCV9 = 43,

    /// Siemens TriCore
    _TRICORE = 44,

    /// Argonaut RISC Core
    _ARC = 45,

    /// Hitachi H8/300
    _H8_300 = 46,

    /// Hitachi H8/300H
    _H8_300H = 47,

    /// Hitachi H8S
    _H8S = 48,

    /// Hitachi H8/500
    _H8_500 = 49,

    /// Intel IA-64 processor architecture
    _IA_64 = 50,

    /// Stanford MIPS-X
    _MIPS_X = 51,

    /// Motorola ColdFire
    _COLDFIRE = 52,

    /// Motorola M68HC12
    _68HC12 = 53,

    /// Fujitsu MMA Multimedia Accelerator
    _MMA = 54,

    /// Siemens PCP
    _PCP = 55,

    /// Sony nCPU embedded RISC processor
    _NCPU = 56,

    /// Denso NDR1 microprocessor
    _NDR1 = 57,

    /// Motorola Star*Core processor
    _STARCORE = 58,

    /// Toyota ME16 processor
    _ME16 = 59,

    /// STMicroelectronics ST100 processor
    _ST100 = 60,

    /// Advanced Logic Corp. TinyJ embedded processor family
    _TINYJ = 61,

    /// AMD x86-64 architecture
    _X86_64 = 62,

    /// Sony DSP Processor
    _PDSP = 63,

    /// Digital Equipment Corp. PDP-10
    _PDP10 = 64,

    /// Digital Equipment Corp. PDP-11
    _PDP11 = 65,

    /// Siemens FX66 microcontroller
    _FX66 = 66,

    /// STMicroelectronics ST9+ 8/16 bit microcontroller
    _ST9PLUS = 67,

    /// STMicroelectronics ST7 8-bit microcontroller
    _ST7 = 68,

    /// Motorola MC68HC16 Microcontroller
    _68HC16 = 69,

    /// Motorola MC68HC11 Microcontroller
    _68HC11 = 70,

    /// Motorola MC68HC08 Microcontroller
    _68HC08 = 71,

    /// Motorola MC68HC05 Microcontroller
    _68HC05 = 72,

    /// Silicon Graphics SVx
    _SVX = 73,

    /// STMicroelectronics ST19 8-bit microcontroller
    _ST19 = 74,

    /// Digital VAX
    _VAX = 75,

    /// Axis Communications 32-bit embedded processor
    _CRIS = 76,

    /// Infineon Technologies 32-bit embedded processor
    _JAVELIN = 77,

    /// Element 14 64-bit DSP Processor
    _FIREPATH = 78,

    /// LSI Logic 16-bit DSP Processor
    _ZSP = 79,

    /// Donald Knuth's educational 64-bit processor
    _MMIX = 80,

    /// Harvard University machine-independent object files
    _HUANY = 81,

    /// SiTera Prism
    _PRISM = 82,

    /// Atmel AVR 8-bit microcontroller
    _AVR = 83,

    /// Fujitsu FR30
    _FR30 = 84,

    /// Mitsubishi D10V
    _D10V = 85,

    /// Mitsubishi D30V
    _D30V = 86,

    /// NEC v850
    _V850 = 87,

    /// Mitsubishi M32R
    _M32R = 88,

    /// Matsushita MN10300
    _MN10300 = 89,

    /// Matsushita MN10200
    _MN10200 = 90,

    /// picoJava
    _PJ = 91,

    /// OpenRISC 32-bit embedded processor
    _OPENRISC = 92,

    /// ARC International ARCompact processor (old spelling/synonym: EM_ARC_A5)
    _ARC_COMPACT = 93,

    /// Tensilica Xtensa Architecture
    _XTENSA = 94,

    /// Alphamosaic VideoCore processor
    _VIDEOCORE = 95,

    /// Thompson Multimedia General Purpose Processor
    _TMM_GPP = 96,

    /// National Semiconductor 32000 series
    _NS32K = 97,

    /// Tenor Network TPC processor
    _TPC = 98,

    /// Trebia SNP 1000 processor
    _SNP1K = 99,

    /// STMicroelectronics (www.st.com) ST200
    _ST200 = 100,

    /// Ubicom IP2xxx microcontroller family
    _IP2K = 101,

    /// MAX Processor
    _MAX = 102,

    /// National Semiconductor CompactRISC microprocessor
    _CR = 103,

    /// Fujitsu F2MC16
    _F2MC16 = 104,

    /// Texas Instruments embedded microcontroller msp430
    _MSP430 = 105,

    /// Analog Devices Blackfin (DSP) processor
    _BLACKFIN = 106,

    /// S1C33 Family of Seiko Epson processors
    _SE_C33 = 107,

    /// Sharp embedded microprocessor
    _SEP = 108,

    /// Arca RISC Microprocessor
    _ARCA = 109,

    /// Microprocessor series from PKU-Unity Ltd. and MPRC of Peking University
    _UNICORE = 110,

    /// eXcess: 16/32/64-bit configurable embedded CPU
    _EXCESS = 111,

    /// Icera Semiconductor Inc. Deep Execution Processor
    _DXP = 112,

    /// Altera Nios II soft-core processor
    _ALTERA_NIOS2 = 113,

    /// National Semiconductor CompactRISC CRX
    _CRX = 114,

    /// Motorola XGATE embedded processor
    _XGATE = 115,

    /// Infineon C16x/XC16x processor
    _C166 = 116,

    /// Renesas M16C series microprocessors
    _M16C = 117,

    /// Microchip Technology dsPIC30F Digital Signal Controller
    _DSPIC30F = 118,

    /// Freescale Communication Engine RISC core
    _CE = 119,

    /// Renesas M32C series microprocessors
    _M32C = 120,

    /// Altium TSK3000 core
    _TSK3000 = 131,

    /// Freescale RS08 embedded processor
    _RS08 = 132,

    /// Analog Devices SHARC family of 32-bit DSP processors
    _SHARC = 133,

    /// Cyan Technology eCOG2 microprocessor
    _ECOG2 = 134,

    /// Sunplus S+core7 RISC processor
    _SCORE7 = 135,

    /// New Japan Radio (NJR) 24-bit DSP Processor
    _DSP24 = 136,

    /// Broadcom VideoCore III processor
    _VIDEOCORE3 = 137,

    /// RISC processor for Lattice FPGA architecture
    _LATTICEMICO32 = 138,

    /// Seiko Epson C17 family
    _SE_C17 = 139,

    /// The Texas Instruments TMS320C6000 DSP family
    _TI_C6000 = 140,

    /// The Texas Instruments TMS320C2000 DSP family
    _TI_C2000 = 141,

    /// The Texas Instruments TMS320C55x DSP family
    _TI_C5500 = 142,

    /// STMicroelectronics 64bit VLIW Data Signal Processor
    _MMDSP_PLUS = 160,

    /// Cypress M8C microprocessor
    _CYPRESS_M8C = 161,

    /// Renesas R32C series microprocessors
    _R32C = 162,

    /// NXP Semiconductors TriMedia architecture family
    _TRIMEDIA = 163,

    /// Qualcomm Hexagon processor
    _HEXAGON = 164,

    /// Intel 8051 and variants
    _8051 = 165,

    /// STMicroelectronics STxP7x family of configurable and extensible RISC processors
    _STXP7X = 166,

    /// Andes Technology compact code size embedded RISC processor family
    _NDS32 = 167,

    /// Cyan Technology eCOG1X family
    _ECOG1X = 168,

    /// Dallas Semiconductor MAXQ30 Core Micro-controllers
    _MAXQ30 = 169,

    /// New Japan Radio (NJR) 16-bit DSP Processor
    _XIMO16 = 170,

    /// M2000 Reconfigurable RISC Microprocessor
    _MANIK = 171,

    /// Cray Inc. NV2 vector architecture
    _CRAYNV2 = 172,

    /// Renesas RX family
    _RX = 173,

    /// Imagination Technologies META processor architecture
    _METAG = 174,

    /// MCST Elbrus general purpose hardware architecture
    _MCST_ELBRUS = 175,

    /// Cyan Technology eCOG16 family
    _ECOG16 = 176,

    /// National Semiconductor CompactRISC CR16 16-bit microprocessor
    _CR16 = 177,

    /// Freescale Extended Time Processing Unit
    _ETPU = 178,

    /// Infineon Technologies SLE9X core
    _SLE9X = 179,

    /// Intel L10M
    _L10M = 180,

    /// Intel K10M
    _K10M = 181,

    /// ARM AArch64
    _AARCH64 = 183,

    /// Atmel Corporation 32-bit microprocessor family
    _AVR32 = 185,

    /// STMicroeletronics STM8 8-bit microcontroller
    _STM8 = 186,

    /// Tilera TILE64 multicore architecture family
    _TILE64 = 187,

    /// Tilera TILEPro multicore architecture family
    _TILEPRO = 188,

    /// NVIDIA CUDA architecture
    _CUDA = 190,

    /// Tilera TILE-Gx multicore architecture family
    _TILEGX = 191,

    /// CloudShield architecture family
    _CLOUDSHIELD = 192,

    /// KIPO-KAIST Core-A 1st generation processor family
    _COREA_1ST = 193,

    /// KIPO-KAIST Core-A 2nd generation processor family
    _COREA_2ND = 194,

    /// Synopsys ARCompact V2
    _ARC_COMPACT2 = 195,

    /// Open8 8-bit RISC soft processor core
    _OPEN8 = 196,

    /// Renesas RL78 family
    _RL78 = 197,

    /// Broadcom VideoCore V processor
    _VIDEOCORE5 = 198,

    /// Renesas 78KOR family
    _78KOR = 199,

    /// Freescale 56800EX Digital Signal Controller (DSC)
    _56800EX = 200,

    /// Beyond BA1 CPU architecture
    _BA1 = 201,

    /// Beyond BA2 CPU architecture
    _BA2 = 202,

    /// XMOS xCORE processor family
    _XCORE = 203,

    /// Microchip 8-bit PIC(r) family
    _MCHP_PIC = 204,

    /// Reserved by Intel
    _INTEL205 = 205,

    /// Reserved by Intel
    _INTEL206 = 206,

    /// Reserved by Intel
    _INTEL207 = 207,

    /// Reserved by Intel
    _INTEL208 = 208,

    /// Reserved by Intel
    _INTEL209 = 209,

    /// KM211 KM32 32-bit processor
    _KM32 = 210,

    /// KM211 KMX32 32-bit processor
    _KMX32 = 211,

    /// KM211 KMX16 16-bit processor
    _KMX16 = 212,

    /// KM211 KMX8 8-bit processor
    _KMX8 = 213,

    /// KM211 KVARC processor
    _KVARC = 214,

    /// Paneve CDP architecture family
    _CDP = 215,

    /// Cognitive Smart Memory Processor
    _COGE = 216,

    /// iCelero CoolEngine
    _COOL = 217,

    /// Nanoradio Optimized RISC
    _NORC = 218,

    /// CSR Kalimba architecture family
    _CSR_KALIMBA = 219,

    /// AMD GPU architecture
    _AMDGPU = 224,

    /// RISC-V
    _RISCV = 243,

    /// Lanai 32-bit processor
    _LANAI = 244,

    /// Linux kernel bpf virtual machine
    _BPF = 247,
    _,
};

pub const Ehdr = struct {
    identity: [std.elf.EI_NIDENT]u8,
    etype: e_type,
    machine: e_machine,
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
pub const Elf32_Ehdr = packed struct {
    e_ident: [std.elf.EI_NIDENT]u8,
    e_type: e_type,
    e_machine: e_machine,
    e_version: std.elf.Elf32_Word,
    e_entry: std.elf.Elf32_Addr,
    e_phoff: std.elf.Elf32_Off,
    e_shoff: std.elf.Elf32_Off,
    e_flags: std.elf.Elf32_Word,
    e_ehsize: std.elf.Elf32_Half,
    e_phentsize: std.elf.Elf32_Half,
    e_phnum: std.elf.Elf32_Half,
    e_shentsize: std.elf.Elf32_Half,
    e_shnum: std.elf.Elf32_Half,
    e_shstrndx: std.elf.Elf32_Half,
};
pub const Elf64_Ehdr = packed struct {
    e_ident: [std.elf.EI_NIDENT]u8,
    e_type: e_type,
    e_machine: e_machine,
    e_version: std.elf.Elf64_Word,
    e_entry: std.elf.Elf64_Addr,
    e_phoff: std.elf.Elf64_Off,
    e_shoff: std.elf.Elf64_Off,
    e_flags: std.elf.Elf64_Word,
    e_ehsize: std.elf.Elf64_Half,
    e_phentsize: std.elf.Elf64_Half,
    e_phnum: std.elf.Elf64_Half,
    e_shentsize: std.elf.Elf64_Half,
    e_shnum: std.elf.Elf64_Half,
    e_shstrndx: std.elf.Elf64_Half,
};
