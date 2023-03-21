// PS: run for about 25us

`timescale 1ns/1ps
module shrink_tb;

// Parameters
parameter FACTOR = 2;  // Down-sampling factor
parameter BPP = 3;
parameter WIDTH = 30;
parameter HIEGHT = 30;
parameter PEXILS = HIEGHT*WIDTH;
parameter ADDR_WR = (PEXILS/(FACTOR**2));
parameter INFILE  = "image30_hex.txt";
parameter OUTFILE = "output.txt";

// Drive Signals
reg        clk;
reg        rst;
reg        start;
reg  [(8*BPP)-1:0] pexil_in;   // Input image data

wire [(8*BPP)-1:0] pexil_out;  // Output image data
wire       done;
wire [$clog2(ADDR_WR)-1:0] write_adrr; // output to the new data memory for the next pixel address to write
wire [$clog2(PEXILS)-1:0]   read_adrr;  // output to the old data memory for the next pixel address to read

reg [(8*BPP)-1:0] new_data_mem [0:ADDR_WR-1]; // memory to save the new image data
reg [(8*BPP)-1:0] old_data_mem [0:PEXILS-1]; // memory with the old image data

// DUT
shrink #(2,3,30,30) dut (clk, rst, start, pexil_in, pexil_out, done, write_adrr, read_adrr);

// initializing the memory
initial begin
    $readmemh(INFILE, old_data_mem,0,PEXILS-1);
end

// system clock
initial begin
    clk = 1'b0;
    forever #10 clk =~clk;
end

// resetting the system
initial begin
    rst   = 1'b0;
    start = 1'b0;
    #10;
    rst   = 1'b1;
    #10;
    rst   = 1'b0;
    #10;
    start = 1'b1;
    // #1331290;
    #9280;
    start = 1'b0;
end

// inputing the data at the positive edge of the clock
always @(posedge clk) begin
    pexil_in = old_data_mem[read_adrr];       
end

// raeding the output combinationally
always @(*) begin
    if(start) new_data_mem[write_adrr] = pexil_out;
end

integer file;
integer j;

// write memory content to file
initial begin
    repeat(2) @(posedge done);
    file = $fopen(OUTFILE, "w");
    for (j = 0; j < ADDR_WR ; j=j+1) begin
        $fwrite (file, "%h\n", new_data_mem[j]);
        #10;
    end
    $fclose(file);
end

endmodule