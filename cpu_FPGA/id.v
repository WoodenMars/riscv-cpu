`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/23 19:49:07
// Design Name: 
// Module Name: id
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


module id(
        input             rst_n,
        (*DONT_TOUCH= "1"*)
        input [31:0]      pc_i,
        input [31:0]      inst_i,
        //��ȡregister 
        input [31:0]      reg1_data_i,
        input [31:0]      reg2_data_i,
        //�����regfile
        output reg        reg1_read_o,
        output reg        reg2_read_o,
        output reg [4:0]  reg1_addr_o,
        output reg [4:0]  reg2_addr_o,
        //�ͳ���ִ��ģ��
        output reg [6:0]  aluop_o,
        output reg [2:0]  alusel_o,
        output reg [31:0] reg1_o,
        output reg [31:0] reg2_o,
		output reg [31:0] reg_last_o,//**
        output reg [4:0]  wd_o,
        output reg        wreg_o,
        
//�����ˮ�߳�ͻ
        input             ex_wreg_i,
        input [31:0]      ex_wdata_i,
        input [4:0]       ex_wd_i,

        input             mem_wreg_i,
        input [31:0]      mem_wdata_i,
        input [4:0]       mem_wd_i
    );

wire [6:0] op  = inst_i[6:0];            //��������
wire [2:0] op1 = inst_i[14:12];          //�������㷽ʽ

reg [31:0] imm;
reg [31:0] imm1;

always @ (*) begin
    if(~rst_n) begin
        aluop_o <= 0;
        alusel_o <= 0;
        wd_o <= 0;
        wreg_o <= 0;
        reg1_read_o <= 0;
        reg2_read_o <= 0;
        reg1_addr_o <= 0;
        reg2_addr_o <= 0;
        imm <= 0;	
		imm1 <= 0;
    end
    else begin
        aluop_o <= 0;
        alusel_o <= 0;
		wd_o <= inst_i[11:7];
		if(op==7'b0100011)
		begin
			if(op1==3'b010)
				wd_o <= inst_i[24:20];                     //Ŀ�ļĴ�����ַ
		end       
        wreg_o <= 1'b1;                           //Ŀ�ļĴ���ʹ��
        reg1_read_o <= 0;
        reg2_read_o <= 0;
        reg1_addr_o <= inst_i[19:15];
        reg2_addr_o <= inst_i[24:20];
        imm <= 0;
        
        case(op)
            7'b0010011: begin                               //������I����
                case (op1)
                    3'b000,3'b100,3'b110,3'b111: begin      //addi,xori,ori,andi
                        wreg_o <= 1'b1;                     //�Ƿ�дĿ�ļĴ���
                        aluop_o <= op;                      //��������
                        alusel_o <= op1;                    //���㷽ʽ
                        reg1_read_o <= 1'b1;                //�Ƿ��������1
                        reg2_read_o <= 1'b0;                //�Ƿ��������2
                        imm <= {{20{inst_i[31]}} , inst_i[31:20]};  //��������չ
                    end
                    3'b001: begin                           //slli
                        wreg_o <= 1'b1;                     //�Ƿ�дĿ�ļĴ���
                        aluop_o <= op;                      //��������
                        alusel_o <= op1;                    //���㷽ʽ
                        reg1_read_o <= 1'b1;                //�Ƿ��������1
                        reg2_read_o <= 1'b0;                //�Ƿ��������2
                        imm <= inst_i[24:20];               //��λ��
                    end
                    default: begin
                    end
                endcase
            end
            
            7'b0110011: begin                               //����R����
                case(op1)
                    3'b000,3'b001,3'b100,3'b110,3'b111,3'b010,3'b011: begin //add,sll,xor,or,and,slt,sltu
                        wreg_o <= 1'b1;
                        aluop_o <= op;
                        alusel_o <= op1;
                        reg1_read_o <= 1'b1;
                        reg2_read_o <= 1'b1;  					
                    end
                    default: begin
                    end
                endcase                
            end
			
			7'b0110111: begin                               //U���� lui
                wreg_o <= 1'b1;                     //�Ƿ�дĿ�ļĴ���
                aluop_o <= op;                      //��������
                alusel_o <= 3'b000;                  //���㷽ʽ
                reg1_read_o <= 1'b0;                //�Ƿ��������1
                reg2_read_o <= 1'b0;                //�Ƿ��������2
                imm <= {inst_i[31:12] , 12'b000000000000};  //��������λ
            end
			
			7'b0000011: begin                               //I����
                case (op1)
                    3'b010: begin      						//lw
                        wreg_o <= 1'b1;                     //�Ƿ�дĿ�ļĴ���
                        aluop_o <= op;                      //��������
                        alusel_o <= op1;                    //���㷽ʽ
                        reg1_read_o <= 1'b1;                //�Ƿ��������1
                        reg2_read_o <= 1'b0;                //�Ƿ��������2
                        imm <= {{20{inst_i[31]}} , inst_i[31:20]};  //��������չ
                    end
					default: begin
                    end
                endcase
            end
			
			7'b0100011: begin                               //S����
                case (op1)
                    3'b010: begin      						//sw
                        wreg_o <= 1'b1;                     //�Ƿ�дĿ�ļĴ���
                        aluop_o <= op;                      //��������
                        alusel_o <= op1;                    //���㷽ʽ
                        reg1_read_o <= 1'b1;                //�Ƿ��������1
                        reg2_read_o <= 1'b0;                //�Ƿ��������2
                        imm <= {{20{inst_i[31]}} , inst_i[31:25], inst_i[11:7]};  //��������չ
                    end
                    default: begin
                    end
                endcase
            end
			
			7'b1100011: begin                               //B����
                case (op1)
                    3'b000: begin      						//beq
                        wreg_o <= 1'b0;                     //�Ƿ�дĿ�ļĴ���
                        aluop_o <= op;                      //��������
                        alusel_o <= op1;                    //���㷽ʽ
                        reg1_read_o <= 1'b1;                //�Ƿ��������1
                        reg2_read_o <= 1'b1;                //�Ƿ��������2
                        imm <= {{20{inst_i[31]}} , inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8]};  //��������չ
						imm1 <= {{20{inst_i[31]}} , inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8]};
						reg_last_o <= imm1;
					end
                    default: begin
                    end
                endcase
            end
            
			7'b1101111: begin                               //J����
                wreg_o <= 1'b1;                     //�Ƿ�дĿ�ļĴ���
                aluop_o <= op;                      //��������
                alusel_o <= 3'b000;                  //���㷽ʽ
                reg1_read_o <= 1'b0;                //�Ƿ��������1
                reg2_read_o <= 1'b0;                //�Ƿ��������2
                imm <= {{12{inst_i[31]}} , inst_i[31],inst_i[19:12],inst_i[20],inst_i[30:21]};  //��������չ
            end
			
			default: begin
            end
        endcase
    end
end

always @ (*) begin
    if(~rst_n)
        reg1_o <= 0;
    else if((reg1_read_o) && (ex_wreg_i) && (ex_wd_i == reg1_addr_o))     //���ִ�н׶ε�����Ϊ����׶���Ҫ
                                                                          //��ȡ��������ֱ�ӽ����ͻ�����׶�
        reg1_o <= ex_wdata_i;
    else if((reg1_read_o) && (mem_wreg_i) && (mem_wd_i == reg1_addr_o))   //����ô�׶ε�����Ϊ����׶���Ҫ
                                                                          //��ȡ��������ֱ�ӽ����ͻ�����׶�
        reg1_o <= mem_wdata_i;    
    else if(reg1_read_o)
    begin
        reg1_o <= reg1_data_i;
    end
    else if(~reg1_read_o)
        reg1_o <= imm;    
    else
        reg1_o <= 0;
end

always @ (*) begin
    if(~rst_n)
        reg2_o <= 0;
        
    else if((reg2_read_o) && (ex_wreg_i) && (ex_wd_i == reg2_addr_o))
        reg2_o <= ex_wdata_i;
    else if((reg2_read_o) && (mem_wreg_i) && (mem_wd_i == reg2_addr_o))
        reg2_o <= mem_wdata_i;
        
    else if(reg2_read_o)
    begin
        reg2_o <= reg2_data_i;
    end
    else if(~reg2_read_o)
        reg2_o <= imm;
    else
        reg2_o <= 0;    
end

endmodule