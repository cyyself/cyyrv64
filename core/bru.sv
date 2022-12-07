`include "def.svh"

module bru(
    input        [63:0] in1,
    input        [63:0] in2,
    input  branch_op    op,
    output logic        is_taken
);

always_comb begin
    case (op)
        BEQ:  is_taken = in1 == in2;
        BNE:  is_taken = in1 != in2;
        BLT:  is_taken = $signed(in1) < $signed(in2);
        BGE:  is_taken = $signed(in1) >= $signed(in2);
        BLTU: is_taken = in1 < in2;
        BGEU: is_taken = in1 >= in2;
        default: begin
            is_taken = 1'b0;
        end
    endcase
end

endmodule
