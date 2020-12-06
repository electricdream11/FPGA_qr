`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/08 21:34:06
// Design Name: 
// Module Name: solve_img
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


module solve_img
#(
    parameter ADDR_WIDTH = 18,
    parameter STATE_WIDTH = 5
)
(
    input wire clk,
    input wire rst_n,
    //ram port of b
    output reg enb,
    output reg web,
    output reg [ADDR_WIDTH-1:0] addrb,
    output reg [7:0] dinb,
    input wire [7:0] doutb,
    //dmn cell
    output reg [31:0] width,
    output reg [31:0] height,
  
    output reg w1_work,
    input w1_work_end,
    input web_w1,
    input [7:0] dinb_w1,
    input [ADDR_WIDTH-1:0] addrb_w1,
    //axi  slave control
    input wire im_start,
    input wire im_work,
    input wire [31:0] im_data,
    output wire [31:0] om_data,
    output reg om_start,
    output reg om_work   
);
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
    localparam S10=4'd10;
    localparam S11=4'd11;
    localparam S12=4'd12;
    localparam S13=4'd13;
    localparam S14=4'd14;
    localparam W1=5'd16;   

    localparam DELAY=5;

//state
    reg [STATE_WIDTH-1:0] state_now;
    reg [STATE_WIDTH-1:0] state_wait;  
    reg w1_end;    
//im_data cnt          
    reg [31:0] cnt_data;
//read delay cnt
    reg [3:0] cnt_delay;
//ram
    reg fisrt_addrb;

//assign out
assign om_data[7:0]=doutb;
assign om_data[31:8]=1'b0;

always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            state_now<=S0;
        end
        else begin
            case(state_now)
                S0:state_now<=state_wait;
                S1:if(im_start)state_now<=state_wait;
                S2:if(im_work)state_now<=state_wait;
                S3:if(om_work)state_now<=state_wait;
                S4:if(!im_work)state_now<=state_wait;
                S5:if(!om_work)state_now<=state_wait;

                S7:if(om_start)state_now<=state_wait;
                S8:state_now<=state_wait;
                S9:if(om_work)state_now<=state_wait;
                S10:if(im_work)state_now<=state_wait;
                S11:state_now<=state_wait;
                S12:if(!om_work)state_now<=state_wait;
                S13:if(!im_work)state_now<=state_wait;
                S14:state_now<=state_wait;

                S6:state_now<=state_wait;
                W1:if(w1_end)state_now<=state_wait;
                
            endcase
        end
    end 
always@(*)begin
        if(!rst_n)begin
            state_wait<=S1;
        end
        else begin
            case(state_now)
                S0:state_wait=S1;
                S1:state_wait=S2;
                S2:state_wait=S3;
                S3:state_wait=S4;
                S4:state_wait=S5;
                S5:if(!im_start)state_wait=S6;else state_wait=S2;

                S7:state_wait=S8;
                S8:state_wait=S9;
                S9:state_wait=S10;
                S10:state_wait=S11;
                S11:state_wait=S12;
                S12:state_wait=S13;
                S13:if(!om_start)state_wait=S14;else state_wait=S8;
                S14:state_wait=S1;

                S6:state_wait=W1;
                W1:state_wait=S7;
            endcase
        end
    end  
//master write
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        om_work<=1'b0;
    end
    else begin
        case(state_now)
            S3:om_work<=1'b1;
            S5:om_work<=1'b0;
            S9:if(cnt_delay==DELAY-1)om_work<=1'b1;
            S12:om_work<=1'b0;
        endcase
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_delay<=1'b0;
    end
    else if(state_now==S0 || state_now==S10)begin
        cnt_delay<=1'b0;
    end
    else if(state_now==S9)begin
        if(cnt_delay==DELAY-1'b1)begin
            cnt_delay<=cnt_delay;
        end
        else begin
            cnt_delay<=cnt_delay+1'b1;
        end
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        om_start<=1'b0;
    end
    else begin
        case(state_now)
            S7:om_start<=1'b1;
            S11:if(addrb==width*height*3-1) om_start<=1'b0;
        endcase
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        fisrt_addrb<=1'b0;
    end
    else if(state_now==S7)begin
        fisrt_addrb<=1'b1;
    end
    else if(state_now==S12)begin
        fisrt_addrb<=1'b0;
    end
end
//ram
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        addrb<=1'b0;
    end
    else if(state_now==S8)begin
        if(fisrt_addrb)begin
            addrb<=1'b0;
        end
        else begin
            addrb<=addrb+1'b1;
        end
    end
    else if(state_now==W1)begin
        addrb<=addrb_w1;
    end
    else if(state_now==S7)begin
        addrb<=1'b0;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        web<=1'b0;
        dinb<=1'b0;
    end
    else if(state_now==W1)begin
        web<=web_w1;
        dinb<=dinb_w1;
    end
    else if(state_now==S7 || state_now==S0)begin
        web<=1'b0;
        dinb<=1'b0;       
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        enb<=1'b0;
    end
    else if(state_now==S6)begin
        enb<=1'b1;
    end
    else if(state_now==S14)begin
        enb<=1'b0;
    end
end
//prepare work 
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        width<=1'b0;
        height<=1'b0;
    end
    else if(state_now==S3) begin
        case(cnt_data)
            1'd0:width<=im_data;
            1'd1:height<=im_data;
        endcase
    end
    else if(state_now==S1)begin
        width<=1'b0;
        height<=1'b0;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_data<=1'b0;
    end
    else if(state_now==S5)begin
        if(!om_work)begin
            cnt_data<=cnt_data+1'b1;
        end
    end
    else if(state_now==S1)begin
        cnt_data<=1'b0;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        w1_end<=1'b0;
    end
    else if(state_now==W1)begin
        if(w1_work_end) begin
            w1_end<=1'b1;
        end
    end
    else if(state_now==S7)begin
        w1_end<=1'b0;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        w1_work<=1'b0;
    end
    else if(state_now==W1)begin
        w1_work<=1'b1;
    end
    else if(state_now==S7 || state_now==S0) begin
        w1_work<=1'b0; 
    end
end
endmodule
