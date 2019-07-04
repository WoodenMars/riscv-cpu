`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/23 22:55:58
// Design Name: 
// Module Name: ex
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


module ex(
    input                rst_n,
    input [6:0]          aluop_i,
    input [2:0]          alusel_i,
    input [31:0]         reg1_i,
    input [31:0]         reg2_i,
	input [31:0]         reg_last_i, //**
    input [4:0]          wd_i,
    input                wreg_i,
	input [31:0]         if_pc,//**
    
    output reg [4:0]     wd_o,
    output reg           wreg_o,
    output reg [31:0]    wdata_o,
	
	//Ϊlwָ����ӵ�
	input [31:0]         wdata_reg_i,
	output reg           reg_read_o,  //�������lw�Ƿ���Ը���addr��ȡ���ݣ����Ի�ȡ״̬Ϊ1
	output reg [4:0]     waddr_o, 
	
	output reg           beq_o //beqָ����ת��־λ
	
    );

reg [31:0] result;
reg [31:0] result2;
reg [31:0] result3;
reg [31:0] reg1;
reg [31:0] reg2;
//Ϊlwָ����ӵ�
reg [4:0] addr1;  //������ȡ����Ҫ�ĵ�ַ 
reg [4:0] addr2;
reg [31:0] reg3;
reg [31:0] reg4;

always @ (*) begin         //ͨ������׶η��͹�������Ϣȷ��������������
    if(~rst_n)
    begin
        result <= 0;

    end
    else begin
        case(aluop_i)
            7'b0010011: begin
                case(alusel_i)
                    3'b000: result <= reg1_i + reg2_i;  //ִ����Ӧ������
                    3'b001: result <= reg1_i << reg2_i;
                    3'b100: result <= reg1_i ^ reg2_i;
                    3'b110: result <= reg1_i | reg2_i;
                    3'b111: result <= reg1_i & reg2_i;
                    default: begin
                        result <= 0;
                    end
                endcase
				beq_o <= 1'b0;
            end
            7'b0110011: begin
                case(alusel_i)
                    3'b000: result <= reg1_i + reg2_i;
                    3'b001: result <= reg1_i << reg2_i;
                    3'b100: result <= reg1_i ^ reg2_i;
                    3'b110: result <= reg1_i | reg2_i;
                    3'b111: result <= reg1_i & reg2_i;
					3'b010:begin
						if(reg1_i<reg2_i)
						begin
							result<=32'h00000001;
						end
						else
						begin
							result<=32'h00000000;
						end
					end
					3'b011:begin
						if(reg1_i[31]==1'b1)
							reg1<=~(reg1_i+32'h00000001);
						else
							reg1<=reg1_i;
						if(reg2_i[31]==1'b1)
							reg2<=~(reg2_i+32'h00000001);
						else
							reg2<=reg2_i;
						if(reg1<reg2)
							result<=32'h00000001;
						else
							result<=32'h00000000;
					end
                endcase
				beq_o <= 1'b0;
            end
			7'b0110111: begin
				result <= reg2_i;
				beq_o <= 1'b0;
			end
			7'b0000011:begin
				case(alusel_i)
					3'b010:begin
						reg_read_o <= 1'b1;
						reg3<=reg1_i + reg2_i;
						addr1<=reg3[4:0];      //��ȡ��Ӧ��addr
						waddr_o<=addr1;  //��addr��������˿ڣ���һ�׶�regfile.v
					end
				endcase
				beq_o <= 1'b0;
			end
			7'b0100011:begin
				case(alusel_i)
					3'b010:begin   //sw�㷨
						reg_read_o <= 1'b1;
						reg3<=reg1_i + reg2_i;
						addr2<=reg3[4:0];      //��ȡ��Ӧ��addr
						waddr_o<=wd_i;
					end
				endcase
				beq_o <= 1'b0;
			end
			7'b1100011:begin  //beqָ��
			    if(reg1_i == reg2_i)
				begin
				    beq_o <= 1'b1;
					result3 <= reg_last_i; //**
				end
				else 
				    beq_o <= 1'b0; 
			end
			7'b1101111:begin//jalָ��
			     result3 <= if_pc + 4'h4;
			end
            default: begin
			beq_o <= 1'b0;
            end
        endcase
    end
end

always @ (*) begin
    if((reg_read_o))
	begin
		if(aluop_i==7'b0000011||aluop_i==7'b0100011)
			result2<=wdata_reg_i;  //��addr��������˿ڣ���һ�׶�regfile.v 
	end
end

always @ (*) begin           //�����������͵���һ�׶�	
	wd_o <= wd_i;
	if(aluop_i==7'b0100011)
	begin
		wd_o<=addr2;
	end	
	wreg_o <= wreg_i;
    case(aluop_i)
        7'b0010011: begin
            case(alusel_i)
                3'b000,3'b001,3'b100,3'b110,3'b111: wdata_o <= result;
                default: begin
                end
            endcase
        end
        7'b0110011: begin
            case(alusel_i)
                3'b000,3'b001,3'b100,3'b110,3'b111,3'b010,3'b011: wdata_o <= result;
                default: begin
                end
            endcase
        end
		7'b0110111:begin
			wdata_o <= result;
		end
		7'b0000011:begin 
			case(alusel_i)
				3'b010:begin
					wdata_o <= result2;
				end
			endcase
		end
		7'b0100011:begin
			case(alusel_i)
				3'b010:begin
					wdata_o <= result2;
				end
			endcase
		end
		7'b1100011:begin //beq
		    wdata_o <= result3;
		end
		7'b1101111:begin//jal ָ��
		     wdata_o <= result3;
		end
        default: begin
            wdata_o <= 0;
        end
    endcase
end
endmodule
