`timescale 1ns/1ps

module testbench;

    reg clk;
    reg start;
    reg rs;
    reg rst;
    reg [7:0] tx_data;

    wire clk_e;
    wire done;
    wire busy;
    wire spi_cs_n;
    wire spi_mosi;
    wire spi_clk;
    wire spi_rs;


    clock_enable  #(
        .DIVISOR(2)
    )
    clk_e_0
    (
        .clk(clk),
        .rst(rst),
        .clk_e(clk_e)
    );


    spi_master DUT(
        .clk(clk),
        .clk_e(clk_e),
        .start(start),
        .rs(rs),
        .tx_data(tx_data),
        .done(done),
        .busy(busy),
        .spi_cs_n(spi_cs_n),
        .spi_mosi(spi_mosi),
        .spi_clk(spi_clk),
        .spi_rs(spi_rs)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, testbench);

        clk = 0;
        start = 0;
        rst = 1;


        #20 rst = 0;

        #40 rs = 0;
        #40 tx_data = 8'b0101_0101;

        #50 start = 1;


        #600 start = 0;
        #620 rs = 1;
        #620 tx_data = 8'b1100_0011;
        #630 start = 1;




        // #20 reset = 0;

        // #50 button = 1;
        // #20 button = 0;

        #2000 $finish;


    end

    always #5 clk = ~clk;

endmodule








