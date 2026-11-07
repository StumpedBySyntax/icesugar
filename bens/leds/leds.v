
module top (
    input wire clk,
    output wire [5:0] LED
);

    reg clk_e;

    clock_enable  #(
        .DIVISOR(3_000_000)
    )
    clk_e_0
    (
        .clk(clk),
        .clk_e(clk_e)
    );

    led_counter led_cnt0 (
        .clk(clk),
        .clk_e(clk_e),
        .led(LED)
    );

endmodule
