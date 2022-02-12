module tb_top();

reg clk = 0;
reg rst = 1;

initial #100 rst = 0;

always #5 clk = ~clk;

sim_soc_top soc_top(
    .clk            (clk),
    .rst            (rst),
    .uart_tx_data   (),
    .uart_tx_valid  (),
    .uart_tx_ready  (1'b1),
    .uart_rx_data   (0),
    .uart_rx_valid  (0),
    .uart_rx_ready  ()
);

endmodule