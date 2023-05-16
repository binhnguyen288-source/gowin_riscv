
module top(
    
    input sys_rst_n,
    input osc,

    input eth_clk,
    input eth_dv,
    input[1:0] eth_rx,
    
    output eth_txen,
    output[1:0] eth_tx,
    
    output[5:0] led
);
    

    reg rst = 1'b1;
    always @(posedge eth_clk or negedge sys_rst_n)
        if (~sys_rst_n)
            rst <= 1'b1;
        else
            rst <= 1'b0;

    wire valid_data;
    wire[31:0] fcs_result;
    rmii_rx ethernet_rx(
        .rst(rst), .eth_clk(eth_clk), 
        .eth_dv(eth_dv), .eth_rx(eth_rx),
        .valid_data(valid_data),
        .fcs_result(fcs_result)
    );
    
    assign led = ~fcs_result[9:4];
//    reg[5:0] led_q = 6'd0;
//    assign led = ~led_q;
//    always @(posedge eth_clk)
//        if (rst)
//            led_q <= 6'h0;
//        else if (valid_data)
//            led_q <= led_q + 1;

    assign eth_txen = 1'b0;
    assign eth_tx = 2'b00;
endmodule
