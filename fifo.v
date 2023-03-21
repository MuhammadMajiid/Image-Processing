//  AUTHOR: Mohamed Maged Elkholy.
//  INFO.: Undergraduate ECE student, Alexandria university, Egypt.
//  AUTHOR'S EMAIL: majiidd17@icloud.com
//  FILE NAME: fifo.v
//  TYPE: module.
//  DATE: 21/3/2023
//  KEYWORDS: FIFO.
//  PURPOSE: An RTL modelling for FIFO.

//-----------------Compiler Directives-----------------\\
`timescale 1ns/1ps
module fifo
//-----------------Parameters-----------------\\
#(
    parameter FACTOR = 2,
    parameter HIEGHT = 30,
    parameter WIDTH = 30,
    parameter BPP = 3,
    parameter PEXILS = HIEGHT*WIDTH,
    parameter ADDR_WR = (PEXILS/(FACTOR**2))
)
//-----------------Ports-----------------\\
(
    input  wr_clk, rd_clk,
    input  wire        rst,
    input  wire        sh_en,
    input  wire        rd_en,
    input  wire        wr_en,
    input  wire [$clog2(PEXILS)-1:0] wr_addr,
    input  wire [(8*BPP)-1:0]  write_data,

    output reg         wr_done,
    output reg         rd_done,
    output reg  [(8*BPP)-1:0]  read_data
);
//-----------------Memory Declaration-----------------\\
reg [(8*BPP)-1:0] data_mem [0:PEXILS-1];
reg [$clog2(PEXILS)-1:0] rd_addr = 0;
// reg wr_done, rd_done;

//-----------------writing @ posedge of the system clock-----------------\\ 
always @(posedge wr_clk) begin
    if (rst) begin
        wr_done        <= 1'b0;
    end
    else begin
        if (wr_en) data_mem[wr_addr] <= write_data;
        if(sh_en) begin
            if (wr_addr == (ADDR_WR-1)) wr_done     <= 1'b1;
            else                       wr_done     <= 1'b0;
        end
        else begin
            if (wr_addr == (PEXILS-1)) wr_done     <= 1'b1;
            else                       wr_done     <= 1'b0;
        end
        
    end
end

//-----------------Reading @ posedge of the baud clock-----------------\\
always @(posedge rd_clk) begin
    if(rd_en && !wr_en) begin
        if (wr_addr == rd_addr) begin 
            rd_done     <= 1'b1;
            rd_addr     <= rd_addr;
        end
        else begin 
            rd_done     <= 1'b0;
            rd_addr     <= rd_addr + 1;
        end
        read_data       <= data_mem[rd_addr];
    end
    // if(rd_done) done    <= 1'b0;
    // else        done    <= wr_done;
end
endmodule