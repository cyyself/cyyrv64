`include "def.svh"

module alu(
    input        [63:0] in1,
    input        [63:0] in2,
    input               is_word, // 0: 64-bit, 1: 32-bit
    input  alu_op       op,
    output       [63:0] out
);

wire [63:0] in1_ext = is_word ? {{33{in1[31]}},in1[30:0]} : in1;
wire [63:0] in2_ext = is_word ? {{33{in2[31]}},in2[30:0]} : in2;

wire [5:0]  shamt = {is_word?1'b0:in2[5],in2[4:0]};
wire [63:0] srl_in1 = is_word ? {32'd0,in1[31:0]} : in1[63:0];
wire [63:0] sra_in1 = is_word ? {{32{in1[31]}},in1[31:0]} : in1[63:0];

logic [63:0] res;


assign out = is_word ? {{33{res[31]}},res[30:0]} : res;

always_comb begin
    case (op)
        ADD:  res = in1_ext + in2_ext;
        SUB:  res = in1_ext - in2_ext;
        SLL:  res = in1_ext << shamt;
        SLT:  res = {63'd0,$signed(in1_ext) < $signed(in2_ext)};
        SLTU: res = {63'd0,in1_ext < in2_ext};
        XOR:  res = in1_ext ^ in2_ext;
        SRL:  res = srl_in1 >> shamt;
        SRA:  res = $signed(sra_in1) >>> shamt;
        OR:   res = in1_ext | in2_ext;
        AND:  res = in1_ext & in2_ext;
        default: begin
            res = 0;
        end
    endcase
end

endmodule
