`timescale 1ns/1ps
module Debounce 
#(
    parameter CNT_VAL = 500_000 // clk ticks to ensure signal is steady.
    // NOTE: Most switches reach a stable logic level within 10ms of the actuation.
)(
    input clk,
    input  wire btn,
    input  wire rst,
    output reg  stbl
);
localparam CNT_SZ  = $clog2(CNT_VAL);
reg [CNT_SZ:0] cnt;
reg  ff_stg1, ff_stg2;
wire cnt_clr, cnt_full;

assign cnt_clr  = ff_stg1 ^ ff_stg2;
assign cnt_full = cnt[CNT_SZ];

always @(posedge clk, posedge rst) begin
    if (rst) begin
        ff_stg1   <= 1'b0;
        ff_stg2   <= 1'b0;
        stbl      <= 1'b0;
    end
    else begin
        ff_stg1 <= btn;
        ff_stg2 <= ff_stg1;
        if (cnt_full) stbl <= ff_stg2;
    end
end

always @(posedge clk, posedge rst) begin
    if (rst || cnt_clr)  cnt   <= '{1'b0};
    else if (cnt_full)   cnt   <= cnt;
    else                 cnt   <= cnt + 1'b1;
end

endmodule