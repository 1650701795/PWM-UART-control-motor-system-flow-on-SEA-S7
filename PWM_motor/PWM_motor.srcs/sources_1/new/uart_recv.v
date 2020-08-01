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
    input			  sys_clk,                  //系统时钟
    input             sys_rst_n,                //系统复位，低电平有效
    
    input             uart_rxd,                 //UART接收端口
    output  reg       uart_done,                //接收一帧数据完成标志信号
    output  reg [7:0] uart_data                 //接收的数据
    );
    
//parameter define
parameter  CLK_FREQ = 50000000;                 //系统时钟频率 50M
parameter  UART_BPS = 9600;                     //串口波特率
localparam BPS_CNT  = CLK_FREQ/UART_BPS;        //为得到指定波特率，
                                                //需要对系统时钟计数BPS_CNT次
//reg define
reg        uart_rxd_d0;
reg        uart_rxd_d1;
reg [15:0] clk_cnt;                             //系统时钟计数器	16位
reg [ 3:0] rx_cnt;                              //接收数据计数器	4位
reg        rx_flag;                             //接收过程标志信号
reg [ 7:0] rxdata;                              //接收数据寄存器	8位

//wire define
wire       start_flag;

//*****************************************************
//**                    main code
//*****************************************************

//*************************************************************************************************
//捕获接收端口下降沿(起始位)，得到一个时钟周期的脉冲信号						
//经典的边缘检测部分(只要uart_rxd产生下降沿,start_flag就会产生一个脉冲信号)		
//然后我们知道,只要在空闲中检测到uart_rxd一个下降沿,表示数据开始传输, 即start_flag就是开始传输的标志位

assign  start_flag = uart_rxd_d1 & (~uart_rxd_d0);    

//对UART接收端口的数据延迟两个时钟周期
always @(posedge sys_clk or negedge sys_rst_n) begin 
    if (!sys_rst_n) begin 
        uart_rxd_d0 <= 1'b0;
        uart_rxd_d1 <= 1'b0;          
    end
    else begin //接收端口赋值,用于 
        uart_rxd_d0  <= uart_rxd;                  
        uart_rxd_d1  <= uart_rxd_d0;
    end   
end
//************************************************************************************************


//*****************************************************************************************************
//上面的程序确定数据开始传输,并且start_flag产生一个脉冲信号,导致rx_flag接收标志变为高,			开始计数
//然后rx_cnt接收计数开始计数,因为每次传输8位,在加上一个开始位,所以总共是9位传输一次,
//	start_bit/	bit0/	bit1/	bit2/	bit3/	bit4/	bit5/	bit6/	bit7/

//这里clk_cnt就是对系统周期计数,到一个波特率就进行下一个接收,
//就是每一个波特率周期,rx_cnt加一, 完成了1bit接收
always @(posedge sys_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n)                                  
        rx_flag <= 1'b0;
    else begin
        if(start_flag)                          //检测到起始位
            rx_flag <= 1'b1;                    //进入接收过程，标志位rx_flag拉高
        else if((rx_cnt == 4'd9)&&(clk_cnt == BPS_CNT/2))	
//		rx_cnt=9表示1B接收完毕,clk_cnt == BPS_CNT/2表示stop_bit到半个比特就要停止,
//		这样rx_flag会拉低,等到下一个数据开始传入的时候,rx_flag就能在剩下的半个比特后进行拉高,产生半个比特的下降位,
//		从而给了清空clk_cnt和rx_cnt的机会
            rx_flag <= 1'b0;                    //计数到停止位中间时，停止接收过程
        else
            rx_flag <= rx_flag;
    end
end

//进入接收过程后，启动系统时钟计数器与接收数据计数器
always @(posedge sys_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n) begin                             
        clk_cnt <= 16'd0;                                  
        rx_cnt  <= 4'd0;
    end                                                      
    else if ( rx_flag ) begin                   //处于接收过程
            if (clk_cnt < BPS_CNT - 1) begin
                clk_cnt <= clk_cnt + 1'b1;
                rx_cnt  <= rx_cnt;
            end
            else begin
                clk_cnt <= 16'd0;               //对系统时钟计数达一个波特率周期后清零
                rx_cnt  <= rx_cnt + 1'b1;       //此时接收数据计数器加1
            end
        end
        else begin                              //接收过程结束，计数器清零
            clk_cnt <= 16'd0;
            rx_cnt  <= 4'd0;
        end
end
//*****************************************************************************************************
//根据接收数据计数器来寄存uart接收端口数据
always @(posedge sys_clk or negedge sys_rst_n) begin 
    if ( !sys_rst_n)  
        rxdata <= 8'd0;                                     
    else if(rx_flag)                            //系统处于接收过程
        if (clk_cnt == BPS_CNT/2) begin         //判断系统时钟计数器计数到数据位中间
            case ( rx_cnt )
             4'd1 : rxdata[0] <= uart_rxd_d1;   //寄存数据位最低位
             4'd2 : rxdata[1] <= uart_rxd_d1;
             4'd3 : rxdata[2] <= uart_rxd_d1;
             4'd4 : rxdata[3] <= uart_rxd_d1;
             4'd5 : rxdata[4] <= uart_rxd_d1;
             4'd6 : rxdata[5] <= uart_rxd_d1;
             4'd7 : rxdata[6] <= uart_rxd_d1;
             4'd8 : rxdata[7] <= uart_rxd_d1;   //寄存数据位最高位
             default:;                                    
            endcase
        end
        else 
            rxdata <= rxdata;
    else
        rxdata <= 8'd0;
end

//数据接收完毕后给出标志信号并寄存输出接收到的数据
always @(posedge sys_clk or negedge sys_rst_n) begin        
    if (!sys_rst_n) begin
        uart_data <= 8'd0;                               
        uart_done <= 1'b0;
    end
    else if(rx_cnt == 4'd9) begin               //接收数据计数器计数到停止位时           
        uart_data <= rxdata;                    //寄存输出接收到的数据
        uart_done <= 1'b1;                      //并将接收完成标志位拉高
    end
    else begin
        uart_data <= 8'd0;                                   
        uart_done <= 1'b0; 
    end    
end

endmodule	
