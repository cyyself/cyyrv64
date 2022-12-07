`include "def.svh"

module div(
    input               clock,
    input               reset,
    input        [63:0] in1,
    input        [63:0] in2,
    input               div_word, // 0: 64-bit, 1: 32-bit
    input               en,
    input        div_op op,
    output       [63:0] out,
    output              out_valid,
    input               out_ready
);

// preprocessing {

wire is_unsigned = op == DIVU || op == REMU;
wire is_rem     = op == REM || op == REMU;

// sign ext for 32-bit
wire [63:0] in1_ext = div_word ? {{33{in1[31]}},in1[30:0]} : in1;
wire [63:0] in2_ext = div_word ? {{33{in2[31]}},in2[30:0]} : in2;

// check overflow
wire in1_is_neg_inf = div_word ? (in1[31:0] == 32'h80000000) : (in1[63:0] == 64'h8000_0000_0000_0000);
wire in2_is_neg_one = in2_ext == 64'hffff_ffff_ffff_ffff;
wire in2_is_zero    = in2_ext == 0;

// get sign
wire in1_sign = in1_ext[63];
wire in2_sign = in2_ext[63];

// cal abs
wire [63:0] in1_abs_32 = {32'd0,in1[31] ? ((~in1[31:0])+1) : in1[31:0]};
wire [63:0] in2_abs_32 = {32'd0,in2[31] ? ((~in2[31:0])+1) : in2[31:0]};

wire [63:0] in1_abs_64 = in1[63] ? ((~in1)+1) : in1;
wire [63:0] in2_abs_64 = in2[63] ? ((~in2)+1) : in2;

wire [63:0] in1_abs = div_word ? in1_abs_32 : in1_abs_64;
wire [63:0] in2_abs = div_word ? in2_abs_32 : in2_abs_64;

// uext
wire [63:0] in1_uext = div_word ? {32'd0,in1[31:0]} : in1[63:0];
wire [63:0] in2_uext = div_word ? {32'd0,in2[31:0]} : in2[63:0];


wire [63:0] final_in1 = is_unsigned ? in1_uext : in1_abs;
wire [63:0] final_in2 = is_unsigned ? in2_uext : in2_abs;
// preprocessing }

// metadata {
enum {IDLE, CAL, FINAL} state;
reg div_sign;
reg rem_sign;
reg out_word;
reg out_rem;

reg [127:0] dividend_shifted; // reuse lower bits as result
reg [63:0]  divisor;
reg [5:0]   div_count;
wire [64:0] try_divide = {dividend_shifted[126:63]} - {1'b0,divisor};
// metadata }

// output {
assign out_valid = state == FINAL;
wire [63:0] result_s = div_sign ? -dividend_shifted[63:0] : dividend_shifted[63:0];
wire [63:0] result   = out_word ? {{33{result_s[31]}},result_s[30:0]} : result_s;
wire [63:0] rem_s    = rem_sign ? -dividend_shifted[127:64] : dividend_shifted[127:64];
wire [63:0] rem      = out_word ? {{33{rem_s[31]}},rem_s[30:0]} : rem_s;
assign out            = out_rem  ? rem : result;
// output }



// FSM
always_ff @(posedge clock) begin
    if (reset || !en) begin
        state <= IDLE;
        div_sign <= 0;
        rem_sign <= 0;
        out_word <= 0;
        out_rem  <= 0;
        dividend_shifted <= 0;
        divisor <= 0;
        div_count <= 0;
    end
    else begin
        case (state)
            IDLE: begin
                div_sign <= is_unsigned ? 1'b0 : in1_sign ^ in2_sign;
                rem_sign <= is_unsigned ? 1'b0 : in1_sign;
                out_word <= div_word;
                out_rem <= is_rem;
                dividend_shifted <= {63'd0,final_in1,1'd0};
                divisor <= final_in2;
                if (in2_is_zero) begin
                    // for divisor == 0, result = 2**L-1(unsigned), rem = x
                    dividend_shifted <= {in1_ext, 64'hffff_ffff_ffff_ffff};
                    div_sign <= 0;
                    rem_sign <= 0;
                    state <= FINAL;
                end
                else if (!is_unsigned && in1_is_neg_inf && in2_is_neg_one) begin
                    // for div(w)/rem(w), dividend is -inf and divisor is -1, output should be inf + 1 but will overflow, so follow the spec. div = -inf, rem = 0.
                    dividend_shifted <= {64'd0, in1_ext};
                    state <= FINAL;
                end
                else begin
                    state <= CAL;
                    dividend_shifted <= {64'd0,final_in1};
                    div_count <= 0;
                end
            end
            CAL: begin
                if (try_divide[64]) begin // cannot divide
                    dividend_shifted <= {dividend_shifted[126:0],1'b0};
                end
                else begin
                    dividend_shifted <= {try_divide[63:0],dividend_shifted[62:0],1'b1};
                end
                div_count <= div_count + 1;
                if (div_count == 6'd63) state <= FINAL;
            end
            FINAL: begin
                if (out_ready) state <= IDLE;
            end
        endcase
    end
end

endmodule
