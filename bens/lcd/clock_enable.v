module clock_enable #(
    parameter integer DIVISOR = 24_000_000
)(
    input wire clk,
    input wire rst,
    output reg clk_e
);

    reg [25:0] cnt;


    always @(posedge clk) begin

        if (rst) begin
            cnt <= 26'b0;
            clk_e <= 1'b0;
        end
        else if (cnt >= (DIVISOR -1)) begin
            cnt <= 26'b0;
            clk_e <= 1'b1;
        end
        else begin
            cnt <= cnt + 1'b1;
            clk_e <= 1'b0;
        end
    end

endmodule
