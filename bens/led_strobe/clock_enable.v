module clock_enable (
    input wire clk,
    input wire [7:0] div,
    output reg clk_e
);

    reg [25:0] cnt;


    always @(posedge clk) begin

        if (cnt >= ( {div[7:0], 18'h20_000} -1'b1)) begin
            cnt <= 26'b0;
            clk_e <= 1'b1;
        end
        else begin
            cnt <= cnt + 1'b1;
            clk_e <= 1'b0;
        end
    end

endmodule
