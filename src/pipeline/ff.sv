module ff #(
    parameter WIDTH = 32
) (
    input                       clk,
    input                       rst,
    input                       flush,
    input                       stall,
    input        [WIDTH-1:0]    data_in,
    output       [WIDTH-1:0]    data_out
);

reg [WIDTH-1:0] data = 0;

assign data_out = data;

always_ff @(posedge clk) begin
    if (rst | flush) data <= 0;
    else if (stall) data <= data_in;
    else data <= data_in;
end

endmodule