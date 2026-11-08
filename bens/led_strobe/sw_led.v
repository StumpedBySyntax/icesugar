module top(
input wire clk,
input wire [7:0] SW,
output wire [7:0] LED,
output reg LEDB
);

    wire clk_e;

    clock_enable clk_e0 (
        .clk(clk),
        .div(SW[7:0]),
        .clk_e(clk_e)
    );

    led_shifter led_s0 (
        .clk(clk),
        .clk_e(clk_e),
        .led(LED[7:0])
    );

    always @(posedge clk) begin
        if (clk_e) begin
            LEDB <= ~LEDB;
        end
    end




endmodule




