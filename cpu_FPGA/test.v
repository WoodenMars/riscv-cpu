`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/24 20:39:16
// Design Name: 
// Module Name: test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test(
	output [31:0]   waddr,
	output [31:0]  wdata
 );
reg clk;
reg rst_n;


initial begin
    clk = 0;
    rst_n = 0;
    #100;
    rst_n = 1'b1;
end
always #20 clk = ~clk;

RISCVtop RISCVtop0(
    .clk(clk),
    .rst_n(rst_n),
	.ADDR(waddr),
	.DATA(wdata)
);

endmodule
