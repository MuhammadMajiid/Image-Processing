// PS: run for about 28us

`timescale 1ns/1ps
module eff_tb;

// Parameters
parameter VALUE = 50;
parameter INFILE  = "image30_hex.txt";
parameter OUTFILE = "eff_out.txt";

// Drive Signals
reg        clk;
reg        rst;
reg        start;
reg  [2:0] eff; 
reg  [23:0] pexil_in;   // Input image data

wire [23:0] pexil_out;  // Output image data
wire       done;
wire [$clog2(900)-1:0] write_adrr; // output to the new data memory for the next pixel address to write
wire [$clog2(900)-1:0] read_adrr;  // output to the old data memory for the next pixel address to read

reg [23:0] new_data_mem [0:899]; // memory to save the new image data
reg [23:0] old_data_mem [0:899]; // memory with the old image data

// DUT
effects #(.VALUE(VALUE)) dut (clk, rst, start, eff, pexil_in, pexil_out, done, write_adrr, read_adrr);

// initializing the memory
initial begin
    $readmemh(INFILE, old_data_mem);
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
    #18010;
    start = 1'b0;
end

// effect
initial begin
    eff = 3'h2;
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
always @(posedge clk) begin
    if (done && (write_adrr == 899)) begin
        file = $fopen(OUTFILE, "w");
        for (j = 0; j < 900 ; j=j+1) begin
            $fwrite (file, "%h\n", new_data_mem[j]);
            #10;
        end
        $fclose(file);
    end
end

endmodule