`timescale 1ns/1ps
module TxTest;

parameter BPP = 3;
parameter SZ = (8*BPP);

//  Regs to drive the inputs
reg       rst;
reg       send;
reg       baud_clk;
reg [SZ-1:0] data_in; 

//  wires to show the output
wire      data_tx;
wire      active_flag;
wire      done_flag; 

//  Instance for the design module
Tx #(.BPP(BPP), .SZ(SZ)) ForTest(
    //  Inputs
    .rst(rst),
    .send(send), 
    .clock(clock),
    .data_in(data_in),

    //  Outputs
    .data_tx(data_tx),
    .active_flag(active_flag),
    .done_flag(done_flag)
);

//  dump
initial
begin
    $dumpfile("TxTest.vcd");
    $dumpvars;
end

//  Monitoring the outputs and the inputs
initial begin
    $monitor($time, "   The Outputs:  Data Tx = %b  Done Flag = %b  Active Flag = %b The Inputs:  Data In = %b  Send = %b",
    data_tx, done_flag, active_flag, reset_n, 
    data_in[SZ-1:0], send);
end

//  50Mhz clock
initial
begin
    baud_clk = 1'b0;
    forever
    begin
      #10 baud_clk = ~baud_clk; 
    end 
end

//  Reseting the system
initial
begin
    rst = 1'b1;
    send    = 1'b0;
    #100;
    rst = 1'b0;
    send    = 1'b1;
end

//  Varying the Baud Rate and the Parity Type
initial
begin
    //  Testing data
    data_in = 8'b10101010 ;
    //  test for baud rate 19200 and even parity
    #677083.329;   //  waits for the whole frame to be sent
end

//  Stop
initial begin
    #1500000 $stop;
    // Simulation for 3 ms
end

endmodule