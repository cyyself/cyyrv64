// branch logic unit
`include "def_inst.vh"
module blu(
    input           [63:0]  in_a,
    input           [63:0]  in_b,
    input            [2:0]  funct3,
    output logic            taken
);

always_comb begin
    case(funct3)
        `FUNCT3_BEQ:    taken = in_a == in_b;
        `FUNCT3_BNE:    taken = in_a != in_b;
        `FUNCT3_BLT:    taken = $signed(in_a) < $signed(in_b);
        `FUNCT3_BGE:    taken = $signed(in_a) >= $signed(in_b);
        `FUNCT3_BLTU:   taken = in_a < in_b;
        `FUNCT3_BGEU:   taken = in_a >= in_b;
        default:        taken = 0;
    endcase
end

endmodule