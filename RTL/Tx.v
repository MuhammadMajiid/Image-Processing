//  AUTHOR: Mohamed Maged Elkholy.
//  INFO.: Undergraduate ECE student, Alexandria university, Egypt.
//  AUTHOR'S EMAIL: majiidd17@icloud.com
//  FILE NAME: Tx.v
//  TYPE: module.
//  DATE: 21/3/2023
//  KEYWORDS: Image Processing, UART, Tx, Serial Communication.
//  PURPOSE: An RTL modelling for the UART-Tx, which sends the processed image back serially to the PC.

//-----------------Compiler Directives-----------------\\
`timescale 1ns/1ps
module Tx
(
    input wire           rst,                //  Active high synchronous reset.
    input wire           send,               //  An enable to start sending data.
    input wire           baud_clk,           //  Clocking signal from the BaudGen unit.
    input wire [23:0]    data_in,            //  The data input.
  
    output reg 	         data_tx, 	         //  Serial transmitter's data out, LSB first.
	output reg  	     active_flag,        //  high when Tx is transmitting, low when idle.
	output reg  	     done_flag           //  high when transmission is done, low when active.
);

//-----------------Interconnects-----------------\\
reg [28:0]  frame_r, frame_man;
reg [4:0]   stop_count, stop_count_r;
reg         crnt_st, nxt_st;

//-----------------Encoding the states-----------------\\
localparam IDLE   = 1'b0,
           ACTIVE = 1'b1;

//-----------------Frame Generation-----------------\\
always @(posedge baud_clk) begin
    if (crnt_st == IDLE)  frame_r <= {data_in[23:16],1'b0,1'b1,data_in[15:8],1'b0,1'b1,data_in[7:0],1'b0};
    else                  frame_r <= frame_man;
end

//-----------------Counter Logic-----------------\\
always @(posedge baud_clk) begin
    if (rst) stop_count_r <= 0;
    else     stop_count_r <= stop_count;
end

//-----------------Transmission Logic FSM-----------------\\
always @(posedge baud_clk, posedge rst) begin
    if (rst) crnt_st   <= IDLE;
	else     crnt_st   <= nxt_st;
end

always @(*) begin
    // default values
    nxt_st       = crnt_st;
    frame_man    = frame_r;
    stop_count   = stop_count_r;
    done_flag    = 1'b1;
    active_flag  = 1'b0;
    data_tx      = 1'b1;

    case (crnt_st)

        IDLE: begin
            stop_count         = 0;
            active_flag    = 1'b0;
            done_flag      = 1'b1;
            if (send) begin
                nxt_st         = ACTIVE;
                active_flag    = 1'b1;
                done_flag      = 1'b0;
            end
            else      nxt_st   = IDLE;
        end 

        ACTIVE: begin
            active_flag  = 1'b1;
            done_flag    = 1'b0;
            data_tx      = frame_man[0];
            frame_man    = frame_r >> 1;
            stop_count   = stop_count_r + 1;
            if(stop_count == 29) begin
                nxt_st  = IDLE;
                active_flag    = 1'b0;
                done_flag      = 1'b1;
            end
            else                 nxt_st  = ACTIVE;
        end

        default: nxt_st = IDLE;
    endcase
end

endmodule  