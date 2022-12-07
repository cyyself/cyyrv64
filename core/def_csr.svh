`ifndef CSR_DEF
`define CSR_DEF

`include "def.svh"

typedef enum logic [11:0] {
// Unprivileged Counter/Timers
    CSR_CYCLE   = 12'hc00,
    CSR_INSTRET = 12'hc02,
// Machine Information Registers
    CSR_MVENDORID   = 12'hf11,
    CSR_MARCHID = 12'hf12,
    CSR_MIMPID  = 12'hf13,
    CSR_MHARTID = 12'hf14,
    CSR_MCONFIGPTR  = 12'hf15,
// Machine Trap Setup
    CSR_MSTATUS = 12'h300,
    CSR_MISA    = 12'h301,
    CSR_MIE     = 12'h304,
    CSR_MTVEC   = 12'h305,
    CSR_MCOUNTEREN  = 12'h306,
// Machine Trap Handling
    CSR_MSCRATCH= 12'h340,
    CSR_MEPC    = 12'h341,
    CSR_MCAUSE  = 12'h342,
    CSR_MTVAL   = 12'h343,
    CSR_MIP     = 12'h344,
// Machine Counter/Timers
    CSR_MCYCLE  = 12'hb00,
    CSR_MINSTRET= 12'hb02,
    CSR_TSELECT = 12'h7a0,
    CSR_TDATA1  = 12'h7a1
} rv_addr;

typedef struct packed {
    logic [1:0] mxl;
    logic [35:0] blank;
    logic [25:0] ext;
} csr_misa;

typedef struct packed {
    logic           sd;  // no vs,fs,xs zero
    logic [24: 0]   wpri0;
    logic           mbe;
    logic           sbe;
    logic [ 1: 0]   sxl; // supervisor xlen
    logic [ 1: 0]   uxl; // user xlen
    logic [ 8: 0]   wpri1;
    logic           tsr; // Trap SRET
    logic           tw;  // Timeout Wait for WFI
    logic           tvm; // Trap Virtual Memory (raise trap when sfence.vma and sinval.vma executing in S-Mode)
    logic           mxr; // Make eXecutable Readable
    logic           sum; // permit Supervisor User Memory access
    logic           mprv;// Modify PRiVilege (Turn on virtual memory and protection for load/store in M-Mode) when mpp is not M-Mode
    logic [ 1: 0]   xs;  // without user ext, zero
    logic [ 1: 0]   fs;  // without float, zero
    logic [ 1: 0]   mpp; // machine previous privilege mode.
    logic [ 1: 0]   vs;  // without vector, zero
    logic           spp; // supervisor previous privilege mode.
    logic           mpie;// mie prior to trapping
    logic           ube; // u big-endian, zero
    logic           spie;// sie prior to trapping
    logic           wpri2;
    logic           mie;
    logic           wpri3;
    logic           sie;
    logic           wpri4;
} csr_status;

typedef struct packed {
    logic [63:12]   blank0;
    logic           MEIP;
    logic           blank1;
    logic           SEIP;
    logic           blank2;
    logic           MTIP;
    logic           blank3;
    logic           STIP;
    logic           blank4;
    logic           MSIP;
    logic           blank5;
    logic           SSIP;
    logic           blank6;
} csr_ip;

typedef struct packed {
    logic is_int;
    union packed{
        exc_code        exc;
        logic [62:0]    intr;
    } tval;
} csr_cause;

typedef enum logic [1:0] {
    TMODE_DIRECT    = 2'd0,
    TMODE_VECTORED  = 2'd1
} trap_mode;

typedef struct packed {
    logic [63:2] base;
    trap_mode    mode;
} csr_tvec;

interface csr_bus;
    logic   csr_en; // csr_en should make sure that this instruction will retire
    csr_op  op;
    logic   [11:0]  csr_addr;
    logic   [63:0]  rdata;
    logic   [63:0]  wdata;
    logic           trap_ill; // trap illegal instruction
    modport master(output csr_en, op, csr_addr, wdata, input rdata, trap_ill);
    modport slave (output rdata, trap_ill, input csr_en, op, csr_addr, wdata);
endinterface

`endif

