module crc32(
    input clk,
    input fcs_en,
    input [1:0] data,
    output [31:0] fcs_out
);
    reg[31:0] crcIn;
    wire[31:0] crcOut;    

    assign crcOut[0] = crcIn[2];
    assign crcOut[1] = crcIn[3];
    assign crcOut[2] = crcIn[4];
    assign crcOut[3] = crcIn[5];
    assign crcOut[4] = crcIn[0] ^ crcIn[6] ^ data[0];
    assign crcOut[5] = crcIn[1] ^ crcIn[7] ^ data[1];
    assign crcOut[6] = crcIn[8];
    assign crcOut[7] = crcIn[0] ^ crcIn[9] ^ data[0];
    assign crcOut[8] = crcIn[0] ^ crcIn[1] ^ crcIn[10] ^ data[0] ^ data[1];
    assign crcOut[9] = crcIn[1] ^ crcIn[11] ^ data[1];
    assign crcOut[10] = crcIn[12];
    assign crcOut[11] = crcIn[13];
    assign crcOut[12] = crcIn[14];
    assign crcOut[13] = crcIn[15];
    assign crcOut[14] = crcIn[0] ^ crcIn[16] ^ data[0];
    assign crcOut[15] = crcIn[1] ^ crcIn[17] ^ data[1];
    assign crcOut[16] = crcIn[18];
    assign crcOut[17] = crcIn[19];
    assign crcOut[18] = crcIn[0] ^ crcIn[20] ^ data[0];
    assign crcOut[19] = crcIn[0] ^ crcIn[1] ^ crcIn[21] ^ data[0] ^ data[1];
    assign crcOut[20] = crcIn[0] ^ crcIn[1] ^ crcIn[22] ^ data[0] ^ data[1];
    assign crcOut[21] = crcIn[1] ^ crcIn[23] ^ data[1];
    assign crcOut[22] = crcIn[0] ^ crcIn[24] ^ data[0];
    assign crcOut[23] = crcIn[0] ^ crcIn[1] ^ crcIn[25] ^ data[0] ^ data[1];
    assign crcOut[24] = crcIn[1] ^ crcIn[26] ^ data[1];
    assign crcOut[25] = crcIn[0] ^ crcIn[27] ^ data[0];
    assign crcOut[26] = crcIn[0] ^ crcIn[1] ^ crcIn[28] ^ data[0] ^ data[1];
    assign crcOut[27] = crcIn[1] ^ crcIn[29] ^ data[1];
    assign crcOut[28] = crcIn[0] ^ crcIn[30] ^ data[0];
    assign crcOut[29] = crcIn[0] ^ crcIn[1] ^ crcIn[31] ^ data[0] ^ data[1];
    assign crcOut[30] = crcIn[0] ^ crcIn[1] ^ data[0] ^ data[1];
    assign crcOut[31] = crcIn[1] ^ data[1];

    assign fcs_out = ~crcIn;
    always @(posedge clk)
        crcIn <= fcs_en ? crcOut : 32'hFFFFFFFF;
        
    
endmodule