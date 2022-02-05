module seg7_phy #(
    parameter nr_digit = 8,
    parameter nr_clk = 13
) (
    input                   clk,
    input  [4*nr_digit-1:0] data,
    output [nr_digit-1:0]   AN,
    output                  CA,
    output                  CB,
    output                  CC,
    output                  CD,
    output                  CE,
    output                  CF,
    output                  CG,
    output                  DP
);

assign DP = 1'b1;

logic [$clog2(nr_digit)-1:0] cur_idx = 0;


wire [3:0] current_data = data[{cur_idx,2'd0} +: 4];

logic [nr_clk-1:0] counter = 0;

always_ff @(posedge clk) begin
    counter <= counter + 1;
    if (counter == 0) cur_idx <= cur_idx + 1;
end

assign AN = ~({{(nr_digit-1){1'b0}},1'b1} << cur_idx);

wire H   = 1'b1;
wire HHH = H;
wire o   = 1'b0;
wire ooH = o;
wire HoH = o;
wire Hoo = o;
wire ooo = o;

logic [6:0] n;
assign {CG,CF,CE,CD,CC,CB,CA} = ~n;

always_comb begin
    case (current_data)
        4'h0: begin
            {   n[0]  } = {HHH};
            {n[5],n[1]} = {H,H};
            {   n[6]  } = {HoH};
            {n[4],n[2]} = {H,H};
            {   n[3]  } = {HHH};
        end
        4'h1: begin
            {   n[0]  } = {ooH};
            {n[5],n[1]} = {o,H};
            {   n[6]  } = {ooH};
            {n[4],n[2]} = {o,H};
            {   n[3]  } = {ooH};
        end
        4'h2: begin
            {   n[0]  } = {HHH};
            {n[5],n[1]} = {o,H};
            {   n[6]  } = {HHH};
            {n[4],n[2]} = {H,o};
            {   n[3]  } = {HHH};
        end
        4'h3: begin
            {   n[0]  } = {HHH};
            {n[5],n[1]} = {o,H};
            {   n[6]  } = {HHH};
            {n[4],n[2]} = {o,H};
            {   n[3]  } = {HHH};
        end
        4'h4: begin
            {   n[0]  } = {HoH};
            {n[5],n[1]} = {H,H};
            {   n[6]  } = {HHH};
            {n[4],n[2]} = {o,H};
            {   n[3]  } = {ooH};
        end
        4'h5: begin
            {   n[0]  } = {HHH};
            {n[5],n[1]} = {H,o};
            {   n[6]  } = {HHH};
            {n[4],n[2]} = {o,H};
            {   n[3]  } = {HHH};
        end
        4'h6: begin
            {   n[0]  } = {HHH};
            {n[5],n[1]} = {H,o};
            {   n[6]  } = {HHH};
            {n[4],n[2]} = {H,H};
            {   n[3]  } = {HHH};
        end
        4'h7: begin
            {   n[0]  } = {HHH};
            {n[5],n[1]} = {o,H};
            {   n[6]  } = {ooH};
            {n[4],n[2]} = {o,H};
            {   n[3]  } = {ooH};
        end
        4'h8: begin
            {   n[0]  } = {HHH};
            {n[5],n[1]} = {H,H};
            {   n[6]  } = {HHH};
            {n[4],n[2]} = {H,H};
            {   n[3]  } = {HHH};
        end
        4'h9: begin
            {   n[0]  } = {HHH};
            {n[5],n[1]} = {H,H};
            {   n[6]  } = {HHH};
            {n[4],n[2]} = {o,H};
            {   n[3]  } = {HHH};
        end
        4'ha: begin
            {   n[0]  } = {HHH};
            {n[5],n[1]} = {H,H};
            {   n[6]  } = {HHH};
            {n[4],n[2]} = {H,H};
            {   n[3]  } = {HoH};
        end
        4'hb: begin
            {   n[0]  } = {Hoo};
            {n[5],n[1]} = {H,o};
            {   n[6]  } = {HHH};
            {n[4],n[2]} = {H,H};
            {   n[3]  } = {HHH};
        end
        4'hc: begin
            {   n[0]  } = {HHH};
            {n[5],n[1]} = {H,o};
            {   n[6]  } = {Hoo};
            {n[4],n[2]} = {H,o};
            {   n[3]  } = {HHH};
        end
        4'hd: begin
            {   n[0]  } = {ooH};
            {n[5],n[1]} = {o,H};
            {   n[6]  } = {HHH};
            {n[4],n[2]} = {H,H};
            {   n[3]  } = {HHH};
        end
        4'he: begin
            {   n[0]  } = {HHH};
            {n[5],n[1]} = {H,o};
            {   n[6]  } = {HHH};
            {n[4],n[2]} = {H,o};
            {   n[3]  } = {HHH};
        end
        4'hf: begin
            {   n[0]  } = {HHH};
            {n[5],n[1]} = {H,o};
            {   n[6]  } = {HHH};
            {n[4],n[2]} = {H,o};
            {   n[3]  } = {Hoo};
        end
        default: begin
            {   n[0]  } = {ooo};
            {n[5],n[1]} = {o,o};
            {   n[6]  } = {ooo};
            {n[4],n[2]} = {o,o};
            {   n[3]  } = {ooo};
        end
    endcase
end


endmodule
