

module UART_RX(
    input rst,
    input clk,
    input uart_rx,
    
    input rx_fifo_rden,
    output rx_fifo_available,
    output[7:0] rx_fifo_data
);
    parameter CLK_MHZ = 0;
    parameter BAUD_RATE = 0;
    
    parameter UART_BIT_PERIOD = CLK_MHZ * 1_000_000 / BAUD_RATE;
    parameter UART_SAMPLE_THRESHOLD = CLK_MHZ * 500_000 / BAUD_RATE;

    localparam COUNTER_W = $clog2(UART_BIT_PERIOD + 1);
    
    parameter RX_INIT = 4'd0;
    parameter RX_PAYLOAD0 = 4'd1;
    parameter RX_PAYLOAD1 = 4'd2;
    parameter RX_PAYLOAD2 = 4'd3;
    parameter RX_PAYLOAD3 = 4'd4;
    parameter RX_PAYLOAD4 = 4'd5;
    parameter RX_PAYLOAD5 = 4'd6;
    parameter RX_PAYLOAD6 = 4'd7;
    parameter RX_PAYLOAD7 = 4'd8;
    parameter RX_END = 4'd9;
    
    reg[3:0] uart_rx_state = RX_INIT;
    
    reg[COUNTER_W-1:0] state_ctr = 0;
    
    reg[3:0] uart_rx_nextstate;
    
    
            
            
    always @* begin
        case (uart_rx_state)
            RX_INIT: uart_rx_nextstate = state_ctr == UART_SAMPLE_THRESHOLD ? RX_PAYLOAD0 : RX_INIT;
            RX_PAYLOAD0: uart_rx_nextstate = state_ctr == UART_BIT_PERIOD ? RX_PAYLOAD1 : RX_PAYLOAD0;
            RX_PAYLOAD1: uart_rx_nextstate = state_ctr == UART_BIT_PERIOD ? RX_PAYLOAD2 : RX_PAYLOAD1;
            RX_PAYLOAD2: uart_rx_nextstate = state_ctr == UART_BIT_PERIOD ? RX_PAYLOAD3 : RX_PAYLOAD2;
            RX_PAYLOAD3: uart_rx_nextstate = state_ctr == UART_BIT_PERIOD ? RX_PAYLOAD4 : RX_PAYLOAD3;
            RX_PAYLOAD4: uart_rx_nextstate = state_ctr == UART_BIT_PERIOD ? RX_PAYLOAD5 : RX_PAYLOAD4;
            RX_PAYLOAD5: uart_rx_nextstate = state_ctr == UART_BIT_PERIOD ? RX_PAYLOAD6 : RX_PAYLOAD5;
            RX_PAYLOAD6: uart_rx_nextstate = state_ctr == UART_BIT_PERIOD ? RX_PAYLOAD7 : RX_PAYLOAD6;
            RX_PAYLOAD7: uart_rx_nextstate = state_ctr == UART_BIT_PERIOD ? RX_END      : RX_PAYLOAD7;
            RX_END:      uart_rx_nextstate = state_ctr == UART_BIT_PERIOD ? RX_INIT     : RX_END;
            default: uart_rx_nextstate = RX_INIT;
        endcase
    end
    reg[7:0] rcv_frame;
    reg uart_rx_q;
    always @(posedge clk)
        if (rst)
            uart_rx_q <= 1'b1;
        else
            uart_rx_q <= uart_rx;
    always @(posedge clk) begin
        if (rst) begin
            uart_rx_state <= RX_INIT;
        end
        else begin
            uart_rx_state <= uart_rx_nextstate;
            if (uart_rx_nextstate != uart_rx_state) begin
                state_ctr <= 0;
                case (uart_rx_state)
                    RX_PAYLOAD0: rcv_frame[0] <= uart_rx_q;
                    RX_PAYLOAD1: rcv_frame[1] <= uart_rx_q;
                    RX_PAYLOAD2: rcv_frame[2] <= uart_rx_q;
                    RX_PAYLOAD3: rcv_frame[3] <= uart_rx_q;
                    RX_PAYLOAD4: rcv_frame[4] <= uart_rx_q;
                    RX_PAYLOAD5: rcv_frame[5] <= uart_rx_q;
                    RX_PAYLOAD6: rcv_frame[6] <= uart_rx_q;
                    RX_PAYLOAD7: rcv_frame[7] <= uart_rx_q;
                endcase
            end
            else begin
                if (uart_rx_state == RX_INIT)
                    state_ctr <= uart_rx_q ? 0 : state_ctr + 1;
                else
                    state_ctr <= state_ctr + 1;
            end
        end
    end
    
    
    
    
    wire rx_fifo_empty;
    assign rx_fifo_available = ~rx_fifo_empty;
    FIFO_SC_2048x8 rx_fifo(
		.Data(rcv_frame), //input [7:0] Data
		.Clk(clk), //input Clk
		.WrEn(uart_rx_state == RX_END && uart_rx_nextstate == RX_INIT), //input WrEn
		.RdEn(rx_fifo_rden), //input RdEn
		.Reset(rst), //input Reset
		.Q(rx_fifo_data), //output [7:0] Q
		.Empty(rx_fifo_empty), //output Empty
		.Full() //output Full
	);
endmodule


module UART_TX(
    input rst,
    input clk,
    output uart_tx,
    
    input tx_fifo_wren,
    input[7:0] tx_fifo_datain,
    output tx_fifo_full
);

    parameter CLK_MHZ = 0;
    parameter BAUD_RATE = 0;
    
    parameter UART_BIT_PERIOD = CLK_MHZ * 1_000_000 / BAUD_RATE;
    parameter UART_SAMPLE_THRESHOLD = CLK_MHZ * 500_000 / BAUD_RATE;

    localparam COUNTER_W = $clog2(UART_BIT_PERIOD + 1);
    
    wire tx_fifo_empty;
    wire tx_read_en;
    wire[7:0] tx_data;
    FIFO_SC_2048x8 tx_fifo(
		.Data(tx_fifo_datain), //input [7:0] Data
		.Clk(clk), //input Clk
		.WrEn(tx_fifo_wren), //input WrEn
		.RdEn(tx_read_en), //input RdEn
		.Reset(rst), //input Reset
		.Q(tx_data), //output [7:0] Q
		.Empty(tx_fifo_empty), //output Empty
		.Full(tx_fifo_full) //output Full
	);
    
    parameter TX_WAIT = 4'd0;
    parameter TX_INIT = 4'd1;
    parameter TX_PAYLOAD0 = 4'd2;
    parameter TX_PAYLOAD1 = 4'd3;
    parameter TX_PAYLOAD2 = 4'd4;
    parameter TX_PAYLOAD3 = 4'd5;
    parameter TX_PAYLOAD4 = 4'd6;
    parameter TX_PAYLOAD5 = 4'd7;
    parameter TX_PAYLOAD6 = 4'd8;
    parameter TX_PAYLOAD7 = 4'd9;
    parameter TX_END = 4'd10;
    
    reg[COUNTER_W-1:0] tx_ctr = 0;
    reg[3:0] uart_tx_state = TX_WAIT;
    reg[3:0] uart_tx_nextstate;
    assign tx_read_en = uart_tx_state == TX_WAIT;
    reg[7:0] transmit_frame;
    always @* begin
        case (uart_tx_state)
            TX_WAIT: uart_tx_nextstate = tx_fifo_empty ? TX_WAIT : TX_INIT;
            TX_INIT: uart_tx_nextstate = tx_ctr == UART_BIT_PERIOD ? TX_PAYLOAD0 : TX_INIT;
            TX_PAYLOAD0: uart_tx_nextstate = tx_ctr == UART_BIT_PERIOD ? TX_PAYLOAD1 : TX_PAYLOAD0;
            TX_PAYLOAD1: uart_tx_nextstate = tx_ctr == UART_BIT_PERIOD ? TX_PAYLOAD2 : TX_PAYLOAD1;
            TX_PAYLOAD2: uart_tx_nextstate = tx_ctr == UART_BIT_PERIOD ? TX_PAYLOAD3 : TX_PAYLOAD2;
            TX_PAYLOAD3: uart_tx_nextstate = tx_ctr == UART_BIT_PERIOD ? TX_PAYLOAD4 : TX_PAYLOAD3;
            TX_PAYLOAD4: uart_tx_nextstate = tx_ctr == UART_BIT_PERIOD ? TX_PAYLOAD5 : TX_PAYLOAD4;
            TX_PAYLOAD5: uart_tx_nextstate = tx_ctr == UART_BIT_PERIOD ? TX_PAYLOAD6 : TX_PAYLOAD5;
            TX_PAYLOAD6: uart_tx_nextstate = tx_ctr == UART_BIT_PERIOD ? TX_PAYLOAD7 : TX_PAYLOAD6;
            TX_PAYLOAD7: uart_tx_nextstate = tx_ctr == UART_BIT_PERIOD ? TX_END      : TX_PAYLOAD7;
            TX_END:      uart_tx_nextstate = tx_ctr == UART_BIT_PERIOD ? TX_WAIT     : TX_END;
            default: uart_tx_nextstate = TX_WAIT;
        endcase
    end
    always @(posedge clk) begin
        if (rst) begin
            uart_tx_state <= TX_WAIT;
        end
        else begin
            if (tx_read_en)
                transmit_frame <= tx_data;
            tx_ctr <= uart_tx_nextstate == uart_tx_state ? tx_ctr + 1 : 0;
            uart_tx_state <= uart_tx_nextstate;
        end
    end
    
    reg uart_tx_q = 1'b1;
    always @(posedge clk)
        case (uart_tx_state)
                TX_WAIT: uart_tx_q <= 1'b1;
                TX_INIT: uart_tx_q <= 1'b0;
                TX_PAYLOAD0: uart_tx_q <= transmit_frame[0];
                TX_PAYLOAD1: uart_tx_q <= transmit_frame[1];
                TX_PAYLOAD2: uart_tx_q <= transmit_frame[2];
                TX_PAYLOAD3: uart_tx_q <= transmit_frame[3];
                TX_PAYLOAD4: uart_tx_q <= transmit_frame[4];
                TX_PAYLOAD5: uart_tx_q <= transmit_frame[5];
                TX_PAYLOAD6: uart_tx_q <= transmit_frame[6];
                TX_PAYLOAD7: uart_tx_q <= transmit_frame[7];
                TX_END: uart_tx_q <= 1'b1;
                default: uart_tx_q <= 1'b1;
            endcase
   
    assign uart_tx = uart_tx_q;

endmodule

module uart(
    input rst,
    input clk,
    // top level pins
    input uart_rx,
    output uart_tx,
    
    input rx_fifo_rden,
    output rx_fifo_available,
    output[7:0] rx_fifo_data,
    
    input tx_fifo_wren,
    input[7:0] tx_fifo_datain,
    output tx_fifo_full
);
    parameter CLK_MHZ = 0;
    parameter BAUD_RATE = 0;

    UART_TX #(.CLK_MHZ(CLK_MHZ), .BAUD_RATE(BAUD_RATE)) tx(
        .clk(clk), .rst(rst), .uart_tx(uart_tx),
        .tx_fifo_wren(tx_fifo_wren), .tx_fifo_datain(tx_fifo_datain), .tx_fifo_full(tx_fifo_full)
    );
    UART_RX #(.CLK_MHZ(CLK_MHZ), .BAUD_RATE(BAUD_RATE)) rx(
        .clk(clk), .rst(rst), .uart_rx(uart_rx),
        .rx_fifo_rden(rx_fifo_rden), .rx_fifo_available(rx_fifo_available), .rx_fifo_data(rx_fifo_data)
    );
    
    
endmodule