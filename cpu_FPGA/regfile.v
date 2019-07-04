`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/21 02:25:05
// Design Name: 
// Module Name: regfile
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


module regfile(
    input              rst_n,
    input              clk,
    
    input [4:0]        waddr,
    input [31:0]       wdata,
    input              we,
    
	input              beq,//**
	output reg [31:0]  imm_data,//**
	
    input [4:0]        raddr1,
    input              re1,
    output reg [31:0]  rdata1,
    
    input [4:0]        raddr2,
    input              re2,
    output reg [31:0]  rdata2,
	
	input [4:0]       addr,
	input    		  re,
	output reg [31:0]     data
    );
 

reg [31:0] mem_r [0:31];

always @ (posedge clk or negedge rst_n) begin      //д��Ĵ���
    if(!rst_n)
        mem_r[waddr] <= 32'b0;
    else
    begin
        if((waddr != 5'b0) && (we) &&(~beq))
            mem_r[waddr] <= wdata;
		else if(beq)
		    mem_r[5'b01111] <= wdata;//**
    end
end

always @ (*) begin                                 //�Ӷ˿�1��������
    if(~rst_n)
        rdata1 <= 32'b0;
    else if(raddr1 == 5'b0)
        rdata1 <= 32'b0;
    else if((raddr1 == waddr) && re1 && we)        //���д��ĵ�ַ��Ҫ�����ĵ�ַ��ͬ
        rdata1 <= wdata;                           //��ֱ�ӽ�д�����ݶ���
    else if(re1)
        rdata1 <= mem_r[raddr1];
    else
        rdata1 <= 32'b0;
end

always @ (*) begin                                 //�Ӷ˿�2��������
    if(~rst_n)
        rdata2 <= 32'b0;
    else if(raddr2 == 5'b0)
        rdata2 <= 32'b0;
    else if((raddr2 == waddr) && re2 && we)
        rdata2 <= wdata;
    else if(re2)
        rdata2 <= mem_r[raddr2];
    else
        rdata2 <= 32'b0;
end

//lw�㷨ר��
always @ (*) begin                                 //�Ӷ˿ڶ�������
    if(~rst_n)
        data <= 32'b0;
    else if(addr == 5'b0)
        data <= 32'b0;
    else if((addr == waddr) && re && we)        //���д��ĵ�ַ��Ҫ�����ĵ�ַ��ͬ
        data <= wdata;                           //��ֱ�ӽ�д�����ݶ���
    else if(re)
        data <= mem_r[addr];
    else
        data <= 32'b0;
end

//B�㷨
always @ (*) begin
    if(~rst_n)
	    imm_data <= 32'b0;
	else if(beq)
	    imm_data <= mem_r[5'b01111];
	else
	    imm_data <= 32'b0;
end

endmodule
