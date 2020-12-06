`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/16 19:18:07
// Design Name: 
// Module Name: return_top
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


module return_top#(
    parameter ADDR_WIDTH_3 = 12,
    parameter ADDR_BEGIN = 3,
    parameter ADDR_END = 103 
)
(
    input clk,
    input [31:0] slv_reg0,
    input [31:0] slv_reg1,
    
    output [31:0] slv_reg2,
    output [31:0] slv_reg3,
    
    output [ADDR_WIDTH_3-1:0] addra,
    input douta
);
wire rst_n;
wire im_start;
wire im_work;
wire om_work;
wire om_start;
wire [7:0] im_data;
wire om_data;

wire [ADDR_WIDTH_3-1:0] addra_end;
wire [ADDR_WIDTH_3-1:0] addra_begin; 
assign addra_end=ADDR_END;
assign addra_begin=ADDR_BEGIN;

assign rst_n=slv_reg0[4];
assign im_start = slv_reg0[1];
assign im_work = slv_reg0[0];
assign im_data=slv_reg1[7:0];

assign slv_reg2[0]=om_data;
assign slv_reg2[31:1]=1'b0;
assign slv_reg3[1]=om_start;
assign slv_reg3[0]=om_work;
assign slv_reg3[31:2]=1'b0;

return #(
    .ADDR_WIDTH_3(ADDR_WIDTH_3)
)
U1_return(
    .clk(clk),
    .rst_n(rst_n),
    .im_start(im_start),
    .im_work(im_work),
    .om_start(om_start),
    .om_work(om_work),

    .im_data(im_data),
    .om_data(om_data),

    .addra(addra),
    .douta(douta),

    .addra_end(addra_end),
    .addra_begin(addra_begin)
);
endmodule
