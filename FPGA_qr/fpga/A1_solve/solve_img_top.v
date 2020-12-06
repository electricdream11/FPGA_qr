`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/08 21:34:25
// Design Name: 
// Module Name: solve_img_top
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


module solve_img_top#(
    parameter ADDR_WIDTH = 18,
    parameter STATE_WIDTH = 5
)
(
    input wire clk,
    output wire rst_n,
    //ram port of b
    output wire enb,
    output wire web,
    output wire [ADDR_WIDTH-1:0] addrb,
    output wire [7:0] dinb,
    input wire [7:0] doutb,
    //dmn cell ports
    output wire [31:0] width,
    output wire [31:0] height,

    output wire dmn_en,
    input wire dmn_end,
    input wire dmn_web,
    input wire [7:0] dmn_dinb,
    input wire [ADDR_WIDTH-1:0] dmn_addrb,

    //axi  slave control
    input [31:0] slv_reg0,
    input [31:0] slv_reg1,
    output [31:0] slv_reg2,
    output [31:0] slv_reg3
    

    );
    wire im_start;
    wire im_work;
    wire om_start;
    wire om_work;
//standard ports
assign rst_n=slv_reg0[4];
assign im_start=slv_reg0[1];
assign im_work=slv_reg0[0];  
assign slv_reg3[0] = om_work;
assign slv_reg3[1] = om_start;
assign slv_reg3[31:2]=1'b0;

solve_img U1_solve(
    .clk(clk),
    .rst_n(rst_n),
    .enb(enb),
    .web(web),
    .addrb(addrb),
    .dinb(dinb),
    .doutb(doutb),
    //dmn cell
    .width(width),
    .height(height),
    .w1_work(dmn_en),
    .w1_work_end(dmn_end),
    .web_w1(dmn_web),
    .dinb_w1(dmn_dinb),
    .addrb_w1(dmn_addrb),
    //-------
    .im_start(im_start),
    .im_work(im_work),
    .im_data(slv_reg1),
    .om_data(slv_reg2),
    .om_start(om_start),
    .om_work(om_work)
);
endmodule
