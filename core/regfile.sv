`include "def.svh"

// assume 5-stage pipeline, only forward from exe, mem to id
module regfile(
    input               clock,
    input               reset,
    gpr_read.slave      gpr_if,
    gpr_forward.slave   ex,
    gpr_forward.slave   me,
    gpr_commit.slave    wb
);

reg [63:0] gpr [31:0];

wire rs1_read_busy = gpr_if.rs1_en && (|gpr_if.rs1) && (
    (ex.rd == gpr_if.rs1 && ex.rd_en && !ex.rd_forward) || (me.rd == gpr_if.rs1 && me.rd_en && !me.rd_forward) );

wire rs2_read_busy = gpr_if.rs2_en && (|gpr_if.rs2) && (
    (ex.rd == gpr_if.rs2 && ex.rd_en && !ex.rd_forward) || (me.rd == gpr_if.rs2 && me.rd_en && !me.rd_forward) );

assign gpr_if.reg_read_busy = rs1_read_busy || rs2_read_busy;

assign gpr_if.rs1_value = 
    (gpr_if.rs1 == 0)                   ?   0            :
    (ex.rd == gpr_if.rs1 && ex.rd_en) ?   ex.rd_value : 
    (me.rd == gpr_if.rs1 && me.rd_en) ?   me.rd_value : 
    (wb.rd  == gpr_if.rs1 && wb.rd_en)  ?    wb.rd_value : gpr[gpr_if.rs1];

assign gpr_if.rs2_value = 
    (gpr_if.rs2 == 0)                   ?   0            :
    (ex.rd == gpr_if.rs2 && ex.rd_en) ?   ex.rd_value : 
    (me.rd == gpr_if.rs2 && me.rd_en) ?   me.rd_value : 
    (wb.rd  == gpr_if.rs2 && wb.rd_en)  ?    wb.rd_value : gpr[gpr_if.rs2];

always_ff @(posedge clock) begin
    if (reset) begin
        gpr <= '{default: 0};
    end
    else begin
        if (wb.rd_en && |wb.rd) gpr[wb.rd] <= wb.rd_value;
    end
end

endmodule
