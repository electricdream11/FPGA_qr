`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/09 21:58:16
// Design Name: 
// Module Name: dmn_last
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module dmn_last#(
    parameter ZERO=0,
    parameter PARA1=32'hff9911,
    parameter PARA2=32'd2,
    parameter PARA3=32'd8
)
(
    input wire dmn_en,
    output wire dmn_end,
    
    output wire zero,
    
    output wire [31:0] dmn_para1,
    output wire [31:0] dmn_para2,
    output wire [31:0] dmn_para3
    );
    assign dmn_end=dmn_en;
    
    assign zero=ZERO;
    assign dmn_para1=PARA1;
    assign dmn_para2=PARA2;
    assign dmn_para3=PARA3;
endmodule
