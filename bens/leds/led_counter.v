module led_counter (
    input wire clk,
    input wire clk_e,
    output wire [5:0] led
);

    reg [5:0] cnt;

    assign led = ~cnt;


    always @(posedge clk) begin

        if (clk_e)
            cnt <= cnt + 1'b1;
    end

endmodule
