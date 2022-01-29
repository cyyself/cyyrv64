module tb_top();

reg clk = 0;
reg rst = 1;

initial #100 rst = 0;

always #5 clk = ~clk;

pipeline pipeline(
    .clk    (clk),
    .rst    (rst)
);

endmodule