`include "def_common.vh"

module alu(
    input           [63:0]  in_a,
    input           [63:0]  in_b,
    input                   word32,
    input           [3:0]   aluctrl,
    output          [63:0]  result
);

wire [63:0] a = word32 ? {{32{in_a[31]}},in_a[31:0]} : in_a;
wire [63:0] b = word32 ? {{32{in_b[31]}},in_b[31:0]} : in_b;

logic [63:0] out;
assign result = word32 ? {{32{out[31]}},out[31:0]} : out;

always_comb begin
    case (aluctrl)
        `ALU_ADD:   out = a + b;
        `ALU_SUB:   out = a - b;
        `ALU_SLL:   out = a << b;
        `ALU_SLT:   out = {63'd0,$signed(a) < $signed(b)};
        `ALU_SLTU:  out = {63'd0,a < b};
        `ALU_XOR:   out = a ^ b;
        `ALU_SRL:   out = a >> b;
        `ALU_SRA:   out = $signed(a) >> b;
        `ALU_OR:    out = a | b;
        `ALU_AND:   out = a & b;
        `ALU_IMM:   out = b;
        default:    out = 0;
    endcase
end

endmodule