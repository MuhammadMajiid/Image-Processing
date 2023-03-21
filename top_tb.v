//-----------------Compiler Directives-----------------\\
`timescale 1ns/1ps
module top_tb;

//-----------------Parameters-----------------\\
parameter FACTOR = 2;  // Down-sampling factor
parameter VALUE = 50;  // Brighten/Darken value
parameter BPP = 3;
parameter HIEGHT = 30;
parameter WIDTH = 30;
parameter integer PEXILS = HIEGHT*WIDTH;
parameter SZ = (8*BPP)-1;
parameter TICK_PER_HALF = 1302;    // Fsys/(2*baudrate)
parameter OUTFILE = "output.txt";
// parameter INFILE  = "input.txt";
// parameter ADDR_WR = (PEXILS/(FACTOR**2));

//-----------------Drivers-----------------\\
reg clk;
reg rst;
reg start;
reg shr_or_eff;
reg [1:0] effect;

wire tx;
wire tx_active;
wire done;
wire op_done;

//-----------------DUT-----------------\\
top #(.FACTOR(FACTOR), .VALUE(VALUE), .BPP(BPP), .HIEGHT(HIEGHT), .WIDTH(WIDTH), .TICK_PER_HALF(TICK_PER_HALF)) dut(
    .clk(clk),
    .rst(rst),
    .effect(effect),
    .start(start),
    .shr_or_eff(shr_or_eff),

    .tx(tx),
    .tx_active(tx_active),
    .done(done),
    .op_done(op_done)
);

//-----------------System Clock-----------------\\
initial begin
    clk = 1'b0;
    forever #5 clk =~clk;
end

//-----------------Reset and Initialize-----------------\\
initial begin
    rst   = 1'b0;
    start = 1'b0;
    #10;
    rst   = 1'b1;
    #10;
    rst   = 1'b0;
    #10;
    start = 1'b1;
    #500;
    start = 1'b0;
end

//-----------------Operation Selection-----------------\\
initial begin
    shr_or_eff = 1;
    effect     = 3'h3;
end

//-----------------Write output into a file-----------------\\
// integer file;
// integer j;
// always @(posedge b_clk) begin
//     if(active_flag)
//     file = $fopen(OUTFILE, "a");
//     $fwrite(file, "%b\n", tx);
//     $fclose(file);
// end

endmodule