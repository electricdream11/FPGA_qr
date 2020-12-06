`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/16 17:02:01
// Design Name: 
// Module Name: return
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


module return #(
    parameter ADDR_WIDTH_3 = 12,
    parameter READ_DELAY = 5
)
(
    input clk,
    input rst_n,

    input im_start,
    input im_work,
    output reg om_start,
    output reg om_work,

    input [7:0] im_data,
    output reg om_data,

    output reg [ADDR_WIDTH_3-1:0] addra,
    input douta,

    input [ADDR_WIDTH_3-1:0] addra_end,
    input [ADDR_WIDTH_3-1:0] addra_begin
    );
//state param
localparam S0=4'd0;
localparam S1=4'd1;
localparam S2=4'd2;
localparam S3=4'd3;
localparam S4=4'd4;
localparam S5=4'd5;
localparam S6=4'd6;
localparam S7=4'd7;
localparam S8=4'd8;
localparam S9=4'd9;
//state varible
reg [3:0] state_now;
reg [3:0] state_wait;
//cnt varible
reg [4:0] cnt_delay;
//addr varible
reg first_addr;
//state machine
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        state_now<=S0;
    end
    else begin
        case(state_now)
            S0:if(im_start)state_now<=state_wait;
            S1:state_now<=state_wait;
            S2:if(om_start)state_now<=state_wait;
            S3:state_now<=state_wait;
            S4:if(cnt_delay==READ_DELAY-1'b1)state_now<=state_wait;
            S5:if(im_work)state_now<=state_wait;
            S6:state_now<=state_wait;
            S7:if(!om_work)state_now<=state_wait;
            S8:if(!im_work)state_now<=state_wait;
            S9:if(!im_start)state_now<=state_wait;
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
            S6:state_wait=S7;
            S7:state_wait=S8;
            S8:if(!om_start)state_wait=S9;else state_wait=S3;
            S9:state_wait=S0;
        endcase
end
//control slave
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        om_start<=1'b0;
    end
    else begin
        case(state_now)
            S0:om_start<=1'b0;
            S2:om_start<=1'b1;
            S6:if(addra==addra_end)om_start<=1'b0;
        endcase
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        om_work<=1'b0;
    end
    else begin
        case(state_now)
            S0:om_work<=1'b0;
            S5:om_work<=1'b1;
            S7:om_work<=1'b0;
        endcase
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_delay<=1'b0;
    end
    else begin
        case(state_now)
            S0:cnt_delay<=1'b0;
            S3:cnt_delay<=1'b0;
            S4:cnt_delay<=cnt_delay+1'b1;
            S5:cnt_delay<=1'b0;
        endcase
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        addra<=1'b0;
    end
    else begin
        case(state_now)
            S0:addra<=1'b0;
            S3:if(first_addr)addra<=addra_begin;else addra<=addra+1'b1;
        endcase
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        om_data<=1'b0;
    end
    else begin
        case(state_now)
            S0:om_data<=1'b0;
            S5:om_data<=douta;
        endcase
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        first_addr<=1'b1;
    end
    else begin
        case(state_now)
            S0:first_addr<=1'b1;
            S6:first_addr<=1'b0;
        endcase
    end
end
endmodule
