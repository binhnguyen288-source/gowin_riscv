
module top(
    
    input sys_rst_n,
    input osc,

    input eth_clk,
    input eth_dv,
    input[1:0] eth_rx,
    
    output eth_txen,
    output[1:0] eth_tx,
    
    input uart_rx,
    output uart_tx,
    
    output[5:0] led
);
    
    

    reg rst = 1'b1;
    always @(posedge eth_clk or negedge sys_rst_n)
        if (~sys_rst_n)
            rst <= 1'b1;
        else
            rst <= 1'b0;
    
    wire rx_fifo_rden = 1'b0;
    wire rx_fifo_available;
    wire[7:0] rx_fifo_data;

    wire tx_fifo_wr_en;
    wire[7:0] tx_fifo_datain;
    wire tx_fifo_full;
    uart #(.CLK_MHZ(50), .BAUD_RATE(921600)) uart0 (
        .rst(rst), .clk(eth_clk), .uart_rx(uart_rx), .uart_tx(uart_tx),
        .rx_fifo_rden(rx_fifo_rden), .rx_fifo_available(rx_fifo_available), .rx_fifo_data(rx_fifo_data),
        .tx_fifo_wren(tx_fifo_wren), .tx_fifo_datain(tx_fifo_datain), .tx_fifo_full(tx_fifo_full)
    );

    wire valid_data;
    wire byte_dv;
    wire[7:0] byte_data;
    rmii_rx ethernet_rx(
        .rst(rst), .eth_clk(eth_clk), 
        .eth_dv_iport(eth_dv), .eth_rx_iport(eth_rx),
        .valid_data(valid_data),
        .byte_dv(byte_dv),
        .byte_data(byte_data)
    );
    assign tx_fifo_wren = byte_dv;
    assign tx_fifo_datain = byte_data;
    

//    reg[5:0] led_q;
//    assign led = ~led_q;
//    always @(posedge eth_clk)
//        if (rst)
//            led_q <= 6'h0;
//        else if (valid_data)
//            led_q <= led_q + 1;
    assign led = 6'b111111;

    assign eth_txen = 1'b0;
    assign eth_tx = 2'b00;
endmodule
