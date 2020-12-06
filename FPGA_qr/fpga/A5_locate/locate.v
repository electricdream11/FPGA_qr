`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/12 16:26:35
// Design Name: 
// Module Name: locate
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


module locate #(
    parameter ADDR_WIDTH_2 =16,
    parameter READ_DELAY = 5
)
(
    input clk,
    input rst_n,

    input dmn_en,
    output reg dmn_end,

    input [31:0] width,
    input [31:0] height,
    input douta,
    output reg [ADDR_WIDTH_2-1:0] addra,
    input [ADDR_WIDTH_2-1:0] addra_dmn,

    output reg [31:0] x0,
    output reg [31:0] y0,
    output reg [31:0] x1,
    output reg [31:0] y1,
    output reg [ADDR_WIDTH_2-1:0] addr_00,
    output reg [ADDR_WIDTH_2-1:0] addr_11,
    output reg [ADDR_WIDTH_2-1:0] addr_width

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
//mode param
localparam M0=3'd0;
localparam M1=3'd1;
localparam M2=3'd2;
localparam M3=3'd3;
localparam MODE_END=3'd3;
//state varible
reg [3:0] state_now;
reg [3:0] state_wait;
//state delay
wire delay_end;
reg [4:0] cnt_delay;
//mode varible
reg [2:0] mode_now;
reg mode_change;
//addr control varible
reg first_addr;
wire [31:0] addr_end;

reg [ADDR_WIDTH_2-1:0] cnt_addr;
//state machine
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        state_now<=1'b0;
    end
    else begin
        case(state_now)
            S0:if(dmn_en)state_now<=state_wait;
            S1:state_now<=state_wait;
            S2:state_now<=state_wait;
            S3:state_now<=state_wait;
            S4:if(delay_end)state_now<=state_wait;
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
        S6:if(mode_now==MODE_END)state_wait=S7;else state_wait=S2;
        S7:state_wait=S8;
        S8:state_wait=S0;
    endcase
end
//addr end connect
assign addr_end =width*height - 1'b1;
//delay end connect
assign delay_end = (cnt_delay==READ_DELAY-1'b1) ;
//mode 
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        mode_now<=M0;
    end
    else if(state_now==S0 || state_now==S7)begin
        mode_now<=M0;
    end
    else if(state_now==S2)begin
        case(mode_now)
            M0: if(mode_change) mode_now<=M1;
            M1: if(mode_change) mode_now<=M2;
            M2: if(mode_change) mode_now<=M3;
            M3: mode_now<=mode_now;
        endcase
    end
end
//addra
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        addra<=1'b0;
    end
    else if(state_now==S0 || state_now==S8)begin
        addra<=1'b0;
    end
    else if(state_now==S3)begin
        case(mode_now)
            M0: if(first_addr) addra<=1'b0; else addra<=addra+1'b1;
            M1: if(!first_addr) addra<=addr_end; else addra<=addra-1'b1;
            M2: if(first_addr) addra<=addr_00;else addra<=addra+1'b1+width;
            M3: addra<=1'b0;
        endcase
    end
    else if(state_now==S7)begin
        addra<=addra_dmn;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        first_addr<=1'b1;
    end
    else if(state_now==S0)begin
        first_addr<=1'b1;
    end
    else if(state_now==S4)begin
        case(mode_now)
            M0:first_addr<=1'b0;
            M1:first_addr<=1'b1;
            M2:first_addr<=1'b0;
            M3:first_addr<=1'b0;
        endcase
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_delay<=1'b0;
    end
    else if(state_now==S0 || state_now==S5)begin
        cnt_delay<=1'b0;
    end
    else if(state_now==S4)begin
        if(cnt_delay==READ_DELAY-1'b1) cnt_delay<=cnt_delay;
        else cnt_delay<=cnt_delay+1'b1;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        addr_00<=1'b0;
        addr_11<=1'b0;
        addr_width<=1'b0;
    end
    else if(state_now==S0 || state_now==S8)begin
        addr_00<=1'b0;
        addr_11<=1'b0;
        addr_width<=1'b0;       
    end
    else if(state_now==S5)begin
        case(mode_now)
            M0:if(douta)addr_00<=addra;
            M1:if(douta)addr_11<=addra;
            M2:if(!douta)addr_width<=cnt_addr-1'b1;
            default: ;
        endcase
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_addr<=1'b0;
    end
    else if(state_now==S0 || state_now==S8)begin
        cnt_addr<=1'b0;
    end
    else if(state_now==S3)begin
        if(mode_now==M2) cnt_addr<=cnt_addr+1'b1;
    end
end
//mode change
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        mode_change<=1'b0;
    end
    else if(state_now==S0 || state_now==S8)begin
        mode_change<=1'b0;
    end
    else if(state_now==S5)begin
        case(mode_now)
            M0:if(douta)mode_change<=1'b1; else mode_change<=1'b0;
            M1:if(douta)mode_change<=1'b1; else mode_change<=1'b0;
            M2:if(!douta)mode_change<=1'b1; else mode_change<=1'b0;
            M3:mode_change<=1'b0;
        endcase
    end
end
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

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        x0<=1'b0;
        y0<=1'b0;
        x1<=1'b0;
        y1<=1'b0;
    end
    else if(state_now==S0)begin
        x0<=1'b0;
        y0<=1'b0;
        x1<=1'b0;
        y1<=1'b0;    
    end
    else if(state_now==S7)begin
        x0<=addr_00%width-1;
        y0<=addr_00/width-1;
        x1<=addr_11%width+1;
        y1<=addr_11/width+1;
    end
end
endmodule
