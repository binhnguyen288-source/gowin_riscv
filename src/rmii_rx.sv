module rmii_rx(
    input rst,
    input eth_clk,
    input[1:0] eth_rx,
    input eth_dv,
    output reg valid_data,
    output[31:0] fcs_result
);
    reg[3:0] byte_ringctr = 4'b1000;
    reg[7:0] byte_temp;
    reg byte_valid_q = 1'b0;

    typedef enum {
        RMII_PREAMBLE,
        RMII_SFD,
        RMII_PAYLOAD,
        RMII_ERROR
    } RMII_STATE;
    RMII_STATE rmii_state = RMII_PREAMBLE;
    wire[31:0] fcs_out;
    crc32 fcs0(.clk(eth_clk), .fcs_en(rmii_state == RMII_PAYLOAD), .data(eth_rx), .fcs_out(fcs_out));
    reg[31:0] fcsResult = 0;
    assign fcs_result = fcsResult;
    always @(posedge eth_clk)
        if (rmii_state == RMII_PAYLOAD && ~eth_dv) begin
            fcsResult <= fcs_out;
            valid_data <= 1'b1;
        end
        else begin
            valid_data <= 1'b0;
        end
    always @(posedge eth_clk)
        if (rst || ~eth_dv) begin
            byte_valid_q <= 1'b0;
            byte_ringctr <= 4'b1000;
            rmii_state <= RMII_PREAMBLE;
        end
        else if (eth_dv) begin
            case (rmii_state)
                RMII_PREAMBLE: begin
                    rmii_state <= eth_rx == 2'b01 ? RMII_SFD : RMII_PREAMBLE;
                end
                RMII_SFD: begin
                    rmii_state <= eth_rx == 2'b01 ? RMII_SFD :
                                  eth_rx == 2'b11 ? RMII_PAYLOAD :
                                                    RMII_ERROR;
                end
                RMII_PAYLOAD: begin
                    byte_temp <= {eth_rx, byte_temp[7:2]};
                    byte_ringctr <= {byte_ringctr[0], byte_ringctr[3:1]};
                end
            endcase
            byte_valid_q <= byte_ringctr[0];
        end

    typedef enum {
        RX_MAC,
        RX_WAIT,
        RX_ERROR
    } RX_STATE;
    RX_STATE rxstate = RX_MAC;
    RX_STATE rx_nextstate;
    reg[7:0] mac_header_check[14] = {
        8'h00, 8'h18, 8'h3E, 8'h03, 8'hE2, 8'hDC, 
        8'h08, 8'h55, 8'h31, 8'hAA, 8'h10, 8'h5F,
        8'h08, 8'h00
    };
    reg[10:0] rx_counter = 11'd0;
    
    always @*
        case (rxstate)
            RX_MAC: begin
                if (mac_header_check[rx_counter] == byte_temp)
                    rx_nextstate = rx_counter == 13 ? RX_WAIT : RX_MAC;
                else
                    rx_nextstate = RX_ERROR;
            end
            RX_WAIT: rx_nextstate = eth_dv ? RX_WAIT : RX_MAC;
            RX_ERROR: rx_nextstate = eth_dv ? RX_ERROR : RX_MAC;
            default: rx_nextstate = RX_MAC;
        endcase
    RX_STATE rxstate_prev;
    always @(posedge eth_clk)
        rxstate_prev <= rxstate;
//    always @(posedge eth_clk)
//        if (rst)
//            valid_data <= 1'b0;
//        else if (rxstate == RX_WAIT && rxstate_prev == RX_MAC)
//            valid_data <= 1'b1;
//        else
//            valid_data <= 1'b0;
    
    always @(posedge eth_clk) begin
        if (rst) begin
            rx_counter <= 11'd0;
        end else if (byte_valid_q) begin
            rx_counter <= rxstate == rx_nextstate ? rx_counter + 1 : 0;
            rxstate <= rx_nextstate;
        end
    end
endmodule