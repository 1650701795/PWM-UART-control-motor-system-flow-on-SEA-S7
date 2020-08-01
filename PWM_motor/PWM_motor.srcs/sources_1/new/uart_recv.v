`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/31 14:00:45
// Design Name: 
// Module Name: uart_recv
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
module uart_recv(
    input			  sys_clk,                  //ϵͳʱ��
    input             sys_rst_n,                //ϵͳ��λ���͵�ƽ��Ч
    
    input             uart_rxd,                 //UART���ն˿�
    output  reg       uart_done,                //����һ֡������ɱ�־�ź�
    output  reg [7:0] uart_data                 //���յ�����
    );
    
//parameter define
parameter  CLK_FREQ = 50000000;                 //ϵͳʱ��Ƶ�� 50M
parameter  UART_BPS = 9600;                     //���ڲ�����
localparam BPS_CNT  = CLK_FREQ/UART_BPS;        //Ϊ�õ�ָ�������ʣ�
                                                //��Ҫ��ϵͳʱ�Ӽ���BPS_CNT��
//reg define
reg        uart_rxd_d0;
reg        uart_rxd_d1;
reg [15:0] clk_cnt;                             //ϵͳʱ�Ӽ�����	16λ
reg [ 3:0] rx_cnt;                              //�������ݼ�����	4λ
reg        rx_flag;                             //���չ��̱�־�ź�
reg [ 7:0] rxdata;                              //�������ݼĴ���	8λ

//wire define
wire       start_flag;

//*****************************************************
//**                    main code
//*****************************************************

//*************************************************************************************************
//������ն˿��½���(��ʼλ)���õ�һ��ʱ�����ڵ������ź�						
//����ı�Ե��ⲿ��(ֻҪuart_rxd�����½���,start_flag�ͻ����һ�������ź�)		
//Ȼ������֪��,ֻҪ�ڿ����м�⵽uart_rxdһ���½���,��ʾ���ݿ�ʼ����, ��start_flag���ǿ�ʼ����ı�־λ

assign  start_flag = uart_rxd_d1 & (~uart_rxd_d0);    

//��UART���ն˿ڵ������ӳ�����ʱ������
always @(posedge sys_clk or negedge sys_rst_n) begin 
    if (!sys_rst_n) begin 
        uart_rxd_d0 <= 1'b0;
        uart_rxd_d1 <= 1'b0;          
    end
    else begin //���ն˿ڸ�ֵ,���� 
        uart_rxd_d0  <= uart_rxd;                  
        uart_rxd_d1  <= uart_rxd_d0;
    end   
end
//************************************************************************************************


//*****************************************************************************************************
//����ĳ���ȷ�����ݿ�ʼ����,����start_flag����һ�������ź�,����rx_flag���ձ�־��Ϊ��,			��ʼ����
//Ȼ��rx_cnt���ռ�����ʼ����,��Ϊÿ�δ���8λ,�ڼ���һ����ʼλ,�����ܹ���9λ����һ��,
//	start_bit/	bit0/	bit1/	bit2/	bit3/	bit4/	bit5/	bit6/	bit7/

//����clk_cnt���Ƕ�ϵͳ���ڼ���,��һ�������ʾͽ�����һ������,
//����ÿһ������������,rx_cnt��һ, �����1bit����
always @(posedge sys_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n)                                  
        rx_flag <= 1'b0;
    else begin
        if(start_flag)                          //��⵽��ʼλ
            rx_flag <= 1'b1;                    //������չ��̣���־λrx_flag����
        else if((rx_cnt == 4'd9)&&(clk_cnt == BPS_CNT/2))	
//		rx_cnt=9��ʾ1B�������,clk_cnt == BPS_CNT/2��ʾstop_bit��������ؾ�Ҫֹͣ,
//		����rx_flag������,�ȵ���һ�����ݿ�ʼ�����ʱ��,rx_flag������ʣ�µİ�����غ��������,����������ص��½�λ,
//		�Ӷ��������clk_cnt��rx_cnt�Ļ���
            rx_flag <= 1'b0;                    //������ֹͣλ�м�ʱ��ֹͣ���չ���
        else
            rx_flag <= rx_flag;
    end
end

//������չ��̺�����ϵͳʱ�Ӽ�������������ݼ�����
always @(posedge sys_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n) begin                             
        clk_cnt <= 16'd0;                                  
        rx_cnt  <= 4'd0;
    end                                                      
    else if ( rx_flag ) begin                   //���ڽ��չ���
            if (clk_cnt < BPS_CNT - 1) begin
                clk_cnt <= clk_cnt + 1'b1;
                rx_cnt  <= rx_cnt;
            end
            else begin
                clk_cnt <= 16'd0;               //��ϵͳʱ�Ӽ�����һ�����������ں�����
                rx_cnt  <= rx_cnt + 1'b1;       //��ʱ�������ݼ�������1
            end
        end
        else begin                              //���չ��̽���������������
            clk_cnt <= 16'd0;
            rx_cnt  <= 4'd0;
        end
end
//*****************************************************************************************************
//���ݽ������ݼ��������Ĵ�uart���ն˿�����
always @(posedge sys_clk or negedge sys_rst_n) begin 
    if ( !sys_rst_n)  
        rxdata <= 8'd0;                                     
    else if(rx_flag)                            //ϵͳ���ڽ��չ���
        if (clk_cnt == BPS_CNT/2) begin         //�ж�ϵͳʱ�Ӽ���������������λ�м�
            case ( rx_cnt )
             4'd1 : rxdata[0] <= uart_rxd_d1;   //�Ĵ�����λ���λ
             4'd2 : rxdata[1] <= uart_rxd_d1;
             4'd3 : rxdata[2] <= uart_rxd_d1;
             4'd4 : rxdata[3] <= uart_rxd_d1;
             4'd5 : rxdata[4] <= uart_rxd_d1;
             4'd6 : rxdata[5] <= uart_rxd_d1;
             4'd7 : rxdata[6] <= uart_rxd_d1;
             4'd8 : rxdata[7] <= uart_rxd_d1;   //�Ĵ�����λ���λ
             default:;                                    
            endcase
        end
        else 
            rxdata <= rxdata;
    else
        rxdata <= 8'd0;
end

//���ݽ�����Ϻ������־�źŲ��Ĵ�������յ�������
always @(posedge sys_clk or negedge sys_rst_n) begin        
    if (!sys_rst_n) begin
        uart_data <= 8'd0;                               
        uart_done <= 1'b0;
    end
    else if(rx_cnt == 4'd9) begin               //�������ݼ�����������ֹͣλʱ           
        uart_data <= rxdata;                    //�Ĵ�������յ�������
        uart_done <= 1'b1;                      //����������ɱ�־λ����
    end
    else begin
        uart_data <= 8'd0;                                   
        uart_done <= 1'b0; 
    end    
end

endmodule	
