//  AUTHOR: Mohamed Maged Elkholy.
//  INFO.: Undergraduate ECE student, Alexandria university, Egypt.
//  AUTHOR'S EMAIL: majiidd17@icloud.com
//  FILE NAME: top.v
//  TYPE: module.
//  DATE: 21/3/2023
//  KEYWORDS: Image Processing.
//  PURPOSE: The top module of the whole system, contains the Shrink/Effects units, FIFO/ROM units, and The UART-Tx unit.

//-----------------Compiler Directives-----------------\\
`timescale 1ns/1ps
module top
//-----------------Parameters-----------------\\
#(
    parameter integer FACTOR = 2,  // Down-sampling factor
    parameter integer VALUE  = 60,
    parameter integer BPP = 3,
    parameter integer HIEGHT = 30,
    parameter integer WIDTH = 30,
    parameter integer PEXILS = HIEGHT*WIDTH,
    // parameter integer ADDR_WR = (PEXILS/(FACTOR**2)),
    parameter integer TICK_PER_HALF = 217,    // Fsys/(2*baudrate)
    parameter integer SZ = (8*BPP)
)
//-----------------Ports-----------------\\
(
    input clk,                  // System Clock.
    input wire rst,             // Active high synchronous reset, Push button.
    input wire start,           // Push button.
    input wire shr_or_eff,      // High for shrink operation, Low for effect operation, switch.
    input wire [1:0] effect,    // Effect selector, switch.

    output wire tx,        // Serial output.
    output wire tx_active, // Transmittiong is Active, LED.
    output wire done,      // Transmittiong is Done, LED.
    output wire op_done    // Operation is Done, LED.
);
//-----------------interconnects-----------------\\
wire [SZ-1:0] pixel_mid, pixel_mid_out, ram_out, rom_out, eff_out, shrink_out;
wire [$clog2(PEXILS)-1:0] rd_adrr_w, rd_adrr_eff, rd_adrr_sh;
wire [$clog2(PEXILS)-1:0] wr_adrr_w, wr_adrr_eff, wr_adrr_sh;
wire ram_done, b_clk, effect_done, shrink_done, done_tx, start_shrink_w, start_effects_w, ram_done_wr, ram_done_rd;

//-----------------Effect Selection-----------------\\
assign start_shrink_w  = (shr_or_eff  && start);
assign start_effects_w = (!shr_or_eff && start);
assign rd_adrr_w       = shr_or_eff? rd_adrr_sh  : rd_adrr_eff;
assign wr_adrr_w       = shr_or_eff? wr_adrr_sh  : wr_adrr_eff;
assign pixel_mid       = shr_or_eff? shrink_out  : eff_out;
assign apply_done      = shr_or_eff? shrink_done : effect_done;

//-----------------ROM-----------------\\
rom #(.HIEGHT(HIEGHT), .WIDTH(WIDTH), .BPP(BPP)) ROM (
    .rd_addr(rd_adrr_w),

    .read_data(rom_out)
);

//-----------------Processing Unit-----------------\\
shrink #(.FACTOR(FACTOR), .BPP(BPP), .HIEGHT(HIEGHT), .WIDTH(WIDTH)) dwnsamp(
    .clk(clk),
    .rst(rst),
    .start(start_shrink_w),
    .pixel_in(rom_out),

    .rd_adrr(rd_adrr_sh),
    .wr_adrr(wr_adrr_sh),
    .pixel_out(shrink_out),
    .done(shrink_done)
);

//-----------------Effects module-----------------\\
effects #(.VALUE(VALUE)) effect(
    .clk(clk),
    .rst(rst),
    .start(start_effects_w),
    .eff(effect),
    .pixel_in(rom_out),

    .rd_adrr(rd_adrr_eff),
    .wr_adrr(wr_adrr_eff),
    .pixel_out(eff_out),
    .done(effect_done)
);

//-----------------Baud Clock Generator-----------------\\
BaudGenT #(.TICK_PER_HALF(TICK_PER_HALF)) baudgen(
    .clock(clk),
    .rst(rst),

    .baud_clk(b_clk)
);

//-----------------FIFO-----------------\\
fifo #(.HIEGHT(HIEGHT), .WIDTH(WIDTH), .BPP(BPP)) fi_fo (
    .wr_clk(clk),
    .rd_clk(b_clk),
    .rst(rst),
    .rd_en(done_tx),
    .sh_en(shr_or_eff),
    .wr_en(!apply_done),
    .wr_addr(wr_adrr_w),
    .write_data(pixel_mid),

    .read_data(ram_out),
    .rd_done(ram_done_rd),
    .wr_done(ram_done_wr)
);

assign ram_done = (ram_done_rd)? 1'b0 : ram_done_wr;

//-----------------UART-Tx-----------------\\
Tx tx(
    .baud_clk(b_clk),
    .rst(rst),
    .send(ram_done),
    .data_in(ram_out),

    .data_tx(tx),
    .active_flag(tx_active),
    .done_flag(done_tx)
);
    
//-----------------Flags-----------------\\
assign done = (!ram_done && done_tx && apply_done);
assign op_done = apply_done;

endmodule