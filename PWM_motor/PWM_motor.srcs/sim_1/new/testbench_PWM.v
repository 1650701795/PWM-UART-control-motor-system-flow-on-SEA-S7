`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/31 11:51:09
// Design Name: 
// Module Name: testbench_PWM
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


module testbench_PWM( );
    reg sys_clk=0;
    reg sys_rst_n=0;    
    reg dir=0;					
    reg sw=0;
    reg uart_rxd;
   					
    wire [3:0] pwmout;
    wire uart_txd;
    
    PWM_motor test(
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .dir(dir),
        .sw(sw),
        .pwmout(pwmout)
    );
    
    
    u_uart_recv(	//串口接收模块                 
    .sys_clk        (sys_clk), 
    .sys_rst_n      (sys_rst_n),
    
    .uart_rxd       (uart_rxd),
    .uart_done      (uart_en_w),
    .uart_data      (uart_data_w)
    );
    
    u_uart_send(     //串口发送模块            
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
     
    .uart_en        (uart_en_w),
    .uart_din       (uart_data_w),
    .uart_txd       (uart_txd)
    );
    
 
       always
        begin
            #10 sys_clk = ~sys_clk;
        end
            
endmodule
