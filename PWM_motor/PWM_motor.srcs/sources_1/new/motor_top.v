`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/31 14:05:16
// Design Name: 
// Module Name: motor_top
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


module motor_top(
    input           sys_clk,          //�ⲿ50Mʱ��
    input           sys_rst_n,        //�ⲿ��λ�źţ�����Ч
                                       //uart�ӿ�
    input           uart_rxd,         //UART���ն˿�
    input           dir,					//���ƶ� 1����ת 0����ת
    input           sw,					//����
    output          [3:0] pwmout,			//���������������
    output          uart_txd          //UART���Ͷ˿�
    );


    
//parameter define
parameter  CLK_FREQ = 50000000;       //����ϵͳʱ��Ƶ��
parameter  UART_BPS = 115200;         //���崮�ڲ�����
    
//wire define   
wire       uart_en_w;                 //UART����ʹ��
wire [7:0] uart_data_w;               //UART��������
wire       clk_1m_w;                  //1MHzʱ�ӣ�����Signaltap����

//*****************************************************
//**                    main code
//*****************************************************

  PWM_motor(
  .sys_clk       (sys_clk),
  .sys_rst_n     (sys_rst_n ),
  .dir		     (dir),	//���ƶ� 1����ת 0����ת
  .sw			 (sw),    //����
  .pwmout        (pwmout) //���������������
  );


//���ڽ���ģ�� ����    
uart_recv #(    //parameter���¸�ֵ                      
    .CLK_FREQ       (CLK_FREQ),       //����ϵͳʱ��Ƶ��
    .UART_BPS       (UART_BPS)		  //���ô��ڽ��ղ�����
)       
u_uart_recv(	//���ڽ���ģ��                 
    .sys_clk        (sys_clk), 
    .sys_rst_n      (sys_rst_n),
    
    .uart_rxd       (uart_rxd),
    .uart_done      (uart_en_w),
    .uart_data      (uart_data_w)
    );
//���ڷ���ģ�� ����    
uart_send #(     //parameter���¸�ֵ                     
    .CLK_FREQ       (CLK_FREQ),       //����ϵͳʱ��Ƶ��
    .UART_BPS       (UART_BPS)		  //���ô��ڷ��Ͳ�����
    )       

u_uart_send(     //���ڷ���ģ��            
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
     
    .uart_en        (uart_en_w),
    .uart_din       (uart_data_w),
    .uart_txd       (uart_txd)
    );
    


endmodule 
