`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/21 02:06:47
// Design Name: 
// Module Name: pc_reg
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


module pc_reg(
    input              clk,
    input              rst_n,
    (*DONT_TOUCH= "1"*)
	input [31:0]       imm,//**
    input [6:0]        aluop_i,	//**
	input              beq_i, //beq指令跳转标志
	(*DONT_TOUCH= "1"*)
	input [31:0]       imm_bi,//beg指令立即
     (*DONT_TOUCH= "1"*)
    output reg [31:0]  pc,
    output reg         ce
    );

always @ (posedge clk or negedge rst_n) begin
    if(~rst_n)
        ce <= 1'b0;
    else
        ce <= 1'b1;      
end

always @ (posedge clk) begin
    if(~ce)
        pc <= 32'b0;
    else begin
	     case(aluop_i)
		    7'b0010011,7'b0110011,7'b0110111,7'b0000011,7'b0100011:pc <= pc + 4'h4;
			7'b1100011:begin
			    case(beq_i)
				    1'b0:pc <= pc + 4'h4;
					1'b1:pc <= pc + imm_bi*2;
				endcase
			end	
			7'b1101111:pc <= pc + imm*2;
		 endcase
	end
end
endmodule
