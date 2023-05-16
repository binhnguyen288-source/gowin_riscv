
module rmii_tx(
    input rst,
    input eth_clk,
    output[1:0] eth_tx,
    output eth_txen
);

    
    assign eth_txen = 1'b0;
    assign eth_tx = 2'b00;

endmodule