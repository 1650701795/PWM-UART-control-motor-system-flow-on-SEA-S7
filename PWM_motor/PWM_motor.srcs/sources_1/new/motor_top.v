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
    input           sys_clk,          //外部50M时钟
    input           sys_rst_n,        //外部复位信号，低有效
                                       //uart接口
    input           uart_rxd,         //UART接收端口
    input           dir,					//控制端 1：正转 0：反转
    input           sw,					//调速
    output          [3:0] pwmout,			//步进电机四相输入
    output          uart_txd          //UART发送端口
    );


    
//parameter define
parameter  CLK_FREQ = 50000000;       //定义系统时钟频率
parameter  UART_BPS = 115200;         //定义串口波特率
    
//wire define   
wire       uart_en_w;                 //UART发送使能
wire [7:0] uart_data_w;               //UART发送数据
wire       clk_1m_w;                  //1MHz时钟，用于Signaltap调试

//*****************************************************
//**                    main code
//*****************************************************

  PWM_motor(
  .sys_clk       (sys_clk),
  .sys_rst_n     (sys_rst_n ),
  .dir		     (dir),	//控制端 1：正转 0：反转
  .sw			 (sw),    //调速
  .pwmout        (pwmout) //步进电机四相输入
  );


//串口接收模块 例化    
uart_recv #(    //parameter重新赋值                      
    .CLK_FREQ       (CLK_FREQ),       //设置系统时钟频率
    .UART_BPS       (UART_BPS)		  //设置串口接收波特率
)       
u_uart_recv(	//串口接收模块                 
    .sys_clk        (sys_clk), 
    .sys_rst_n      (sys_rst_n),
    
    .uart_rxd       (uart_rxd),
    .uart_done      (uart_en_w),
    .uart_data      (uart_data_w)
    );
//串口发送模块 例化    
uart_send #(     //parameter重新赋值                     
    .CLK_FREQ       (CLK_FREQ),       //设置系统时钟频率
    .UART_BPS       (UART_BPS)		  //设置串口发送波特率
    )       

u_uart_send(     //串口发送模块            
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
     
    .uart_en        (uart_en_w),
    .uart_din       (uart_data_w),
    .uart_txd       (uart_txd)
    );
    


endmodule 
