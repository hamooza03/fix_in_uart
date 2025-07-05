module uart_rx #(
    parameter CLK_FREQ = 50000000,     // 50 MHz clock signal
    parameter BAUD_RATE = 9600,         // Baud rate
    parameter CLK_PER_BIT = 5208
)(
    input wire i_clk,                    // clk
    input wire i_reset,                  // Synchronous reset
    input wire i_rx,                     // UART serial input
    output reg [7:0] o_data_out,         // Received byte
    output reg o_valid_out               // Output: high for one cycle when byte is ready
);

// State encoding
    localparam STATE_IDLE  = 0;
    localparam STATE_START = 1;
    localparam STATE_DATA  = 2;
    localparam STATE_STOP  = 3;

    reg [1:0] r_state = STATE_IDLE;           // Current state
    reg [12:0] r_clk_count = 0;               // Counts clock cycles
    reg [2:0] r_bit_index = 0;                // Which bit we're on
    reg [7:0] r_rx_shift = 0;                 // Shift register

    always @(posedge i_clk)
        if (i_reset) begin
            // reset all
            r_state      <= STATE_IDLE;
            r_clk_count  <= 0;
            r_bit_index  <= 0;
            r_rx_shift   <= 0;
            o_data_out   <= 0;
            o_valid_out  <= 0;

        end else begin
            case(r_state)

                STATE_IDLE: begin
                    o_valid_out <= 0;
                    if (i_rx == 0) begin // Signals the START bit, ready to start receiving
                        r_state <= STATE_START;
                        r_clk_count <= 0;
                    end
                end

                STATE_START: begin
                    if (r_clk_count == (CLK_PER_BIT >> 1)) begin
                        if (i_rx == 0) begin // Checks again, 
                            r_state <= STATE_DATA;
                            r_clk_count <= 0;
                            r_bit_index <= 0;
                        end else begin
                            r_state <= STATE_IDLE;  // Do I need this? Just in case of error perhaps?
                        end
                    end else begin
                        r_clk_count <= r_clk_count + 1;
                    end
                end

                STATE_DATA: begin
                    
                end

                STATE_STOP: begin

                end


        end

endmodule