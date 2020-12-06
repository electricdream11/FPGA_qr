`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/18 11:13:25
// Design Name: 
// Module Name: info_extract
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


module info_extract#(
    parameter ADDR_WIDTH_RAM2 = 16,
    parameter READ_DELAY = 5
)
(
    input clk,
    input rst_n,

    input dmn_en,
    output reg dmn_end,
    //ram2
    output reg [ADDR_WIDTH_RAM2-1:0] addr_ram2_A,
    input dout_ram2_A,

    input [ADDR_WIDTH_RAM2-1:0] addr_ram2_B,
    output reg dout_ram2_B,
    //result
    output reg [15:0] info_buf,  

    //locate
    input [ADDR_WIDTH_RAM2-1:0] addr_00,
    input [ADDR_WIDTH_RAM2-1:0] addr_11,
    input [ADDR_WIDTH_RAM2-1:0] addr_width,
    input [31:0] width
);
//state params
localparam S0=4'd0;
localparam S1=4'd1;
localparam S2=4'd2;
localparam S3=4'd3;
localparam S4=4'd4;
localparam S5=4'd5;
localparam S6=4'd6;
localparam S7=4'd7;
localparam S8=4'd8;
//state varible
reg [3:0] state_now;
reg [3:0] state_wait;
//data caculate
reg [ADDR_WIDTH_RAM2-1:0] qr_width;
reg [ADDR_WIDTH_RAM2-1:0] addr_init;
reg [ADDR_WIDTH_RAM2-1:0] qr_ud;
reg [ADDR_WIDTH_RAM2-1:0] qr_lr;
//count
reg [3:0] cnt_data;
reg [2:0] cnt_S1;
reg [3:0] cnt_S3;
//state machine
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        state_now<=S0;
    end
    else begin
        case(state_now)
            S0:if(dmn_en)state_now<=state_wait;
            S1:if(cnt_S1==3'd5)state_now<=state_wait;
            S2:state_now<=state_wait;
            S3:if(cnt_S3==READ_DELAY-1'b1) state_now<=state_wait;
            S4:state_now<=state_wait;
            S5:state_now<=state_wait;
            S6:state_now<=state_wait;
            S7:if(!dmn_en)state_now<=state_wait;
            S8:state_now<=state_wait;
        endcase
    end
end
always@(*)begin
        case(state_now)
            S0:state_wait=S1;
            S1:state_wait=S2;
            S2:state_wait=S3;
            S3:state_wait=S4;
            S4:state_wait=S5;
            S5:state_wait=S6;
            S6:if(cnt_data==4'd15)state_wait=S7;else state_wait=S2;
            S7:state_wait=S8;
            S8:state_wait=S0;
        endcase
end
//connect
always@(*)begin
    dout_ram2_B = dout_ram2_A;
end
//S1 : caculate once
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        qr_width<=1'b0;
        qr_lr<=1'b0;
        qr_ud<=1'b0;
        addr_init<=1'b0;
    end
    else if(state_now==S0 || state_now==S7)begin
        qr_width<=1'b0;
        qr_lr<=1'b0;
        qr_ud<=1'b0;
        addr_init<=1'b0;
    end
    else if(state_now==S1)begin
        case(cnt_S1)
            3'd0:qr_width <= ((addr_11-addr_00)/width+1);
            3'd1:qr_width <= qr_width/addr_width;
            3'd2:   begin 
                    qr_lr<=addr_width;
                    qr_ud<=addr_width*width; 
                    end  
            3'd3:addr_init <=addr_00+qr_lr*8;
            3'd4:addr_init <=addr_init+qr_ud*(qr_width-1);
        endcase
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_S1<=1'b0;
    end
    else if(state_now==S0 || state_now==S2)begin
        cnt_S1<=1'b0;
    end
    else if(state_now==S1)begin
        cnt_S1<=cnt_S1+1'b1;
    end
end
//S2
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        addr_ram2_A<=1'b0;
    end
    else if(state_now==S0)begin
        addr_ram2_A<=1'b0;
    end
    else if(state_now==S2)begin
        case(cnt_data)
            4'd0:addr_ram2_A<=addr_init;
            4'd1,4'd2,4'd3,4'd4,4'd5,4'd7:addr_ram2_A<=addr_ram2_A - qr_ud;
            4'd6:addr_ram2_A<=addr_ram2_A - 2*qr_ud;
            4'd8,4'd10,4'd11,4'd12,4'd13,4'd14:addr_ram2_A<=addr_ram2_A - qr_lr;
            4'd9:addr_ram2_A<=addr_ram2_A - 2*qr_lr;
        endcase
    end
    else if(state_now==S7)begin
        addr_ram2_A<=addr_ram2_B;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_S3<=1'b0;
    end
    else if(state_now==S0 || state_now==S4)begin
        cnt_S3<=1'b0;
    end
    else if(state_now==S3)begin
        cnt_S3<=cnt_S3+1'b1;
    end
end
//S4:get data
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        info_buf<=1'b0;
    end
    else if(state_now==S0)begin
        info_buf<=1'b0;
    end
    else if(state_now==S4)begin
        case(cnt_data)
            4'd0:info_buf[0]=dout_ram2_A;
            4'd1:info_buf[1]=dout_ram2_A;
            4'd2:info_buf[2]=dout_ram2_A;
            4'd3:info_buf[3]=dout_ram2_A;
            4'd4:info_buf[4]=dout_ram2_A;
            4'd5:info_buf[5]=dout_ram2_A;
            4'd6:info_buf[6]=dout_ram2_A;
            4'd7:info_buf[7]=dout_ram2_A;
            4'd8:info_buf[8]=dout_ram2_A;
            4'd9:info_buf[9]=dout_ram2_A;
            4'd10:info_buf[10]=dout_ram2_A;
            4'd11:info_buf[11]=dout_ram2_A;
            4'd12:info_buf[12]=dout_ram2_A;
            4'd13:info_buf[13]=dout_ram2_A;
            4'd14:info_buf[14]=dout_ram2_A;
        endcase
    end
end
//S5:cnt data
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_data<=1'b0;
    end
    else if(state_now==S0)begin
        cnt_data<=1'b0;
    end
    else if(state_now==S5)begin
        cnt_data<=cnt_data+1'b1;
    end
end
//S6: choose channal
//S7: dmn wait
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        dmn_end<=1'b0;
    end
    else if(state_now==S0 || state_now==S8)begin
        dmn_end<=1'b0;
    end
    else if(state_now==S7)begin
        dmn_end<=1'b1;
    end
end
//S8: reset wait
endmodule
