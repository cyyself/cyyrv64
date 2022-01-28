`include "def_common.vh"

module alu(
    input           [63:0]  in_a,
    input           [63:0]  in_b,
    input                   word32,
    input           [3:0]   aluctrl,
    output logic    [63:0]  result
);

wire [63:0] a = word32 ? {{32{in_a[31]}},in_a[31:0]} : in_a;
wire [63:0] b = word32 ? {{32{in_b[31]}},in_b[31:0]} : in_b;

always_comb begin
    case (aluctrl)
        `ALU_ADD:   result = a + b;
        `ALU_SUB:   result = a - b;
        `ALU_SLL:   result = a << b;
        `ALU_SLT:   result = {63'd0,$signed(a) < $signed(b)};
        `ALU_SLTU:  result = {63'd0,a < b};
        `ALU_XOR:   result = a ^ b;
        `ALU_SRL:   result = a >> b;
        `ALU_SRA:   result = $signed(a) >> b;
        `ALU_OR:    result = a | b;
        `ALU_AND:   result = a & b;
        `ALU_IMM:   result = b;
        default:    result = 0;
    endcase
end

endmodule