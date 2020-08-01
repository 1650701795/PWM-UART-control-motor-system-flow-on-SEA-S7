`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/27 15:34:14
// Design Name: 
// Module Name: PWM_motor
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



module PWM_motor(
input  sys_clk,
input  sys_rst_n,
input  dir,					//���ƶ� 1����ת 0����ת
input  sw,					//����
output [3:0] pwmout			//���������������
    );
    
    
reg 	sys_clk1h;				//�������Ƶ��
reg	[3:0] ctrl;				//DCBA�������

parameter 	S1 = 3'b000,		//�������״̬ A
			S2 = 3'b001,		//AB
			S3 = 3'b010,		//B
			S4 = 3'b011,		//BC
			S5 = 3'b100,
			S6 = 3'b101,
			S7 = 3'b110,
			S8 = 3'b111;
			
reg [2:0] cur_state,next_state;	

wire 	[24:0]		speed;
reg		[24:0]		cnt;


assign speed = sw ? 32'd12000:32'd24000;
			

always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if(!sys_rst_n)
			sys_clk1h <= 1'b0;
		else if(cnt < (speed>>1))			
			sys_clk1h <= 1'b0;
		else 
			sys_clk1h <= 1'b1;				
	end
      	
always @(posedge sys_clk or negedge sys_rst_n)
	begin
		if(!sys_rst_n)
			cnt <= 1'b0;
		else if(cnt == (speed-1))
			cnt <= 1'b0;
		else 
			cnt <= cnt + 1'b1;
	end

always@(posedge sys_clk1h or negedge sys_rst_n)        //��һ��
	if(!sys_rst_n)
		cur_state <= S1;
    else 
	    cur_state <= next_state;

always@(cur_state or sys_rst_n or dir)        //�ڶ��Σ�״̬ת��,dir���Ʒ���
	if(!sys_rst_n)
		begin
			next_state = S1;
		end
	else
		begin
			if(dir)                         //�����ƶ�Ϊ1����ת
				case(cur_state)
					S1:next_state = S2;     //
					S2:next_state = S3;
					S3:next_state = S4;
					S4:next_state = S5;
					S5:next_state = S6;     //
					S6:next_state = S7;
					S7:next_state = S8;
					S8:next_state = S1;
				endcase
			else                             //�����ƶ�Ϊ0����ת
				case(cur_state)
					S1:next_state = S8;      //
					S2:next_state = S1;
					S3:next_state = S2;
					S4:next_state = S3;
					S5:next_state = S4;      
					S6:next_state = S5;
					S7:next_state = S6;
					S8:next_state = S7;
				endcase
		end

always@(posedge sys_clk1h or negedge sys_rst_n)			//�����Σ���ǰ״̬���
	if(!sys_rst_n)
		begin
			ctrl <= 4'b1000;
		end
	else
		begin
			case(next_state)
				S1: ctrl <= 4'b1000;           //A
				S2: ctrl <= 4'b1100;		   //AB
				S3: ctrl <= 4'b0100;		   //B
				S4: ctrl <= 4'b0110;		   //BC
				S5: ctrl <= 4'b0010;           //C
				S6: ctrl <= 4'b0011;		   //CD
				S7: ctrl <= 4'b0001;		   //D
				S8: ctrl <= 4'b1001;		   //DA
				default: ctrl <= 4'b1000;
			endcase
		end
assign  pwmout = ctrl;		             //״̬���������Ӧ��led


endmodule

