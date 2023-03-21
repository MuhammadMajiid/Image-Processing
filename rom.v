//  AUTHOR: Mohamed Maged Elkholy.
//  INFO.: Undergraduate ECE student, Alexandria university, Egypt.
//  AUTHOR'S EMAIL: majiidd17@icloud.com
//  FILE NAME: rom.v
//  TYPE: module.
//  DATE: 21/3/2023
//  KEYWORDS: ROM.
//  PURPOSE: An RTL modelling for the ROM which initialized with the given image hex data.

module rom
//-----------------Parameters-----------------\\
#(
    parameter HIEGHT = 30,
    parameter WIDTH = 30,
    parameter BPP = 3,
    parameter PEXILS = HIEGHT*WIDTH
)
//-----------------Ports-----------------\\
(
    input wire [$clog2(PEXILS)-1:0] rd_addr,

    output reg  [(8*BPP)-1:0]  read_data
);

//-----------------Memory Declaration-----------------\\
reg [(8*BPP)-1:0] data_mem [0:PEXILS-1];

//-----------------Memory Initialization-----------------\\
initial begin
    $readmemh("image30_hex.txt", data_mem);
end

//-----------------Reading combinationally-----------------\\
always @(*) begin
    read_data  = data_mem[rd_addr];
end

endmodule