//  AUTHOR: Mohamed Maged Elkholy.
//  INFO.: Undergraduate ECE student, Alexandria university, Egypt.
//  AUTHOR'S EMAIL: majiidd17@icloud.com
//  FILE NAME: BaudGenT.v
//  TYPE: module.
//  DATE: 21/3/2023
//  KEYWORDS: Baud Rate Generator, UART, Tx, Serial Communication.
//  PURPOSE: An RTL modelling for the clock feeding the UART-Tx, at which sends the processed image back serially to the PC.

//-----------------Compiler Directives-----------------\\
`timescale 1ns/1ps
module BaudGenT
//-----------------Parameters-----------------\\
#(
    parameter TICK_PER_HALF = 434  // 217   // BR = 115200    // Fsys/(2*baudrate)
)
//-----------------Ports-----------------\\
(
    input              clock,             //  The System's main clock.
    input wire         rst,               //  Active high reset.

    output reg         baud_clk           //  Clocking output for the other modules.
);
//-----------------interconnects-----------------\\
reg [$clog2(TICK_PER_HALF)-1:0] clock_ticks, final_value;


//-----------------Timer logic-----------------\\
always @(posedge clock)
begin
    if(rst)
    begin
        clock_ticks <= 0; 
        baud_clk    <= 1'b0; 
    end
    else
    begin
        if (clock_ticks == TICK_PER_HALF)
        begin
            clock_ticks <= 0; 
            baud_clk    <= ~baud_clk; 
        end 
        else
        begin
            clock_ticks <= clock_ticks + 1'd1;
            baud_clk    <= baud_clk;
        end
    end 
end

endmodule