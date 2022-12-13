`include "def.svh"
`include "def_csr.svh"

module csr #(
    parameter hart_id = 0
) (
    input               clock,
    input               reset,
    input  hart_int     ext_int,
    input               ready_instret, // for counting instret
    output rv_priv      cur_priv_mode,
    trap_bus.slave      trap_if,
    csr_bus.slave       csr_if,
    trap_pc_bus.master  trap_pc_if,
    async_irq.master    async_irq_if
);


//csr regs {

// csr wired
`ifdef ENABLE_AMO
csr_misa        misa = '{default: '0, mxl: 2'd2, ext: 26'h101101}; // imau
`else
csr_misa        misa = '{default: '0, mxl: 2'd2, ext: 26'h101100}; // imu
`endif
// csr regs
csr_status      status;
csr_ip          ip;
csr_cause       mcause;
csr_tvec        mtvec;
csr_ip          ie;
logic [63:0]    cycle;
logic [63:0]    instret;
logic [63:0]    mscratch;
logic [63:0]    mepc;
logic [63:0]    mtval;

// oob regs
rv_priv         priv_mode;

//csr regs }

assign cur_priv_mode = priv_mode;   

// Note: If S-Mode implemented, there will be more CSRs and alias with masks.

always_comb begin // read and permission check

    // do permission check {
    
    csr_if.trap_ill = 1'b0; // initially set to 0

    if (csr_if.csr_en && priv_mode != MACHINE_MODE) csr_if.trap_ill = 1'b1; // trap ill when mode is not machine mode.
    // This is a simple trick to implement a M/U mode only machine with mcounteren is read-only zero.

    if (csr_if.csr_en && csr_if.op != CSR_READ && csr_if.csr_addr[11:10] == 2'd3) csr_if.trap_ill = 1'b1;
    // according to spec, when csr[11:10] is 0b11 is read-only csrs.

    // do permission check }

    // do read {
    case (csr_if.csr_addr)
        CSR_CYCLE:      csr_if.rdata = cycle;
        CSR_INSTRET:    csr_if.rdata = instret;
        CSR_MVENDORID:  csr_if.rdata = 0;
        CSR_MARCHID:    csr_if.rdata = 0;
        CSR_MIMPID:     csr_if.rdata = 0;
        CSR_MHARTID:    csr_if.rdata = hart_id;
        CSR_MCONFIGPTR: csr_if.rdata = 0;
        CSR_MSTATUS:    csr_if.rdata = status;
        CSR_MISA:       csr_if.rdata = misa;
        CSR_MIE:        csr_if.rdata = ie;
        CSR_MTVEC:      csr_if.rdata = mtvec;
        CSR_MCOUNTEREN: csr_if.rdata = 0;
        CSR_MSCRATCH:   csr_if.rdata = mscratch;
        CSR_MEPC:       csr_if.rdata = mepc;
        CSR_MCAUSE:     csr_if.rdata = mcause;
        CSR_MTVAL:      csr_if.rdata = mtval;
        CSR_MIP:        csr_if.rdata = ip;
        CSR_MCYCLE:     csr_if.rdata = cycle;
        CSR_MINSTRET:   csr_if.rdata = instret;
        CSR_TSELECT:    csr_if.rdata = 1; // a trick to pass risc-v test
        CSR_TDATA1:     csr_if.rdata = 0;
        default: begin
            csr_if.rdata = 0;
            if (csr_if.csr_en) csr_if.trap_ill = 1'b1;
        end
    endcase
    // do read }
end

always_comb begin // trap address generator
    trap_pc_if.trap_en = 1'b0;
    trap_pc_if.trap_pc = 0;
    if (trap_if.trap_en) begin
        trap_pc_if.trap_en = 1'b1;
        trap_pc_if.trap_pc = {mtvec.base,2'd00} + (mtvec.mode == TMODE_VECTORED ? trap_if.cause[3:0] * 4: 0);
    end
    else if (trap_if.mret_en) begin
        trap_pc_if.trap_en = 1'b1;
        trap_pc_if.trap_pc = mepc;
    end
end

csr_ip int_check;
assign int_check = ip & ie;
always_comb begin // interrupt generator
    async_irq_if.irq_type = 0;
    if ((priv_mode != MACHINE_MODE || status.mie) && |int_check) begin
        async_irq_if.irq = 1'b1;
        if (int_check[{2'd0,INT_MSI}]) async_irq_if.irq_type = INT_MSI;
        else if (int_check[{2'd0,INT_MTI}]) async_irq_if.irq_type = INT_MTI;
        else if (int_check[{2'd0,INT_MEI}]) async_irq_if.irq_type = INT_MEI;
        else assert(1'b0);
    end
    else async_irq_if.irq = 1'b0;
end

csr_status mstatus_wdata;
assign mstatus_wdata = csr_wdata_final;

csr_tvec mtvec_wdata;
assign mtvec_wdata = csr_wdata_final;

logic [63:0] csr_wdata_final;
always_comb begin // csr write data prepare
    case (csr_if.op)
        CSR_WRITE:      csr_wdata_final = csr_if.wdata;
        CSR_SETBIT:     csr_wdata_final = csr_if.rdata | csr_if.wdata;
        CSR_CLEARBIT:   csr_wdata_final = csr_if.rdata & (~csr_if.wdata);
        default:        csr_wdata_final = 0;
    endcase
end

always_ff @(posedge clock) begin
    if (reset) begin
        status <= '{default: '0, uxl: 2'd2};
        ip <= '{default: '0};
        mcause <= 64'd0;
        mtvec <= '{default: '0};
        ie <= 0;
        cycle <= 0;
        instret <= 0;
        mscratch <= 0;
        mepc <= 0;
        mtval <= 0;
        priv_mode <= MACHINE_MODE;
    end
    else begin
        // Update counter, whatever it will replaced by CSR writes
        cycle <= cycle + 1;
        if (ready_instret) instret <= instret + 1;
        // Update interrupts
        ip.MEIP <= ext_int.MEI;
        ip.MTIP <= ext_int.MTI;
        ip.MSIP <= ext_int.MSI;
        // do csr op {
        if (csr_if.csr_en && !csr_if.trap_ill && csr_if.op != CSR_READ) begin
            case (csr_if.csr_addr)
                CSR_MSTATUS: begin
                    status.mie  <= mstatus_wdata.mie;
                    status.mpie <= mstatus_wdata.mpie;
                    status.mpp  <= (mstatus_wdata.mpp == MACHINE_MODE || mstatus_wdata.mpp == USER_MODE) ? mstatus_wdata.mpp : 0;
                    status.mprv <= mstatus_wdata.mprv; // As we don't neither PMP nor MMU, so set to mprv has no side effect. 
                end
                CSR_MIE: begin
                    ie.MEIP     <= csr_wdata_final[{2'd0,INT_MEI}];
                    ie.MSIP     <= csr_wdata_final[{2'd0,INT_MSI}];
                    ie.MTIP     <= csr_wdata_final[{2'd0,INT_MTI}];
                end
                CSR_MTVEC: begin
                    mtvec.base  <= mtvec_wdata.base;
                    mtvec.mode  <= (mtvec_wdata.mode == 0 || mtvec_wdata.mode == 1) ? mtvec_wdata.mode : 0;
                end
                CSR_MSCRATCH:   mscratch<= csr_wdata_final;
                CSR_MEPC:       mepc    <= csr_wdata_final;
                CSR_MCAUSE:     mcause  <= csr_wdata_final;
                CSR_MTVAL:      mtval   <= csr_wdata_final;
                CSR_MCYCLE:     cycle   <= csr_wdata_final;
                default: begin
                end
            endcase
        end
        // do csr op }
        // do exception and mret {
        if (trap_if.trap_en) begin
            mcause      <= trap_if.cause;
            mtval       <= trap_if.tval;
            mepc        <= trap_if.pc;
            status.mpie <= status.mie;
            status.mie  <= 0;
            status.mpp  <= priv_mode;
            priv_mode   <= MACHINE_MODE;
        end
        else if (trap_if.mret_en) begin
            status.mie  <= status.mpie;
            status.mpie <= 1'b1;
            priv_mode   <= status.mpp;
            if (status.mpp != MACHINE_MODE) status.mprv <= 0;
            status.mpp  <= 0;
        end
        // do exception and mret }
    end
end

endmodule
