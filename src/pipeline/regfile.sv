module regfile(
    input           clk,
    input           rst,
    // read port 1
    input  [4:0]    read_addr1,
    output [63:0]   read_data1,
    // read port 2
    input  [4:0]    read_addr2,
    output [63:0]   read_data2,
    // write port
    input  [4:0]    write_addr,
    input  [63:0]   write_data,
    input           write_ena
);
    logic [63:0] regs [31:0];
    integer i;
    always_ff @(negedge clk) begin
        // write at negedge
        if (rst) begin
            for(i=0 ; i<32 ; i+=1 ) regs[i] <= 0;
        end
        else if (write_ena) begin
            regs[write_addr] <= write_data;
            assert (write_ena && write_addr == 0) begin
                $display("error");
                $stop;
            end
        end
    end
    
    

    assign read_data1 = regs[read_addr1];
    assign read_data2 = regs[read_addr2];
endmodule