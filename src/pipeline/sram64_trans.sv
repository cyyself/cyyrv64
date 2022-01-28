`include "def_inst.vh"
module sram64_trans(
    input         [2:0] funct3,
    input        [63:0] writedata,
    output logic [63:0] readdata,
    input        [63:0] memaddr,
    input               mem_write,
    // sram interface
    output        [7:0] sram_wea,
    output logic [63:0] sram_dina,
    input        [63:0] sram_douta
);

always_comb begin : read_translate
    case (funct3)
        `FUNCT3_LB:
            readdata = {{56{sram_douta[{memaddr[2:0],3'b111}]}},sram_douta[{memaddr[2:0],3'd0} +: 8]};
        `FUNCT3_LBU:
            readdata = {56'd0,sram_douta[{memaddr[2:0],3'd0} +: 8]};
        `FUNCT3_LH:
            readdata = {{48{sram_douta[{memaddr[2:1],4'b1111}]}},sram_douta[{memaddr[2:1],4'd0} +: 16]};
        `FUNCT3_LHU:
            readdata = {48'd0,sram_douta[{memaddr[2:1],4'd0} +: 16]};
        `FUNCT3_LW:
            readdata = {{32{sram_douta[{memaddr[2],5'b11111}]}}, sram_douta[{memaddr[2],5'd0} +: 32]};
        `FUNCT3_LWU:
            readdata = {32'd0,sram_douta[{memaddr[2],5'd0} +: 32]};
        `FUNCT3_LD:
            readdata = sram_douta;
        default:
            readdata = 0;
    endcase
end

always_comb begin : write_translate
    if (mem_write) begin
        case (funct3)
            `FUNCT3_SB: begin
                sram_wea    = (8'b1 << {5'd0,memaddr[2:0]});
                sram_dina   = {56'd0,writedata[7:0]} << {58'd0,memaddr[2:0],3'd0};
            end
            `FUNCT3_SH: begin
                sram_wea    = (8'b00000011 << {5'd0,memaddr[2:1],1'b0});
                sram_dina   = {48'd0,writedata[15:0]} << {58'd0,memaddr[2:1],4'd0};
            end
            `FUNCT3_SW: begin
                sram_wea    = (8'b00001111 << {5'd0,memaddr[2],2'd0});
                sram_dina   = {32'd0,writedata[31:0]} << {58'd0,memaddr[2],5'd0};
            end
            `FUNCT3_SD: begin
                sram_wea    = 8'b11111111;
                sram_dina   = writedata;
            end
            default: begin
                sram_wea    = 0;
                sram_dina   = 0;
            end
        endcase
    end
    else begin
        sram_wea    = 0;
        sram_dina   = 0;
    end
end

endmodule