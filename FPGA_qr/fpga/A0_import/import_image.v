`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/08 18:19:33
// Design Name: 
// Module Name: import_image
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


module import_image(
    input import_clk,
    
//axi slave    
    input [31:0] slv_reg0,
    input [31:0] slv_reg1,
    output [31:0] slv_reg2,
    output [31:0] slv_reg3,
//ram port b
	input wire enb,
	input wire web,
	input wire [17:0] addrb,
	input wire [7:0] dinb,
	output wire [7:0] doutb        
    );
wire rst_n;
wire im_satrt;
wire im_work;
wire [7:0] im_data;
wire [7:0] om_data;
wire om_start;
wire om_work;
//connect
assign rst_n=slv_reg0[4];
assign im_start=slv_reg0[1];
assign im_work=slv_reg0[0];

assign im_data=slv_reg1[7:0];

assign slv_reg2[7:0]=om_data;
assign slv_reg2[31:8]=24'b0;

assign slv_reg3[0]=om_work;
assign slv_reg3[1]=om_start;
assign slv_reg3[31:2]=30'b0;

imag_get U1_get(
    .clk(import_clk),
    .rst_n(rst_n),
    .im_start(im_start),
    .im_work(im_work),
    .om_start(om_start),
    .om_work(om_work),
    .im_data(im_data),
    .om_data(om_data),
    
    .enb(enb),
    .web(web),
    .addrb(addrb),
    .dinb(dinb),
    .doutb(doutb)
);    
endmodule
