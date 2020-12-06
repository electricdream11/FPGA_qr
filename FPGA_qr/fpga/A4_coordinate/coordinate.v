`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/10 20:05:51
// Design Name: 
// Module Name: coordinate
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


module coordinate#(
    parameter ADDR_WIDTH = 18,
    parameter ADDR_WIDTH_2 = 16,
    parameter DELAY = 4'd10,
    parameter COLOR_LINE = 24'h111111 //rgb
)
(
    input clk,
    input rst_n,

    input [31:0] width,
    input [31:0] height,

    input dmn_en,
    output reg dmn_end,
//reg to value
    input [ADDR_WIDTH_2-1:0] addra_dmn,
    output douta_dmn,
//reg to imag
    input [7:0] doutb,
    output reg web,
    output reg [7:0] dinb,
    output reg [ADDR_WIDTH-1:0] addrb,

    input web_dmn,
    input [7:0] dinb_dmn,
    input [ADDR_WIDTH-1:0] addrb_dmn
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
localparam S9=4'd9;
localparam S10=4'd10;
//state varible
reg [3:0] state_now;
reg [3:0] state_wait;
reg get_value;
reg get_all;
reg S4_end;
reg S8_end;
//ram of two value
reg wea;
reg dina;
reg [ADDR_WIDTH_2-1:0] addra;
wire douta_dmn_wire;
//func varible
wire [31:0] addr_end;
reg first_addr;
reg [3:0] cnt_delay;
reg [7:0] data_read1;
reg [7:0] data_read2;
reg [7:0] data_read3;
reg [1:0] cnt_read;
//state machine
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        state_now<=S0;
    end
    else begin
        case(state_now)
            S0:if(dmn_en)state_now<=state_wait;
            S1:state_now<=state_wait;
            S2:state_now<=state_wait;
            S3:if(cnt_delay==DELAY-1'b1)state_now<=state_wait;
            S4:if(S4_end)state_now<=state_wait;
            S5:state_now<=state_wait;
            S6:state_now<=state_wait;
            S7:if(wea)state_now<=state_wait;
            S8:if(S8_end)state_now<=state_wait;
            S9:if(!dmn_en)state_now<=state_wait;
            S10:if(!dmn_end)state_now<=state_wait;            
        endcase
    end
end
always@(*)begin
    case(state_now)
        S0:state_wait=S1;
        S1:state_wait=S2;
        S2:state_wait=S3;
        S3:state_wait=S4;
        S4:if(get_value)state_wait=S5;else state_wait=S2;
        S5:state_wait=S6;
        S6:state_wait=S7;
        S7:state_wait=S8;
        S8:if(get_all)state_wait=S9; else state_wait=S2;
        S9:state_wait=S10;
        S10:state_wait=S0;
    endcase
end
//addr addr end
assign addr_end = width*height*3;
//assign douta_dmn
assign douta_dmn = douta_dmn_wire & dmn_end;
//addr imag
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        addrb<=1'b0;
    end
    else begin
        case(state_now)
            S0:addrb<=1'b0;
            S2: if(first_addr) addrb<=1'b0;
                else addrb<=addrb+1'b1;
            S9:addrb<=addrb_dmn;
        endcase
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_delay<=1'b0;
    end
    else if(state_now==S0 || state_now==S4)begin
        cnt_delay<=1'b0;
    end
    else if(state_now==S3)begin
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
        data_read1<=1'b0;
        data_read2<=1'b0;
        data_read3<=1'b0;
    end
    else if(state_now==S0 || state_now==S10)begin
        data_read1<=1'b0;
        data_read2<=1'b0;
        data_read3<=1'b0;
    end
    else if(state_now==S3 && cnt_delay==DELAY-1'b1)begin
        case(cnt_read)
            2'b01:data_read1<=doutb;
            2'b10:data_read2<=doutb;
            2'b11:data_read3<=doutb;
        endcase
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_read<=1'b0;
    end
    else if(state_now==S0 || state_now==S9)begin
        cnt_read<=1'b0;
    end
    else if(state_now==S2)begin
        if(cnt_read==2'b11)begin
            cnt_read<=2'b01;
        end
        else begin
            cnt_read<=cnt_read+1'b1;
        end
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        first_addr<=1'b1;
    end
    else if(state_now==S0)begin
        first_addr<=1'b1;
    end
    else if(state_now==S3)begin
        first_addr<=1'b0;
    end
end
//dmn imag reg 
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        web<=1'b0;
    end
    else if(state_now==S0 || state_now==S10)begin
        web<=1'b0;
    end
    else if(state_now==S9)begin
        web<=web_dmn;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        dinb<=1'b0;
    end
    else if(state_now==S0 || state_now==S10)begin
        dinb<=1'b0;
    end
    else if(state_now==S9)begin
        dinb<=dinb_dmn;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        get_value<=1'b0;
    end
    else if(state_now==S0 || state_now==S6)begin
        get_value<=1'b0;
    end
    else if(state_now==S4)begin
        if(cnt_read==2'b11) get_value<=1'b1;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        S4_end<=1'b0;
    end
    else if(state_now==S4)begin
        S4_end<=1'b1;
    end
    else begin
        S4_end<=1'b0;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        addra<=1'b0;
    end
    else if(state_now==S0)begin
        addra<=1'b0;
    end
    else if(state_now==S5)begin
        if(addrb==2'd2) addra<=1'b0;
        else addra<=addra+1'b1;
    end
    else if(state_now==S9)begin
        addra<=addra_dmn;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        dina<=1'b0;
    end
    else if(state_now==S0 && state_now==S10)begin
        dina<=1'b0;
    end
    else if(state_now==S6)begin
        if( data_read1>=COLOR_LINE[7:0] ||
            data_read2>=COLOR_LINE[15:8] ||
            data_read3>=COLOR_LINE[23:16] )
            dina<=1'b0;
        else 
            dina<=1'b1;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        wea<=1'b0;
    end
    else if(state_now==S0 || state_now==S8)begin
        wea<=1'b0;
    end
    else if(state_now==S7)begin
        wea<=1'b1;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        S8_end<=1'b0;
    end
    else if(state_now==S8)begin
        S8_end<=1'b1;
    end
    else begin
        S8_end<=1'b0;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        get_all<=1'b0;
    end
    else if(state_now==S0)begin
        get_all<=1'b0;
    end
    else if(state_now==S8)begin
        if(addrb==addr_end-1'b1) get_all<=1'b1;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        dmn_end<=1'b0;
    end
    else if(state_now==S0 || state_now==S10)begin
        dmn_end<=1'b0;
    end
    else if(state_now==S9)begin
        dmn_end<=1'b1;
    end
end
//value ram
blk_mem_gen_0 U1_value_reg (
  .clka(clk),    // input wire clka
  .wea(wea),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [15 : 0] addra
  .dina(dina),    // input wire [0 : 0] dina
  .douta(douta_dmn_wire)  // output wire [0 : 0] douta
);


endmodule
