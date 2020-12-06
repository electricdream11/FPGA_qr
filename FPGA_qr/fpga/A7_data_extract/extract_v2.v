`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/19 16:35:47
// Design Name: 
// Module Name: extract_v2
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

module extract_v2#(
    parameter ADDR_WIDTH_2 = 16,
    parameter ADDR_WIDTH_3 = 12

)
(
    input wire clk,
    input wire rst_n,

    input wire dmn_en,
    output reg dmn_end,

    output reg [ADDR_WIDTH_2-1:0] addr_M,
    input wire [ADDR_WIDTH_2-1:0] addr_S,
    input wire dout_M,
    output wire dout_S,

    input wire [14:0] info,
    input wire [31:0] width,
    input wire [ADDR_WIDTH_2-1:0] addr_00,
    input wire [ADDR_WIDTH_2-1:0] addr_11,
    input wire [ADDR_WIDTH_2-1:0] addr_width,

    input wire [ADDR_WIDTH_3-1:0] addr_buf_S,
    output wire dout_buf_S
);
//delay read
    localparam READ_DELAY = 10;
    localparam ADDR_BUF_INIT = 27;
    
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
localparam S10=4'd10;
localparam S11=4'd11;
localparam S12=4'd12;

localparam E1=5'd16;
localparam E2=5'd17;
localparam E3=5'd18;
localparam E4=5'd19;
//mode param
localparam M0 = 4'd0;
localparam M1 = 4'd1;
localparam M2 = 4'd2;
localparam M3 = 4'd3;
//state varible
reg [4:0] state_now;
reg [4:0] state_wait;

//mode varible
reg [3:0] mode_now;
//addr
reg first_addr;
//caculate data
reg [ADDR_WIDTH_2-1:0] data_init;
reg [7:0] qr_width;
reg [2:0] qr_hide;
reg [ADDR_WIDTH_2-1:0] addr_height;
reg [7:0] mode_last;
reg [7:0] data_mode0_end;
reg [7:0] data_mode1_end;
reg [7:0] data_mode2_end;
reg [7:0] data_mode0_half;
reg [7:0] data_mode1_half;
reg [7:0] data_mode2_half;
reg [7:0] data_mode1_jump0;
reg [7:0] data_mode1_jump1;

reg [7:0] qr_x;
reg [7:0] qr_y;
reg [11:0] numb;
//count
reg [3:0] cnt_delay;
reg [ADDR_WIDTH_2-1:0] cnt_data;
reg [7:0] cnt_mode;
//mode_small
reg mode_small;
reg anti_hide;
//data
reg data_temp;
//ram buf
reg wea_buf;
reg dina_buf;
reg [ADDR_WIDTH_3-1:0] addra_buf;
reg [4:0] cnt_buf;
//connect
assign dout_S = dout_M;
//state machine
always@(posedge clk or negedge rst_n)begin
     if(!rst_n)begin
         state_now<=S0;
     end
     else begin
         case(state_now)
            S0:if(dmn_en)state_now<=state_wait;
            S1:if(cnt_delay==4'd10)state_now<=state_wait;
            S2:state_now<=state_wait;
            S3:state_now<=state_wait;
            S4:if(cnt_delay==READ_DELAY-1'b1) state_now<=state_wait;
            S5:state_now<=state_wait;
            S6:state_now<=state_wait;
            S7:if(wea_buf)state_now<=state_wait;
            S8:state_now<=state_wait;
            S9:state_now<=state_wait;
            S10:state_now<=state_wait;
            S11:if(!dmn_en)state_now<=state_wait;
            S12:state_now<=state_wait;

            E1:state_now<=state_wait;
            E2:state_now<=state_wait;
            E3:state_now<=state_wait;
            E4:state_now<=state_wait;
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
        S8:state_wait=S9;
        S9:state_wait=S10;
        S10:if(cnt_mode==mode_last)state_wait=E1;else state_wait=S2;
        E1:state_wait=E2;
        E2:state_wait=E3;
        E3:state_wait=E4;
        E4:if(cnt_buf==ADDR_BUF_INIT) state_wait=S11;else state_wait=E1;
        S11:state_wait=S12;
        S12:state_wait=S0;
     endcase
 end
 //S1
 always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        first_addr<=1'b1;
    end
    else if(state_now==S0)begin
        first_addr<=1'b1;
    end
    else if(state_now==S9)begin
        first_addr<=1'b0;
    end
    
 end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_delay<=1'b0;
    end
    else begin
        case(state_now)
            S0:cnt_delay<=1'b0;
            S1:cnt_delay<=cnt_delay+1'b1;
            S2:cnt_delay<=1'b0;
            S4:cnt_delay<=cnt_delay+1'b1;
        endcase
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        addr_height<=1'b0;
        qr_hide<=1'b0;
        qr_width<=1'b0;
        data_init<=1'b0;
        mode_last<=1'b0;
        data_mode0_end<=1'b0;
        data_mode1_end<=1'b0;
        data_mode2_end<=1'b0;
        data_mode0_half<=1'b0;
        data_mode1_half<=1'b0;
        data_mode2_half<=1'b0;
        data_mode1_jump0<=1'b0;
        data_mode1_jump1<=1'b0; 
        numb<=1'b0;       
    end
    else if(state_now==S1)begin
        case(cnt_delay)
            4'd0:addr_height<=width*addr_width;
            4'd1:qr_hide<=info[12:10];
            4'd2:qr_width<=(addr_11-addr_00)/width+1;
            4'd3:qr_width<=qr_width/addr_width;
            4'd4:begin
                data_init<=addr_00+addr_width*(qr_width-1);
                data_mode1_jump0<=(qr_width-7)*2;
                data_mode1_jump1<=(qr_width+5)*2;
            end
            4'd5:numb<=(qr_width-9)*8+(qr_width-17)*8;
            4'd6:begin
                 mode_last<=(qr_width-1)/4;
                 numb<=numb+(qr_width-1)*(qr_width-17);
            end
            4'd7:begin
                data_mode0_end<=(qr_width-9)*4;
                data_mode1_end<=(qr_width-1)*4;
                data_mode2_end<=(qr_width-9-8)*4;
            end
            4'd8:begin
                data_mode0_half<=data_mode0_end/2;
                data_mode1_half<=data_mode1_end/2;
                data_mode2_half<=data_mode2_end/2;
            end
        endcase
    end
    else if(state_now==S11)begin
        addr_height<=1'b0;
        qr_hide<=1'b0;
        qr_width<=1'b0;
        data_init<=1'b0;
        mode_last<=1'b0;
        data_mode0_end<=1'b0;
        data_mode1_end<=1'b0;
        data_mode2_end<=1'b0;
        data_mode0_half<=1'b0;
        data_mode1_half<=1'b0;
        data_mode2_half<=1'b0;
        numb<=1'b0;
    end
end
//S2
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        mode_now<=M0;
    end
    else if(state_now==S0 || state_now==S11)begin
        mode_now<=M0;
    end
    else if(state_now==S2)begin
        case(mode_now)
            M0:if(cnt_mode==2'd2)mode_now<=M1;
            M1:if(cnt_mode==mode_last-2'd2)mode_now<=M2;
            M2:if(cnt_mode==mode_last-1'b1)mode_now<=M3;
            M3:if(cnt_mode==mode_last)mode_now<=mode_now;//not way
        endcase
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        mode_small<=1'b0;
    end
    else if(state_now==S0)begin
        mode_small<=1'b0;
    end
    else if(state_now==S2)begin
        mode_small<=cnt_data%2;
    end
end
//S3
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        addr_M<=1'b0;
    end
    else begin
        case(state_now)
            S0:addr_M<=1'b0;
            S3: begin
                case(mode_now)
                    M0: addr_task0;
                    M1: addr_task1;
                    M2: addr_task2;
                    M3: addr_task3;
                endcase
            end
            S11:addr_M<=addr_S;
        endcase
    end
end
task addr_task0; //block 0 
    begin
        if(cnt_data<data_mode0_half)begin
            if(first_addr)addr_M<=data_init;
            else if(mode_small)addr_M<=addr_M - addr_width;
            else addr_M<=addr_M + addr_height + addr_width;
        end
        else if(cnt_data==data_mode0_half)begin
            addr_M<=addr_M - addr_width;
        end
        else if(cnt_data> data_mode0_half && cnt_data<data_mode0_end)begin
            if(mode_small)addr_M<=addr_M - addr_width;
            else addr_M <= addr_M - addr_height + addr_width;
        end
        else if(cnt_data==data_mode0_end)begin
            addr_M<= addr_M - addr_width;
        end
    end
endtask
task addr_task1; //block 1
    begin
        if(cnt_data<data_mode1_half)begin
            if(cnt_data==data_mode1_jump0) addr_M<=addr_M+addr_height*2+addr_width;
            else if(mode_small)addr_M<=addr_M - addr_width;
            else addr_M<=addr_M + addr_height + addr_width;
        end
        else if(cnt_data==data_mode1_half)begin
            addr_M<=addr_M - addr_width;
        end
        else if(cnt_data> data_mode1_half && cnt_data<data_mode1_end)begin
            if(cnt_data==data_mode1_jump1) addr_M<=addr_M- addr_height*2+addr_width;
            else if(mode_small)addr_M<=addr_M - addr_width;
            else addr_M <= addr_M - addr_height + addr_width;
        end
        else if(cnt_data==data_mode1_end)begin
            if(cnt_mode==mode_last-2'd3) addr_M<=addr_M - addr_width + 8*addr_height;
            else addr_M<= addr_M - addr_width;
        end
    end
endtask
task addr_task2; //block 2
    begin
        if(cnt_data<data_mode2_half)begin
            if(mode_small)addr_M<=addr_M - addr_width;
            else addr_M<=addr_M + addr_height + addr_width;
        end
        else if(cnt_data==data_mode2_half)begin
            addr_M<=addr_M - addr_width*2;
        end
        else if(cnt_data> data_mode2_half && cnt_data<data_mode2_end)begin
            if(mode_small)addr_M<=addr_M - addr_width;
            else addr_M <= addr_M - addr_height + addr_width;
        end
        else if(cnt_data==data_mode2_end)begin
            addr_M<= addr_M - addr_width;
        end
    end
endtask
task addr_task3; //block 3
    begin
        if(cnt_data<data_mode2_half)begin
            if(mode_small)addr_M<=addr_M - addr_width;
            else addr_M<=addr_M + addr_height + addr_width;
        end
        else if(cnt_data==data_mode2_half)begin
            addr_M<=addr_M - addr_width;
        end
        else if(cnt_data> data_mode2_half && cnt_data<data_mode2_end)begin
            if(mode_small)addr_M<=addr_M - addr_width;
            else addr_M <= addr_M - addr_height + addr_width;
        end
        else if(cnt_data==data_mode2_end)begin
            addr_M<= addr_M;
        end
    end
endtask
//S4 delay-->S1 used
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        qr_x<=1'b0;
        qr_y<=1'b0;
        anti_hide<=1'b0;
    end
    else if(state_now==S0) begin
        qr_x<=1'b0;
        qr_y<=1'b0;
        anti_hide<=1'b0;
    end
    else if(state_now==S4)begin
        case(cnt_delay)
            4'd0:begin
                qr_x<=(addr_M - addr_00)%width/addr_width;
                qr_y<=(addr_M - addr_00)/addr_height;
            end
            4'd1:begin
                qr_y<=qr_width-1'b1-qr_y;
            end
            4'd3:begin
                case(qr_hide)//5 4 7 6 1 0 3 2
                    3'b000: if((qr_x*qr_y)%2+(qr_x*qr_y)%3==0)anti_hide<=1'b1;
                            else anti_hide<=1'b0;
                    3'b001: if((qr_x/2+qr_y/3)%2==0)anti_hide<=1'b1;  
                            else anti_hide<=1'b0;              
                    3'b010: if(((qr_x*qr_y)%3+(qr_x+qr_y)%2)%2==0)anti_hide<=1'b1;
                            else anti_hide<=1'b0;               
                    3'b011: if(((qr_x*qr_y)%2+(qr_x*qr_y)%3)%2==0)anti_hide<=1'b1;
                            else anti_hide<=1'b0;               
                    3'b100: if( qr_x %2 ==0 )anti_hide<=1'b1;    
                            else anti_hide<=1'b0;           
                    3'b101: if( (qr_x+qr_y)%2==0  )  anti_hide<=1'b1; 
                            else anti_hide<=1'b0;                
                    3'b110: if( (qr_x+ qr_y)%3==0  )   anti_hide<=1'b1; 
                            else anti_hide<=1'b0;              
                    3'b111: if( qr_y%3==0  )   anti_hide<=1'b1;  
                            else anti_hide<=1'b0;             
                endcase
            end
        endcase
    end
end
//S5
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        data_temp<=1'b0;
    end
    else if(state_now==S0)begin
        data_temp<=1'b0;
    end
    else if(state_now==S5)begin
        if(anti_hide)data_temp<=~dout_M;
        else data_temp<=dout_M;
    end
end
//S6 S7
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        addra_buf<=1'b0;
    end
    else begin
        case(state_now)
            S0: addra_buf<=1'b0;
            S6: if(addra_buf==1'b0)addra_buf<=ADDR_BUF_INIT;
                else addra_buf<=addra_buf+1'b1;
            E2: if(cnt_buf==1'b0)addra_buf<=1'b0;
                else addra_buf<=addra_buf+1'b1;
            S11:addra_buf<=1'b0;
        endcase
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        dina_buf<=1'b0;
    end
    else begin
        case(state_now)
            S0:dina_buf<=1'b0;
            S6:dina_buf<=data_temp;
            E1:begin
                case(cnt_buf)
                    5'd0:dina_buf<=numb[0];
                    5'd1:dina_buf<=numb[1];
                    5'd2:dina_buf<=numb[2];
                    5'd3:dina_buf<=numb[3];
                    5'd4:dina_buf<=numb[4];
                    5'd5:dina_buf<=numb[5];
                    5'd6:dina_buf<=numb[6];
                    5'd7:dina_buf<=numb[7];
                    5'd8:dina_buf<=numb[8];
                    5'd9:dina_buf<=numb[9];
                    5'd10:dina_buf<=numb[10];
                    5'd11:dina_buf<=numb[11];

                    5'd12:dina_buf<=info[0];
                    5'd13:dina_buf<=info[1];
                    5'd14:dina_buf<=info[2];
                    5'd15:dina_buf<=info[3];
                    5'd16:dina_buf<=info[4];
                    5'd17:dina_buf<=info[5];
                    5'd18:dina_buf<=info[6];
                    5'd10:dina_buf<=info[7];
                    5'd20:dina_buf<=info[8];
                    5'd21:dina_buf<=info[9];
                    5'd22:dina_buf<=info[10];
                    5'd23:dina_buf<=info[11];
                    5'd24:dina_buf<=info[12];
                    5'd25:dina_buf<=info[13];
                    5'd26:dina_buf<=info[14];
                    default:dina_buf<=dina_buf;
                endcase
            end
            S11:dina_buf<=1'b0;
        endcase
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        wea_buf<=1'b0;
    end
    else begin
        case(state_now)
            S0: wea_buf<=1'b0;
            S7: wea_buf<=1'b1;
            S8: wea_buf<=1'b0;
            E3: wea_buf<=1'b1;
            E4: wea_buf<=1'b0;
        endcase
    end
end
//S9
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_data<=1'b0;
    end
    else if(state_now==S0)begin
        cnt_data<=1'b0;
    end
    else if(state_now==S9)begin
        case(mode_now)
            M0: if(cnt_data==data_mode0_end)cnt_data<=1'b1; 
                else cnt_data<=cnt_data+1'b1;
            M1: if(cnt_data==data_mode1_end)cnt_data<=1'b1;
                else cnt_data<=cnt_data+1'b1;
            M2: if(cnt_data==data_mode2_end)cnt_data<=1'b1;
                else cnt_data<=cnt_data+1'b1;
            M3: if(cnt_data==data_mode2_end)cnt_data<=1'b1;
                else cnt_data<=cnt_data+1'b1;
        endcase
    end
end
//S8
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_mode<=1'b0;
    end
    else if(state_now==S0)begin
        cnt_mode<=1'b0;
    end
    else if(state_now==S8)begin
        case(mode_now)
            M0:if(cnt_data==data_mode0_end)cnt_mode<=cnt_mode+1'b1;
            M1:if(cnt_data==data_mode1_end)cnt_mode<=cnt_mode+1'b1;
            M2,M3:if(cnt_data==data_mode2_end)cnt_mode<=cnt_mode+1'b1;
        endcase
    end
end
//S10 choose
//E1--E4 ==> ram_buf
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_buf<=1'b0;
    end
    else if(state_now==S0)begin
        cnt_buf<=1'b0;
    end
    else if(state_now==E3)begin
        cnt_buf<=cnt_buf+1'b1;
    end
end
//S11
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        dmn_end<=1'b0;
    end
    else if(state_now==S0)begin
        dmn_end<=1'b0;
    end
    else if(state_now==S11)begin
        dmn_end<=1'b1;
    end
end
//ram buf==>two ports to work other time
blk_mem_gen_0 your_instance_name (
  .clka(clk),    // input wire clka
  .wea(wea_buf),      // input wire [0 : 0] wea
  .addra(addra_buf),  // input wire [11 : 0] addra
  .dina(dina_buf),    // input wire [0 : 0] dina
  .clkb(clk),    // input wire clkb
  .addrb(addr_buf_S),  // input wire [11 : 0] addrb
  .doutb(dout_buf_S)  // output wire [0 : 0] doutb
);

endmodule
