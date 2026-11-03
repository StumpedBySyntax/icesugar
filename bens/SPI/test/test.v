


module top (
    input  wire clk,
    output reg  led
);

    wire tick;

    clock_enable #(
        .DIVISOR(24_000_000)
    ) clk_en (
        .clk(clk),
        .rst(1'b0),
        .tick(tick)
    );

    always @(posedge clk) begin

        if (tick)
            led <= ~led;

    end

endmodule



module clock_enable #(
    // Number of input clock cycles between output tick pulses.
    //
    // Input Clock Frequency : 48 MHz
    // Tick Frequency        : 48 MHz / DIVISOR
    //
    // Examples:
    // DIVISOR = 480  -> 100 kHz tick
    // DIVISOR = 48   ->   1 MHz tick
    // DIVISOR = 24   ->   2 MHz tick
    // DIVISOR = 12   ->   4 MHz tick
    // DIVISOR = 6    ->   8 MHz tick
    //
    // Valid values:
    // DIVISOR >= 1
    //
    // Recommended values for SPI LCD development:
    // 24 .. 480
    //
    parameter integer DIVISOR = 24
)(
    input  wire clk,
    input  wire rst,

    output reg  tick
);

    reg [25:0] counter;

    always @(posedge clk) begin
        if (rst) begin
            counter <= 26'd0;
            tick    <= 1'b0;
        end
        else begin

            // default
            tick <= 1'b0;

            if (counter == (DIVISOR - 1)) begin
                counter <= 26'd0;
                tick    <= 1'b1;
            end
            else begin
                counter <= counter + 1'b1;
            end

        end
    end

endmodule