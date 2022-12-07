`include "def.svh"

module mul(
    input               clock,
    input               reset,
    input        [63:0] in1,
    input        [63:0] in2,
    input               mul_word, // 0: 64-bit, 1: 32-bit
    input               en,
    input        mul_op op,
    output       [63:0] out,
    output              out_valid,
    input               out_ready
);

// preprocessing {

// sign ext for 32-bit
wire [63:0] in1_ext = mul_word ? {{33{in1[31]}},in1[30:0]} : in1;
wire [63:0] in2_ext = mul_word ? {{33{in2[31]}},in2[30:0]} : in2;

// get sign
wire in1_sign = in1_ext[63];
wire in2_sign = in2_ext[63];

// cal abs
wire [63:0] in1_abs = in1_sign ? -in1_ext : in1_ext;
wire [63:0] in2_abs = in2_sign ? -in2_ext : in2_ext;

// preprocessing }

// metadata {
enum {IDLE, CAL, FINAL} state;
reg out_sign;
reg out_word;
reg out_high;
reg [63:0] in1_cal;
reg [63:0] in2_cal;
reg [63:0] mid_result [3:0];
// metadata }

assign out_valid = state == FINAL;

wire [127:0] final_unsigned = ({mid_result[3],64'd0}) + ({32'd0,mid_result[2],32'd0}) + ({32'd0,mid_result[1],32'd0}) + {64'd0,mid_result[0]};
wire [127:0] final_signed   = out_sign ? (-final_unsigned) : final_unsigned;

assign out = out_word ? (out_high ? {{33{final_signed[63]}},final_signed[62:32]} : {{33{final_signed[31]}},final_signed[30:0]}) : (out_high ? final_signed[127:64] : final_signed[63:0]);

always_ff @(posedge clock) begin
    if (reset) begin
        state <= IDLE;
        out_sign <= 0;
        out_word <= 0;
        out_high <= 0;
        in1_cal <= 0;
        in2_cal <= 0;
        mid_result <= '{default: '0};
    end
    else begin
        case (state)
            IDLE: begin
                if (en) begin
                    out_word <= mul_word;
                    state <= CAL;
                    case (op)
                        MUL: begin
                            out_sign <= 0;
                            out_high <= 0;
                            in1_cal  <= in1_ext;
                            in2_cal  <= in2_ext;
                        end
                        MULH: begin
                            out_sign <= in1_sign ^ in2_sign;
                            out_high <= 1'b1;
                            in1_cal  <= in1_abs;
                            in2_cal  <= in2_abs;
                        end
                        MULHU: begin
                            out_sign <= 0;
                            out_high <= 1'b1;
                            in1_cal  <= in1_ext;
                            in2_cal  <= in2_ext;
                        end
                        MULHSU: begin
                            out_sign <= in1_sign;
                            out_high <= 1'b1;
                            in1_cal  <= in1_abs;
                            in2_cal  <= in2_ext;
                        end
                        default: begin
                            // Don't Care
                        end
                    endcase
                end
            end
            CAL: begin
                mid_result[0] <= in1_cal[31: 0] * in2_cal[31: 0];
                mid_result[1] <= in1_cal[63:32] * in2_cal[31: 0];
                mid_result[2] <= in1_cal[31: 0] * in2_cal[63:32];
                mid_result[3] <= in1_cal[63:32] * in2_cal[63:32];
                state <= FINAL;
            end
            FINAL: begin
                if (out_ready) state <= IDLE;
            end
            default: begin
            end
        endcase
    end
end

endmodule
