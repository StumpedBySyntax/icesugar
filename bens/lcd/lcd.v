



module clock_enable #(
    parameter integer DIVISOR = 24
)(
    input  wire clk,
    output reg  tick
);

    reg [25:0] counter;

    always @(posedge clk) begin
        
        //default
        tick <= 1'b0;

        if (counter >= (DIVISOR-1)) begin
            counter <= 26'b0;
            tick <= 1'b1;
        end 
        else
            counter <= counter + 1'b1;
        
    end


endmodule



module spi_master
(

    input wire clk;
    input wire tick;
    input wire start;
    output reg busy;
    output reg done;

    input wire rs;
    input wire [7:0] tx_data,

    output reg spi_cs_n;
    output reg spi_sclk;
    output reg spi_mosi;
    output reg spi_rs;


);


reg [2:0] state;
reg [7:0] tx_shift_reg;
reg [2:0] bit_count;


    // states
    // 0 - IDLE
    // 1 - LOAD
    // 2 - SHIFT_LOW
    // 3 - SHIFT_HIGH
    // 4 - COMPLETE

    localparam IDLE        = 3'd0;
    localparam LOAD        = 3'd1;
    localparam SHIFT_LOW   = 3'd2;
    localparam SHIFT_HIGH  = 3'd3;
    localparam COMPLETE    = 3'd4;


    always @(posedge clk) begin
        
        case (state)

            IDLE: begin

                busy <= 1'b0;
                done <= 1'b0;
                tx_shift_reg <= 8'b0;
                spi_cs_n <= 1'b1;
                spi_sclk <= 1'b0;
                spi_mosi <= 1'b0;




            end

            LOAD: begin
            
            end

            SHIFT_LOW: begin
            end

            SHIFT_HIGH: begin
            end

            COMPLETE: begin
                
                
            end

            default: begin
                

            end

        endcase

    end

endmodule