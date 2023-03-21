//  AUTHOR: Mohamed Maged Elkholy.
//  INFO.: Undergraduate ECE student, Alexandria university, Egypt.
//  AUTHOR'S EMAIL: majiidd17@icloud.com
//  FILE NAME: shrink.v
//  TYPE: module.
//  DATE: 21/3/2023
//  KEYWORDS: Down-Sampling, Image Processing, Re-sizing.
//  PURPOSE: An RTL modelling for the Down-Sampling performed on the given image, by a factor of the power of 2.

//-----------------Compiler Directives-----------------\\
`timescale 1ns/1ps
module shrink
//-----------------Parameters-----------------\\
#(
    parameter FACTOR = 2,  // Down-sampling factor
    parameter BPP = 3,
    parameter HIEGHT = 30,
    parameter WIDTH = 30,
    parameter integer PEXILS = HIEGHT*WIDTH
    // parameter PEXILS = (PEXILS/(FACTOR**2))
)
//-----------------Ports-----------------\\
(
    input                    clk,
    input wire               rst,
    input wire               start,
    input wire [(8*BPP)-1:0] pixel_in,       // Input image data
    
    output reg                       done,
    output reg  [(8*BPP)-1:0]        pixel_out,  // Output image data
    output wire [$clog2(PEXILS)-1:0] wr_adrr, // output to the new data memory for the next pixel address to write
    output wire [$clog2(PEXILS)-1:0] rd_adrr   // output to the old data memory for the next pixel address to read
);
//-----------------Local Parameters-----------------\\
localparam integer LIM = ((WIDTH+FACTOR-1)/FACTOR);
localparam IDLE = 2'b00,
           GET  = 2'b01,
           SKIP = 2'b10,
           JUMP = 2'b11;
//-----------------Interconnects-----------------\\
reg [1:0] crnt_st, nxt_st;
reg [$clog2(PEXILS)-1:0] rd_address, rd_address_r;
reg [$clog2(PEXILS)-1:0] wr_address, wr_address_r;
reg [$clog2(LIM)-1:0] row_count_r, row_count, col_count, col_count_r;

//-----------------Shrink FSM-----------------\\
always @(posedge clk) begin
    if (rst) begin
        crnt_st      <= IDLE;
        rd_address_r <= 0;
        wr_address_r <= 0;
        row_count_r  <= 0;
        col_count_r  <= 0;
    end
    else begin
        crnt_st      <= nxt_st;
        rd_address_r <= rd_address;
        wr_address_r <= wr_address;
        row_count_r  <= row_count;
        col_count_r  <= col_count;
    end
end

always @(*) begin    
    // default values
    nxt_st      = crnt_st;
    rd_address  = rd_address_r;
    wr_address  = wr_address_r;
    nxt_st      = crnt_st;
    row_count   = row_count_r;
    col_count   = col_count_r;
    done        = 1'b0;

    case (crnt_st)
        IDLE: begin
            row_count         = 0;
            col_count         = 0;
            if (start) begin
                nxt_st        = GET;
                rd_address    = 0;
                wr_address    = 0;
                done          = 1'b0;
            end 
            else begin
                nxt_st        = IDLE;
                done          = 1'b1;
            end
        end

        GET: begin
            pixel_out = pixel_in;
            nxt_st    = SKIP;
        end

        SKIP: begin
            if (col_count_r == (LIM-1)) begin
                col_count  = 0;
                nxt_st     = JUMP;
            end
            else begin
                rd_address = rd_address_r + (FACTOR);
                wr_address = wr_address_r + 1'b1;
                col_count  = col_count_r + 1'b1;
                nxt_st     = GET;
            end
        end

        JUMP: begin
            if (row_count_r == (LIM-1)) begin
                row_count  = 0;
                nxt_st     = IDLE;
                done       = 1'b1;
            end
            else begin    
                rd_address     = rd_address_r + (((FACTOR-1)*HIEGHT)+2);
                wr_address     = wr_address_r + 1'b1;
                row_count      = row_count_r + 1'b1;
                nxt_st         = GET;
            end
        end

        default: nxt_st    = IDLE;
    endcase
end

//-----------------Output-----------------\\
assign wr_adrr = wr_address_r;
assign rd_adrr = rd_address_r;

endmodule