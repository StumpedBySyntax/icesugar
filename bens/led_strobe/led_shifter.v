module led_shifter (
    input wire clk,
    input wire clk_e,
    output wire [7:0] led
);

    reg [3:0] state;

    reg [7:0] shifter;


    assign led = ~(shifter);

    always @(posedge clk) begin
        
        if (clk_e) begin
            
            state <= state + 1'b1;
            case (state)

                4'd0: begin
                    shifter <= 8'b1000_0000;
                end

                4'd1: begin
                    shifter <= 8'b0100_0000;
                end

                4'd2: begin
                    shifter <= 8'b0010_0000;
                end

                4'd3: begin
                    shifter <= 8'b0001_0000;
                end

                4'd4: begin
                    shifter <= 8'b0000_1000;
                end

                4'd5: begin
                    shifter <= 8'b0000_0100;
                end

                4'd6: begin
                    shifter <= 8'b0000_0010;
                end

                4'd7: begin
                    shifter <= 8'b0000_0001;
                end

                4'd8: begin
                    shifter <= 8'b0000_0000;
                    state <= 4'b0;
                end

                default: begin
                    shifter <= 8'b0000_0000;
                    state <= 4'b0;
                end

            endcase

        end
    end


endmodule