// NOTE for this test you will need to run it for 36 micro seconds
// in order to the process to get completed successfully.

`timescale 1ns/1ps
module mem_tb;

parameter HIEGHT = 30;
parameter WIDTH = 30;
parameter BPP = 3;
parameter PEXILS = HIEGHT*WIDTH;
parameter INFILE = "img_30x30_output.txt";

reg        clk;
reg        rst;
reg        read_en;
reg        write_en;
reg [$clog2(PEXILS)-1:0] rd_addr;
reg [$clog2(PEXILS)-1:0] wr_addr;
reg  [(8*BPP)-1:0] write_data;

wire [(8*BPP)-1:0] read_data;
wire done;

mem #(30,30,3) dut(clk, rst, read_en, write_en, rd_addr, wr_addr, write_data, read_data, done);

reg [(8*BPP)-1:0] data_mem_tb [0:PEXILS-1];

// Memory Initialization with the given file.
initial begin
    $readmemh(INFILE, data_mem_tb,0,899);
end

initial begin
    clk = 1'b0;
    forever #10 clk =~clk;
end

initial begin
    rst      = 1'b0;
    #10;
    rst   = 1'b1;
    #10
    rst   = 1'b0;
end

integer file;
integer j;
integer i;
initial begin

    read_en  = 1'b0;
    write_en = 1'b0;
    #10;
    write_en = 1'b1;
    for ( i=0 ; i<PEXILS+1 ; i=i+1) begin
        @(posedge clk);
        if(write_en)begin
        wr_addr = i;
        write_data = data_mem_tb[wr_addr];
        end
    end
    write_en = 1'b0;
    wr_addr = 0;
    #20;
    if(done) begin
        @(posedge clk);
        read_en  = 1'b1;
        file = $fopen("test.txt", "w");
        for (j = 0; j < PEXILS ; j=j+1) begin
            rd_addr = j;
            #10;
            $fwrite (file, "%h\n", read_data);
            #10;
        end
        $fclose(file);
    end
    read_en = 1'b0;
end
endmodule