module pc_gen_stage(
    input           clock,
    input           reset,
    input [63:0]    if_pc,
    input [63:0]    mem_pc,
    input           mem_pc_en,
    output [63:0]   pc_next
);

reg is_reset;

always_ff @(posedge clock) begin
    if (reset) is_reset <= 1;
    else is_reset <= 0;
end

assign pc_next = 
    is_reset  ? 64'h60000000 : 
    mem_pc_en ? mem_pc       :
    if_pc + 4;

endmodule
