module imag_get(
	input clk,
	input rst_n,

	input im_start,
	input im_work,

	output reg om_start,
	output reg om_work,

	input [7:0] im_data,
	output [7:0] om_data,
	//ram port b
	input wire enb,
	input wire web,
	input wire [17:0] addrb,
	input wire [7:0] dinb,
	output wire [7:0] doutb
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
    localparam S10=4'd10;
    localparam S11=4'd11;
//delay read param
	localparam READ_DEALY=4'd10;
	reg [3:0] read_en_delay;
//state varible
	reg [3:0] state_now;
	reg [3:0] state_wait;
	reg s2_end; //just for delay one clk 
//	reg s8_end;
//ram varible
	reg [17:0] addr;
	reg wea;
	wire [7:0] dina;
	wire [7:0] douta;
//ram help
	reg wea_en;
	reg first_addr;
	reg [1:0] cnt_addr;
	reg read_en;
//ports connect
	assign dina=im_data[7:0];
	assign om_data[7:0]=douta;
//state machine
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		state_now<=S0;
	end
	else begin
		case(state_now)
			S0:if(im_start)state_now<=state_wait;
			S1:if(im_work)state_now<=state_wait;
			S2:if(s2_end)state_now<=state_wait;
			S3:if(om_work)state_now<=state_wait;
			S4:if(!im_work)state_now<=state_wait;
			S5:state_now<=state_wait;
			S6:if(om_start)state_now<=state_wait;
			S7:state_now<=state_wait;
			S8:if(!om_work)state_now<=state_wait;
			S9:if(!im_work)state_now<=state_wait;
			S10:if(!im_work)state_now<=state_wait;
			//to buff s7;
			S11:if(im_work)state_now<=state_wait;
		endcase
	end
end

always@(*)begin
	if(!rst_n)begin
		state_wait=S1;
	end
	else begin
		case(state_now)
			S0:state_wait=S1;
			S1:state_wait=S2;
			S2:state_wait=S3;
			S3:state_wait=S4;
			S4:if(!im_start)state_wait=S5;else state_wait=S1;
			S5:state_wait=S6;
			S6:state_wait=S7;//change
			S7:state_wait=S11;
			S8:state_wait=S9;
			S9:if(!om_start)state_wait=S10;else state_wait=S7;
			S10:state_wait=S0;
			S11:state_wait=S8;
		endcase
	end
end
//ram connect
blk_mem_gen_0 U1_ram (
  .clka(clk),    // input wire clka
  .wea(wea),      // input wire [0 : 0] wea
  .addra(addr),  // input wire [17 : 0] addra
  .dina(dina),    // input wire [7 : 0] dina
  .douta(douta),  // output wire [7 : 0] douta
  .clkb(clk),    // input wire clkb
  .enb(enb),      // input wire enb
  .web(web),      // input wire [0 : 0] web
  .addrb(addrb),  // input wire [17 : 0] addrb
  .dinb(dinb),    // input wire [7 : 0] dinb
  .doutb(doutb)  // output wire [7 : 0] doutb
);

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		s2_end<=1'b0;
	end
	else if(state_now==S2)begin
		if(wea)begin
			s2_end<=1'b1;
		end
	end
	else begin
		s2_end<=1'b0;
	end

end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		wea<=1'b0;
	end
	else if(state_now==S2)begin
		if(wea_en)
		wea<=1'b1;
	end
	else begin
		wea<=1'b0;
	end
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		addr<=1'b0;
		wea_en<=1'b0;
		cnt_addr<=1'b0;
		read_en<=1'b0;
	end
	else if(state_now==S2)begin
		if(!first_addr && wea_en==1'b0)begin
			addr<=addr+1'b1;
			wea_en<=1'b1;
		end
		else begin
			addr<=addr;
			wea_en<=1'b1;
		end
	end
	else if(state_now==S7)begin
		if(first_addr)begin
			addr<=addr-2;
			cnt_addr<=1'b0;
		end
		else if(cnt_addr==2'd2) begin
			addr<=addr-5;
			cnt_addr<=2'd0;
		end
		else begin
			addr<=addr+1'b1;
			cnt_addr<=cnt_addr+1'b1;
		end
	end
	else if(state_now==S11)begin
	   read_en<=1'b1;
	end
	else begin
		wea_en<=1'b0;
		read_en<=1'b0;
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
	else if(state_now==S5)begin
		first_addr<=1'b1;
	end
	else if(state_now==S8)begin
		first_addr<=1'b0;
	end
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		read_en_delay<=1'b0;
	end
	else if(state_now==S11)begin
	 	if(read_en_delay==READ_DEALY)begin
			read_en_delay<=read_en_delay;
		end
		else if(read_en)begin
			read_en_delay<=read_en_delay+1'b1;
		end
	end
	else begin
		read_en_delay<=1'b0;
	end
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		om_work<=1'b0;
	end
	else if(state_now==S3)begin
		om_work<=1'b1;
	end
	else if(state_now==S4) begin
	       if(!im_work)begin
		          om_work<=1'b0;
		   end
	end
	else if(state_now==S11)begin
		if(read_en_delay==READ_DEALY)begin
			 om_work<=1'b1;
		end
	end
	else if(state_now==S8)begin	      
		om_work<=1'b0;
	end

end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		om_start<=1'b0;
//		s8_end<=1'b0;
	end
	else if(state_now==S6)begin
		om_start<=1'b1;
	end
	else if(state_now==S8)begin
		if(addr==2)begin //end of send
			om_start<=1'b0;
//			s8_end<=1'b1;
		end
		else begin
			om_start<=1'b1;
//			s8_end<=1'b1;
		end
	end
//	else begin
//		s8_end<=1'b0;
//	end
end

endmodule