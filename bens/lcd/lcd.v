


    // reg clk_e;

    // clock_enable  #(
    //     .DIVISOR(3_000_000)
    // )
    // clk_e_0
    // (
    //     .clk(clk),
    //     .clk_e(clk_e)
    // );




module spi_master (
    // CLK and CLK enable
    input wire clk,
    input wire clk_e,

    // LCD Controller connections
    input wire start,
    input wire rs,
    input wire [7:0] tx_data,
    output reg done,
    output reg busy,
    
    // LCD connections
    output reg spi_cs_n,
    output wire spi_mosi,
    output reg spi_clk,
    output reg spi_rs
);


    // State Machine Registers
    reg [3:0] state;

    localparam IDLE        = 3'd0;
    localparam LOAD        = 3'd1;
    localparam SHIFT_LOW   = 3'd2;
    localparam SHIFT_HIGH  = 3'd3;
    localparam COMPLETE =  3'd4;

    // Bit shift count registers
    reg [3:0] bit_count;

    // Bit Shift Register
    reg [7:0] tx_shift_reg;

    assign spi_mosi = tx_shift_reg[7];


    always @(posedge clk) begin
        
        case (state)

            IDLE: begin
                
                // default
                spi_cs_n <= 1'b1;
                done <= 1'b0;
                state <= IDLE;
                spi_clk <= 1'b0;
                spi_rs <= 1'b0;
                bit_count <= 1'b0;
                tx_shift_reg <= 8'b0;
                busy <= 1'b0;

                if (clk_e && start) begin
                    state <= LOAD;
                end
            end

            LOAD: begin

                spi_cs_n <= 1'b0;
                done <= 1'b0;
                state <= LOAD;
                spi_clk <= 1'b0;
                spi_rs <= rs;
                tx_shift_reg <= tx_data;
                busy <= 1'b1;
                bit_count <= 8'd7;

                if (clk_e) begin
                    state <= SHIFT_HIGH;
                end

            end

            SHIFT_HIGH: begin
                spi_cs_n <= 1'b0;
                done <= 1'b0;
                state <= SHIFT_HIGH;
                spi_rs <= rs;
                busy <= 1'b1;

                if (clk_e) begin
                    spi_clk <= 1'b1;
                    state <= SHIFT_LOW;
                end

            end

            SHIFT_LOW: begin
                spi_cs_n <= 1'b0;
                done <= 1'b0;
                state <= SHIFT_LOW;
                spi_rs <= rs;
                busy <= 1'b1;

                if(clk_e) begin
                    spi_clk <= 1'b0;
                    tx_shift_reg  <= {tx_shift_reg[6:0], 1'b0};
                    if (bit_count > 0) begin
                        //Shift and bit count can only occuring once in this state
                        bit_count <= bit_count - 1'b1;
                        state <= SHIFT_HIGH;
                    end
                    else begin
                        state <= COMPLETE;
                        spi_cs_n <= 1'b1;
                    end
                end
            end

            COMPLETE: begin
                state <= COMPLETE;
                spi_cs_n <= 1'b1;
                done <= 1'b1;
                busy <= 1'b0;
                spi_cs_n <= 1'b1;
                
                if (clk_e && ~start) begin
                    state <= IDLE;
                    spi_clk <= 1'b1;
                end
            end

            default: begin
                spi_cs_n <= 1'b1;
                done <= 1'b0;
                state <= IDLE;
                spi_clk <= 1'b0;
                spi_rs <= 1'b0;
                bit_count <= 1'b0;
                tx_shift_reg <= 8'b0;
                busy <= 1'b0;
            end
        endcase
    end
endmodule



