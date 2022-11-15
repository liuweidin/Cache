`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/21 11:09:04
// Design Name: 
// Module Name: fetch
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
//////////////////////////////////////////////////////////////////////////////////дֱ���cache
`include "defines.v"


module icache(
    input wire clk,
     input wire rst,
     input wire data_req_i, //CPU�������ݣ���λ��Ч
     input  wire[`RegBus] virtual_addr,//�����ַ����ʵ��TLB
     input wire [`RegBus] write_data,
     input wire cpu_we,//��д�źţ�1λд��0λ��
     output wire [19:0] ram_addr,
     //input wire ram_ready,
     input wire [`cache_lineBus]ram_data_i,//sram��ȡ����һ������
     output reg cache_hit_o,//cache���У���λ��Ч
     output reg data_valid_o,//���������Ƿ���Ч����λ��Ч
     output reg[31:0]data1,//�������ݵĶ˿�1
     output reg [31:0] data2,//�������ݵĶ˿�2
     output reg stopreq,
     output reg ce,
     output reg we,
     //��sram�������������ź�
     input wire write_finish,
     input wire read_finish,
     output reg addr_valid,//��ַ�Ƿ���Ч
     //д��һ������
     output wire [`cache_lineBus]write_back_data,
     //�Ƿ������������,��λ��Ч
     output reg is_single,
     //�ֽ�дʹ���ź�
     input wire [3:0]sel,
     //����ͣ��ˮʱ��cache�ڲ���״̬��ҲҪ���ã���λ��Ч
     input wire cache_flush
    );
    wire [31:0]addr;//���������ַ����ת������Ҫʹ�������ַʱʹ���ź���Ƭ����ת��
    assign addr=virtual_addr;
   // wire [6:0]group_addr1;
   // wire [6:0]group_addr2;
    wire [`cache_lineBus]ram_data;
    //״̬������
    reg[2:0] state;
    reg[2:0] next_state;
    //
    reg[31:0] way0_data;
    reg[31:0] way1_data;
    
    //reg[127:0] dirt_reg[1:0];//��λ������ָʾcache�����Ƿ�д��
    reg [127:0] valid_reg[1:0];//cache����Чλ
    reg[127:0] lru_reg;//Ϊ0��ʱway0���û���ù���Ϊ1��ʾway1���û���ù�
    wire [6:0]group_addr;//
    wire [19:0]tag_way0;
    wire [19:0]tag_way1;
    
    reg tagv_way0_ena;//cache�洢��ʹ��
    reg tagv_way1_ena;
    reg tagv_way0_wea;//cache�ڲ�дʹ��
    reg tagv_way1_wea;
    wire [19:0]trgv_way0_out;
    wire [19:0]trgv_way0_in;
    wire [19:0]trgv_way1_out;
    wire [19:0]trgv_way1_in;
    reg hit_way0;
    reg hit_way1;
    
    wire lru_pik=lru_reg[group_addr];
    
    wire [31:0] way0_bank0;
    wire [31:0] way0_bank1;
    wire [31:0] way0_bank2;
    wire [31:0] way0_bank3;
    wire [31:0] way0_bank4;
    wire [31:0] way0_bank5;
    wire [31:0] way0_bank6;
    wire [31:0] way0_bank7;
    wire [31:0] way1_bank0;
    wire [31:0] way1_bank1;
    wire [31:0] way1_bank2;
    wire [31:0] way1_bank3;
    wire [31:0] way1_bank4;
    wire [31:0] way1_bank5;
    wire [31:0] way1_bank6;
    wire [31:0] way1_bank7;
    
    wire [31:0]addr2;
    wire is_same_line;//��ʾ���������Ƿ�����ͬһ��cache��
    reg [`cache_lineBus] write_temp;
    
    //assign ram_addr=(state==`Write_ram)? ((lru_reg[group_addr]==1'b0)? {tag_way0[9:0],group_addr,3'b000}:{tag_way1[9:0],group_addr,3'b000}):addr[21:2];
    assign ram_addr={addr[21:5],3'b000};
    assign group_addr=addr[11:5];//���ַ����
    //���ַ����
    //assign group_addr1=addr[11:5];////////////////////
    //assign addr2=addr+4'h4;//�ڶ������ݵ�ַ
    //assign group_addr2=addr2[11:5];
    
    //assign is_same_line=(group_addr1==group_addr2)?1'b1:1'b0;
    
    assign tag_way0=trgv_way0_out;//ȡ��way0��tag
    assign tag_way1=trgv_way1_out;//ȡ��way1��tag
    assign trgv_way0_in=addr[31:12];
    assign trgv_way1_in=addr[31:12];
    
    //assign write_back_data=(lru_reg[group_addr]==1'b0)? {way0_bank7,way0_bank6,way0_bank5,way0_bank4,way0_bank3,way0_bank2,way0_bank1,way0_bank0}:{way1_bank7,way1_bank6,way1_bank5,way1_bank4,way1_bank3,way1_bank2,way1_bank1,way1_bank0}; 
    assign write_back_data=write_temp;
    assign ram_data=(state==`Write_data &&cpu_we==1'b0)? ram_data_i://��δ����
                    //дδ����
                    (state==`Write_data && cpu_we==1'b1 && sel==4'b0000)? {ram_data_i[255:32],write_data}:
                    (state==`Write_data && cpu_we==1'b1 && sel==4'b1110)? {ram_data_i[255:8],write_data[7:0]}:
                    (state==`Write_data && cpu_we==1'b1 && sel==4'b1101)? {ram_data_i[255:16],write_data[7:0],ram_data_i[7:0]}:
                    (state==`Write_data && cpu_we==1'b1 && sel==4'b1011)? {ram_data_i[255:24],write_data[7:0],ram_data_i[15:0]}:
                    (state==`Write_data && cpu_we==1'b1 && sel==4'b0111)? {ram_data_i[255:32],write_data[7:0],ram_data_i[23:0]}:
                    //д����
                    (state==`Scanf_cache && cpu_we==1'b1 )? write_temp:
                    256'b0;
                    
    always @(*) begin //����д����ʱд�������
        if(rst==`RstEnable) begin 
            write_temp=256'h0;
        end 
        else begin 
            write_temp=256'h0;
            if(state==`Scanf_cache && hit_way0==`hit) begin //way0д����
                case(addr[4:2])
                    3'b000: begin 
                        case(sel)
                            4'b0000: begin 
                                write_temp={way0_bank7,way0_bank6,way0_bank5,way0_bank4,way0_bank3,way0_bank2,way0_bank1,write_data};
                            end
                            4'b1110: begin 
                                write_temp={way0_bank7,way0_bank6,way0_bank5,way0_bank4,way0_bank3,way0_bank2,way0_bank1,way0_bank0[31:8],write_data[7:0]};
                            end
                            4'b1101: begin 
                                write_temp={way0_bank7,way0_bank6,way0_bank5,way0_bank4,way0_bank3,way0_bank2,way0_bank1,way0_bank0[31:16],write_data[7:0],way0_bank0[7:0]};
                            end
                            4'b1011: begin 
                                write_temp={way0_bank7,way0_bank6,way0_bank5,way0_bank4,way0_bank3,way0_bank2,way0_bank1,way0_bank0[31:24],write_data[7:0],way0_bank0[15:0]};
                            end
                            4'b0111: begin 
                                write_temp={way0_bank7,way0_bank6,way0_bank5,way0_bank4,way0_bank3,way0_bank2,way0_bank1,write_data[7:0],way0_bank0[23:0]};
                            end
                        
                        endcase
                    end
                    3'b001: begin 
                        case(sel)
                            4'b0000: begin 
                                write_temp={way0_bank7,way0_bank6,way0_bank5,way0_bank4,way0_bank3,way0_bank2,write_data,way0_bank0};
                            end
                            4'b1110: begin 
                                write_temp={way0_bank7,way0_bank6,way0_bank5,way0_bank4,way0_bank3,way0_bank2,way0_bank1[31:8],write_data[7:0],way0_bank0};
                            end
                            4'b1101: begin 
                                write_temp={way0_bank7,way0_bank6,way0_bank5,way0_bank4,way0_bank3,way0_bank2,way0_bank1[31:16],write_data[7:0],way0_bank1[7:0],way0_bank0};
                            end
                            4'b1011: begin 
                                write_temp={way0_bank7,way0_bank6,way0_bank5,way0_bank4,way0_bank3,way0_bank2,way0_bank1[31:24],write_data[7:0],way0_bank1[15:0],way0_bank0};
                            end
                            4'b0111: begin 
                                write_temp={way0_bank7,way0_bank6,way0_bank5,way0_bank4,way0_bank3,way0_bank2,write_data[7:0],way0_bank1[23:0],way0_bank0};
                            end
                        
                        endcase
                    end
                    3'b010: begin 
                        case(sel)
                            4'b0000: begin 
                                write_temp={way0_bank7,way0_bank6,way0_bank5,way0_bank4,way0_bank3,write_data,way0_bank1,way0_bank0};
                            end
                            4'b1110: begin 
                                write_temp={way0_bank7,way0_bank6,way0_bank5,way0_bank4,way0_bank3,way0_bank2[31:8],write_data[7:0],way0_bank1,way0_bank0};
                            end
                            4'b1101: begin 
                                write_temp={way0_bank7,way0_bank6,way0_bank5,way0_bank4,way0_bank3,way0_bank2[31:16],write_data[7:0],way0_bank2[7:0],way0_bank1,way0_bank0};
                            end
                            4'b1011: begin 
                                write_temp={way0_bank7,way0_bank6,way0_bank5,way0_bank4,way0_bank3,way0_bank2[31:24],write_data[7:0],way0_bank2[15:0],way0_bank1,way0_bank0};
                            end
                            4'b0111: begin 
                                write_temp={way0_bank7,way0_bank6,way0_bank5,way0_bank4,way0_bank3,write_data[7:0],way0_bank2[23:0],way0_bank1,way0_bank0};
                            end
                        
                        endcase
                    end
                    3'b011: begin 
                        case(sel)
                            4'b0000: begin 
                                write_temp={way0_bank7,way0_bank6,way0_bank5,way0_bank4,write_data,way0_bank2,way0_bank1,way0_bank0};
                            end
                            4'b1110: begin 
                                write_temp={way0_bank7,way0_bank6,way0_bank5,way0_bank4,way0_bank3[31:8],write_data[7:0],way0_bank2,way0_bank1,way0_bank0};
                            end
                            4'b1101: begin 
                                write_temp={way0_bank7,way0_bank6,way0_bank5,way0_bank4,way0_bank3[31:16],write_data[7:0],way0_bank3[7:0],way0_bank2,way0_bank1,way0_bank0};
                            end
                            4'b1011: begin 
                                write_temp={way0_bank7,way0_bank6,way0_bank5,way0_bank4,way0_bank3[31:24],write_data[7:0],way0_bank3[15:0],way0_bank2,way0_bank1,way0_bank0};
                            end
                            4'b0111: begin 
                                write_temp={way0_bank7,way0_bank6,way0_bank5,way0_bank4,write_data[7:0],way0_bank3[23:0],way0_bank2,way0_bank1,way0_bank0};
                            end
                        
                        endcase
                    end
                    3'b100: begin 
                        case(sel)
                            4'b0000: begin 
                                write_temp={way0_bank7,way0_bank6,way0_bank5,write_data,way0_bank3,way0_bank2,way0_bank1,way0_bank0};
                            end
                            4'b1110: begin 
                                write_temp={way0_bank7,way0_bank6,way0_bank5,way0_bank4[31:8],write_data[7:0],way0_bank3,way0_bank2,way0_bank1,way0_bank0};
                            end
                            4'b1101: begin 
                                write_temp={way0_bank7,way0_bank6,way0_bank5,way0_bank4[31:16],write_data[7:0],way0_bank4[7:0],way0_bank3,way0_bank2,way0_bank1,way0_bank0};
                            end
                            4'b1011: begin 
                                write_temp={way0_bank7,way0_bank6,way0_bank5,way0_bank4[31:24],write_data[7:0],way0_bank4[15:0],way0_bank3,way0_bank2,way0_bank1,way0_bank0};
                            end
                            4'b0111: begin 
                                write_temp={way0_bank7,way0_bank6,way0_bank5,write_data[7:0],way0_bank4[23:0],way0_bank3,way0_bank2,way0_bank1,way0_bank0};
                            end
                        
                        endcase
                    end
                    3'b101: begin 
                        case(sel)
                            4'b0000: begin 
                                write_temp={way0_bank7,way0_bank6,write_data,way0_bank4,way0_bank3,way0_bank2,way0_bank1,way0_bank0};
                            end
                            4'b1110: begin 
                                write_temp={way0_bank7,way0_bank6,way0_bank5[31:8],write_data[7:0],way0_bank4,way0_bank3,way0_bank2,way0_bank1,way0_bank0};
                            end
                            4'b1101: begin 
                                write_temp={way0_bank7,way0_bank6,way0_bank5[31:16],write_data[7:0],way0_bank5[7:0],way0_bank4,way0_bank3,way0_bank2,way0_bank1,way0_bank0};
                            end
                            4'b1011: begin 
                                write_temp={way0_bank7,way0_bank6,way0_bank5[31:24],write_data[7:0],way0_bank5[15:0],way0_bank4,way0_bank3,way0_bank2,way0_bank1,way0_bank0};
                            end
                            4'b0111: begin 
                                write_temp={way0_bank7,way0_bank6,write_data[7:0],way0_bank5[23:0],way0_bank4,way0_bank3,way0_bank2,way0_bank1,way0_bank0};
                            end
                        
                        endcase
                    end
                    3'b110: begin 
                        case(sel)
                            4'b0000: begin 
                                write_temp={way0_bank7,write_data,way0_bank5,way0_bank4,way0_bank3,way0_bank2,way0_bank1,way0_bank0};
                            end
                            4'b1110: begin 
                                write_temp={way0_bank7,way0_bank6[31:8],write_data[7:0],way0_bank5,way0_bank4,way0_bank3,way0_bank2,way0_bank1,way0_bank0};
                            end
                            4'b1101: begin 
                                write_temp={way0_bank7,way0_bank6[31:16],write_data[7:0],way0_bank6[7:0],way0_bank5,way0_bank4,way0_bank3,way0_bank2,way0_bank1,way0_bank0};
                            end
                            4'b1011: begin 
                                write_temp={way0_bank7,way0_bank6[31:24],write_data[7:0],way0_bank6[15:0],way0_bank5,way0_bank4,way0_bank3,way0_bank2,way0_bank1,way0_bank0};
                            end
                            4'b0111: begin 
                                write_temp={way0_bank7,write_data[7:0],way0_bank6[23:0],way0_bank5,way0_bank4,way0_bank3,way0_bank2,way0_bank1,way0_bank0};
                            end
                        
                        endcase
                    end
                    3'b111: begin 
                        case(sel)
                            4'b0000: begin 
                                write_temp={write_data,way0_bank6,way0_bank5,way0_bank4,way0_bank3,way0_bank2,way0_bank1,way0_bank0};
                            end
                            4'b1110: begin 
                                write_temp={way0_bank7[31:8],write_data[7:0],way0_bank6,way0_bank5,way0_bank4,way0_bank3,way0_bank2,way0_bank1,way0_bank0};
                            end
                            4'b1101: begin 
                                write_temp={way0_bank7[31:16],write_data[7:0],way0_bank7[7:0],way0_bank6,way0_bank5,way0_bank4,way0_bank3,way0_bank2,way0_bank1,way0_bank0};
                            end
                            4'b1011: begin 
                                write_temp={way0_bank7[31:24],write_data[7:0],way0_bank7[15:0],way0_bank6,way0_bank5,way0_bank4,way0_bank3,way0_bank2,way0_bank1,way0_bank0};
                            end
                            4'b0111: begin 
                                write_temp={write_data[7:0],way0_bank7[23:0],way0_bank6,way0_bank5,way0_bank4,way0_bank3,way0_bank2,way0_bank1,way0_bank0};
                            end
                        
                        endcase
                    end
                endcase
            end
            else if(state==`Scanf_cache && hit_way1==`hit) begin //way1д����
                case(addr[4:2])
                    3'b000: begin 
                        case(sel)
                            4'b0000: begin 
                                write_temp={way1_bank7,way1_bank6,way1_bank5,way1_bank4,way1_bank3,way1_bank2,way1_bank1,write_data};
                            end
                            4'b1110: begin 
                                write_temp={way1_bank7,way1_bank6,way1_bank5,way1_bank4,way1_bank3,way1_bank2,way1_bank1,way1_bank0[31:8],write_data[7:0]};
                            end
                            4'b1101: begin 
                                write_temp={way1_bank7,way1_bank6,way1_bank5,way1_bank4,way1_bank3,way1_bank2,way1_bank1,way1_bank0[31:16],write_data[7:0],way1_bank0[7:0]};
                            end
                            4'b1011: begin 
                                write_temp={way1_bank7,way1_bank6,way1_bank5,way1_bank4,way1_bank3,way1_bank2,way1_bank1,way1_bank0[31:24],write_data[7:0],way1_bank0[15:0]};
                            end
                            4'b0111: begin 
                                write_temp={way1_bank7,way1_bank6,way1_bank5,way1_bank4,way1_bank3,way1_bank2,way1_bank1,write_data[7:0],way1_bank0[23:0]};
                            end
                        
                        endcase
                    end
                    3'b001: begin 
                        case(sel)
                            4'b0000: begin 
                                write_temp={way1_bank7,way1_bank6,way1_bank5,way1_bank4,way1_bank3,way1_bank2,write_data,way1_bank0};
                            end
                            4'b1110: begin 
                                write_temp={way1_bank7,way1_bank6,way1_bank5,way1_bank4,way1_bank3,way1_bank2,way1_bank1[31:8],write_data[7:0],way1_bank0};
                            end
                            4'b1101: begin 
                                write_temp={way1_bank7,way1_bank6,way1_bank5,way1_bank4,way1_bank3,way1_bank2,way1_bank1[31:16],write_data[7:0],way1_bank1[7:0],way1_bank0};
                            end
                            4'b1011: begin 
                                write_temp={way1_bank7,way1_bank6,way1_bank5,way1_bank4,way1_bank3,way1_bank2,way1_bank1[31:24],write_data[7:0],way1_bank1[15:0],way1_bank0};
                            end
                            4'b0111: begin 
                                write_temp={way1_bank7,way1_bank6,way1_bank5,way1_bank4,way1_bank3,way1_bank2,write_data[7:0],way1_bank1[23:0],way1_bank0};
                            end
                        
                        endcase
                    end
                    3'b010: begin 
                        case(sel)
                            4'b0000: begin 
                                write_temp={way1_bank7,way1_bank6,way1_bank5,way1_bank4,way1_bank3,write_data,way1_bank1,way1_bank0};
                            end
                            4'b1110: begin 
                                write_temp={way1_bank7,way1_bank6,way1_bank5,way1_bank4,way1_bank3,way1_bank2[31:8],write_data[7:0],way1_bank1,way1_bank0};
                            end
                            4'b1101: begin 
                                write_temp={way1_bank7,way1_bank6,way1_bank5,way1_bank4,way1_bank3,way1_bank2[31:16],write_data[7:0],way1_bank2[7:0],way1_bank1,way1_bank0};
                            end
                            4'b1011: begin 
                                write_temp={way1_bank7,way1_bank6,way1_bank5,way1_bank4,way1_bank3,way1_bank2[31:24],write_data[7:0],way1_bank2[15:0],way1_bank1,way1_bank0};
                            end
                            4'b0111: begin 
                                write_temp={way1_bank7,way1_bank6,way1_bank5,way1_bank4,way1_bank3,write_data[7:0],way1_bank2[23:0],way1_bank1,way1_bank0};
                            end
                        
                        endcase
                    end
                    3'b011: begin 
                        case(sel)
                            4'b0000: begin 
                                write_temp={way1_bank7,way1_bank6,way1_bank5,way1_bank4,write_data,way1_bank2,way1_bank1,way1_bank0};
                            end
                            4'b1110: begin 
                                write_temp={way1_bank7,way1_bank6,way1_bank5,way1_bank4,way1_bank3[31:8],write_data[7:0],way1_bank2,way1_bank1,way1_bank0};
                            end
                            4'b1101: begin 
                                write_temp={way1_bank7,way1_bank6,way1_bank5,way1_bank4,way1_bank3[31:16],write_data[7:0],way1_bank3[7:0],way1_bank2,way1_bank1,way1_bank0};
                            end
                            4'b1011: begin 
                                write_temp={way1_bank7,way1_bank6,way1_bank5,way1_bank4,way1_bank3[31:24],write_data[7:0],way1_bank3[15:0],way1_bank2,way1_bank1,way1_bank0};
                            end
                            4'b0111: begin 
                                write_temp={way1_bank7,way1_bank6,way1_bank5,way1_bank4,write_data[7:0],way1_bank3[23:0],way1_bank2,way1_bank1,way1_bank0};
                            end
                        
                        endcase
                    end
                    3'b100: begin 
                        case(sel)
                            4'b0000: begin 
                                write_temp={way1_bank7,way1_bank6,way1_bank5,write_data,way1_bank3,way1_bank2,way1_bank1,way1_bank0};
                            end
                            4'b1110: begin 
                                write_temp={way1_bank7,way1_bank6,way1_bank5,way1_bank4[31:8],write_data[7:0],way1_bank3,way1_bank2,way1_bank1,way1_bank0};
                            end
                            4'b1101: begin 
                                write_temp={way1_bank7,way1_bank6,way1_bank5,way1_bank4[31:16],write_data[7:0],way1_bank4[7:0],way1_bank3,way1_bank2,way1_bank1,way1_bank0};
                            end
                            4'b1011: begin 
                                write_temp={way1_bank7,way1_bank6,way1_bank5,way1_bank4[31:24],write_data[7:0],way1_bank4[15:0],way1_bank3,way1_bank2,way1_bank1,way1_bank0};
                            end
                            4'b0111: begin 
                                write_temp={way1_bank7,way1_bank6,way1_bank5,write_data[7:0],way1_bank4[23:0],way1_bank3,way1_bank2,way1_bank1,way1_bank0};
                            end
                        
                        endcase
                    end
                    3'b101: begin 
                        case(sel)
                            4'b0000: begin 
                                write_temp={way1_bank7,way1_bank6,write_data,way1_bank4,way1_bank3,way1_bank2,way1_bank1,way1_bank0};
                            end
                            4'b1110: begin 
                                write_temp={way1_bank7,way1_bank6,way1_bank5[31:8],write_data[7:0],way1_bank4,way1_bank3,way1_bank2,way1_bank1,way1_bank0};
                            end
                            4'b1101: begin 
                                write_temp={way1_bank7,way1_bank6,way1_bank5[31:16],write_data[7:0],way1_bank5[7:0],way1_bank4,way1_bank3,way1_bank2,way1_bank1,way1_bank0};
                            end
                            4'b1011: begin 
                                write_temp={way1_bank7,way1_bank6,way1_bank5[31:24],write_data[7:0],way1_bank5[15:0],way1_bank4,way1_bank3,way1_bank2,way1_bank1,way1_bank0};
                            end
                            4'b0111: begin 
                                write_temp={way1_bank7,way1_bank6,write_data[7:0],way1_bank5[23:0],way1_bank4,way1_bank3,way1_bank2,way1_bank1,way1_bank0};
                            end
                        
                        endcase
                    end
                    3'b110: begin 
                        case(sel)
                            4'b0000: begin 
                                write_temp={way1_bank7,write_data,way1_bank5,way1_bank4,way1_bank3,way1_bank2,way1_bank1,way1_bank0};
                            end
                            4'b1110: begin 
                                write_temp={way1_bank7,way1_bank6[31:8],write_data[7:0],way1_bank5,way1_bank4,way1_bank3,way1_bank2,way1_bank1,way1_bank0};
                            end
                            4'b1101: begin 
                                write_temp={way1_bank7,way1_bank6[31:16],write_data[7:0],way1_bank6[7:0],way1_bank5,way1_bank4,way1_bank3,way1_bank2,way1_bank1,way1_bank0};
                            end
                            4'b1011: begin 
                                write_temp={way1_bank7,way1_bank6[31:24],write_data[7:0],way1_bank6[15:0],way1_bank5,way1_bank4,way1_bank3,way1_bank2,way1_bank1,way1_bank0};
                            end
                            4'b0111: begin 
                                write_temp={way1_bank7,write_data[7:0],way1_bank6[23:0],way1_bank5,way1_bank4,way1_bank3,way1_bank2,way1_bank1,way1_bank0};
                            end
                        
                        endcase
                    end
                    3'b111: begin 
                        case(sel)
                            4'b0000: begin 
                                write_temp={write_data,way1_bank6,way1_bank5,way1_bank4,way1_bank3,way1_bank2,way1_bank1,way1_bank0};
                            end
                            4'b1110: begin 
                                write_temp={way1_bank7[31:8],write_data[7:0],way1_bank6,way1_bank5,way1_bank4,way1_bank3,way1_bank2,way1_bank1,way1_bank0};
                            end
                            4'b1101: begin 
                                write_temp={way1_bank7[31:16],write_data[7:0],way1_bank7[7:0],way1_bank6,way1_bank5,way1_bank4,way1_bank3,way1_bank2,way1_bank1,way1_bank0};
                            end
                            4'b1011: begin 
                                write_temp={way1_bank7[31:24],write_data[7:0],way1_bank7[15:0],way1_bank6,way1_bank5,way1_bank4,way1_bank3,way1_bank2,way1_bank1,way1_bank0};
                            end
                            4'b0111: begin 
                                write_temp={write_data[7:0],way1_bank7[23:0],way1_bank6,way1_bank5,way1_bank4,way1_bank3,way1_bank2,way1_bank1,way1_bank0};
                            end
                        
                        endcase
                    end
                endcase
            end
            
            else begin 
                write_temp=(lru_reg[group_addr]==1'b1)? {way0_bank7,way0_bank6,way0_bank5,way0_bank4,way0_bank3,way0_bank2,way0_bank1,way0_bank0}:{way1_bank7,way1_bank6,way1_bank5,way1_bank4,way1_bank3,way1_bank2,way1_bank1,way1_bank0}; 
            end
        end
    end
    
    //״̬ת��
    always @(posedge clk) begin 
        if(rst==`RstEnable) begin 
            state<=`Look_UP;
        end
        else begin 
            state<=next_state;
        end
    end
    //����LRU
    always @(posedge clk) begin 
        if(rst==`RstEnable) begin 
            lru_reg<=0;
        end
        else if(hit_way0==`hit) begin 
            lru_reg[group_addr]<=1'b1;
        end
        else if(hit_way1==`hit) begin 
            lru_reg[group_addr]<=1'b0;
        end
        else if(state==`Write_data && data_valid_o==`Data_valid && cache_hit_o==`miss_hit) begin 
            lru_reg[group_addr]<=~lru_reg[group_addr];//���ԸĽ�
        end
        else begin 
        
        end
    end
    //������Ч��־λ
    always@(posedge clk) begin 
        if(rst==`RstEnable) begin 
            valid_reg[0]<=128'h0000_0000_0000_0000_0000_0000_0000_0000;
            valid_reg[1]<=128'h0000_0000_0000_0000_0000_0000_0000_0000;
        end
        else begin 
            if(state==`Write_data) begin
                valid_reg[lru_reg[group_addr]][group_addr]<=1'b1;
            end 
            else begin 
            
            end
        end
    end
    /*always @(posedge clk) begin 
         if(rst==`RstEnable) begin 
            dirt_reg[0]<=0;
            dirt_reg[1]<=0;
        end
        else begin 
            if(state==`Write_data && cpu_we==1'b0) begin //��δ����
                dirt_reg[lru_reg[group_addr]][group_addr]=1'b0;
            end
            else if(state==`Write_data && cpu_we==1'b1) begin //дδ����
                dirt_reg[lru_reg[group_addr]][group_addr]=1'b1;
            end
            else if(state==`Scanf_cache&& cache_hit_o==`hit&&cpu_we==1'b1) begin //д����
                dirt_reg[hit_way1][group_addr]=1'b1;
            end
            else begin 
            
            end
        end
    end*/
    
    
       //�ж�way0�Ƿ�����
    always @(*) begin 
        if(rst==`RstEnable) begin 
            hit_way0=`miss_hit;
        end
        else begin 
            hit_way0=`miss_hit;
            
            if(valid_reg[0][group_addr]==`cache_way_valid) begin 
                if(tag_way0==addr[31:12]) begin //////////////////////////////////////////////////////////////////////////////////////////
                    hit_way0=`hit;
                    
                end
                else begin 
                    hit_way0=`miss_hit;
                end
            end
            else begin 
                hit_way0=`miss_hit;
                
            end
        end
    end
    //�ж�way1�Ƿ�����
    always @(*) begin 
        if(rst==`RstEnable) begin 
            hit_way1=`miss_hit;
            
        end
        else begin 
            hit_way1=`miss_hit;
            
            if(valid_reg[1][group_addr]==`cache_way_valid) begin 
                if(tag_way1==addr[31:12]) begin //////////////////////////////////////////////////////////////////////////////////////////
                    hit_way1=`hit;
                end
                else begin 
                    hit_way1=`miss_hit;
                end
            end
            else begin 
                hit_way1=`miss_hit;
            end
        end
    end
    
    //����ź����ɣ�����߼�
    always @(*) begin 
        if(rst==`RstEnable) begin 
            data_valid_o=   `Data_invalid;
            
            cache_hit_o=`miss_hit;
            stopreq=`NoStop;
            tagv_way0_ena=1'b0;
            tagv_way1_ena=1'b0;
            tagv_way0_wea=1'b0;
            tagv_way1_wea=1'b0;
            
            ce=`ChipDisable;
            we=1'b0;
            
            addr_valid=1'b0;
        end
        else begin 
            data_valid_o=   `Data_invalid;
            
            cache_hit_o=`miss_hit;
            stopreq=`NoStop;
            tagv_way0_ena=1'b0;
            tagv_way1_ena=1'b0;
            tagv_way0_wea=1'b0;
            tagv_way1_wea=1'b0;
            
            ce=`ChipDisable;
            we=1'b0;
            addr_valid=1'b0;
            case(state) 
                `Look_UP: begin 
                    if(data_req_i==1'b1) begin 
                        data_valid_o=   `Data_invalid;
                        
                        cache_hit_o=`miss_hit;
                        stopreq=`NoStop;
                        tagv_way0_ena=1'b0;
                        tagv_way1_ena=1'b0;
                        tagv_way0_wea=1'b0;
                        tagv_way1_wea=1'b0;
                    end
                    else begin //��ʼ��ȡcache��
                        data_valid_o=`Data_invalid;
                        
                        cache_hit_o=`miss_hit;
                        stopreq=`Stop;
                        tagv_way0_ena=1'b1;
                        tagv_way1_ena=1'b1;
                        tagv_way0_wea=1'b0;
                        tagv_way1_wea=1'b0;
                        
                    end
                end
                `Scanf_cache: begin 
                    tagv_way0_ena=1'b1;
                    tagv_way1_ena=1'b1;
                    tagv_way0_wea=1'b0;
                    tagv_way1_wea=1'b0;  
                    if(hit_way0==`hit||hit_way1==`hit) begin //����cache
                        if(cpu_we==1'b0) begin 
                            stopreq=`NoStop;
                            data_valid_o=`Data_valid;
                        end
                        else begin 
                            stopreq=`Stop;
                            data_valid_o=`Data_invalid;
                        end
                        cache_hit_o=`hit;
                        if(cpu_we==1'b1&& hit_way0==`hit) begin 
                            tagv_way0_ena=1'b1;
                            tagv_way1_ena=1'b0;
                            tagv_way0_wea=1'b1;
                            tagv_way1_wea=1'b0;
                        end
                        else if(cpu_we==1'b1&& hit_way1==`hit) begin 
                            tagv_way0_ena=1'b0;
                            tagv_way1_ena=1'b1;
                            tagv_way0_wea=1'b0;
                            tagv_way1_wea=1'b1;
                        end
                        else begin 
                        
                        end
                        
                    end
                    else begin //cache����ʧ��
                        data_valid_o=`Data_invalid;
                        
                        cache_hit_o=`miss_hit;
                        stopreq=`Stop;
                        
                    end
                    
                end
                `Miss_hit: begin 
                    data_valid_o=`Data_invalid;
                    cache_hit_o=`miss_hit;
                    stopreq=`Stop;
                    ce=`ChipEnable;
                    
                   
                    we=1'b0;
                    addr_valid=1'b1;
                  
                end 
                `Write_ram: begin 
                    
                    if(write_finish==1'b1) begin 
                        data_valid_o=`Data_valid;
                    
                        stopreq=`NoStop;
                    end
                    else begin 
                        data_valid_o=`Data_invalid;
                    
                        stopreq=`Stop;
                    end
                    ce=`ChipEnable;
                    
                    
                    we=1'b1;
                    addr_valid=1'b1;
                end
                `Write_data: begin 
                    if(cpu_we==1'b1) begin 
                        data_valid_o=`Data_invalid;
                        stopreq=`Stop;
                    end
                    else begin 
                        data_valid_o=`Data_valid;
                        stopreq=`NoStop;
                    end
                    
                    cache_hit_o=`miss_hit;
                    
                    if(lru_reg[group_addr]==1'b0) begin 
                        tagv_way0_ena=1'b1;
                        tagv_way1_ena=1'b0;
                        tagv_way0_wea=1'b1;
                        tagv_way1_wea=1'b0;
                    end
                    else if(lru_reg[group_addr]==1'b1) begin 
                        tagv_way0_ena=1'b0;
                        tagv_way1_ena=1'b1;
                        tagv_way0_wea=1'b0;
                        tagv_way1_wea=1'b1;
                    end
                    else begin 
                        tagv_way0_ena=1'b1;
                        tagv_way1_ena=1'b0;
                        tagv_way0_wea=1'b1;
                        tagv_way1_wea=1'b0;
                    end
                    
                end
            endcase
        end
    end
    
    
    always @(*) begin //����data1���,������ʱ
      if(rst==`RstEnable) begin 
            data1=`ZeroWord;
            data2=`ZeroWord;
            is_single=1'b0;
        end
      else if(state==`Scanf_cache&&hit_way0==`hit)begin   
            data1=`ZeroWord;
            data2=`ZeroWord;
            is_single=1'b0;
            case(addr[4:2])/////////////////////////////////////////////
                        3'b000: begin 
                            data1=way0_bank0;
                            data2=way0_bank1;
                        end
                        3'b001:begin 
                            data1=way0_bank1;
                            data2=way0_bank2;
                        end
                        3'b010: begin 
                            data1=way0_bank2;
                            data2=way0_bank3;
                        end
                        3'b011: begin 
                            data1=way0_bank3;
                            data2=way0_bank4;
                        end
                        3'b100: begin 
                            data1=way0_bank4;
                            data2=way0_bank5;
                        end
                        3'b101: begin 
                            data1=way0_bank5;
                            data2=way0_bank6;
                        end
                        3'b110: begin 
                            data1=way0_bank6;
                            data2=way0_bank7;
                        end
                        3'b111:  begin 
                            data1=way0_bank7;
                            is_single=1'b1;
                        end
                        default: begin 
                            data1=`ZeroWord;
                            data2=`ZeroWord;
                            is_single=1'b0;
                        end
                    endcase
         end
         else if(state==`Scanf_cache&&hit_way1==`hit) begin 
             data1=`ZeroWord;
             data2=`ZeroWord;
             is_single=1'b0;
            case(addr[4:2])/////////////////////////////////////////////
                        3'b000: begin 
                            data1=way1_bank0;
                            data2=way1_bank1;
                        end
                        3'b001:begin 
                            data1=way1_bank1;
                            data2=way1_bank2;
                        end
                        3'b010: begin 
                            data1=way1_bank2;
                            data2=way1_bank3;
                        end
                        3'b011: begin 
                            data1=way1_bank3;
                            data2=way1_bank4;
                        end
                        3'b100: begin 
                            data1=way1_bank4;
                            data2=way1_bank5;
                        end
                        3'b101: begin 
                            data1=way1_bank5;
                            data2=way1_bank6;
                        end
                        3'b110: begin 
                            data1=way1_bank6;
                            data2=way1_bank7;
                        end
                        3'b111:  begin 
                            data1=way1_bank7;
                            is_single=1'b1;
                        end
                        default: begin 
                            data1=`ZeroWord;
                            data2=`ZeroWord;
                            is_single=1'b0;
                        end
                    endcase
         end
         else if(data_valid_o==`Data_valid && cache_hit_o==`miss_hit) begin 
                  data1=`ZeroWord;
                  data2=`ZeroWord;
                  is_single=1'b0;
                  case(addr[4:2])/////////////////////////////////////////////
                        3'b000: begin 
                            data1=ram_data[32*1-1:0*32];
                            data2=ram_data[32*2-1:1*32];
                        end
                        3'b001:begin 
                            data1=ram_data[32*2-1:1*32];
                            data2=ram_data[32*3-1:2*32];
                        end
                        3'b010: begin 
                            data1=ram_data[32*3-1:2*32];
                            data2=ram_data[32*4-1:3*32];
                        end
                        3'b011: begin 
                            data1=ram_data[32*4-1:3*32];
                            data2=ram_data[32*5-1:4*32];
                        end
                        3'b100: begin 
                            data1=ram_data[32*5-1:4*32];
                            data2=ram_data[32*6-1:5*32];
                        end
                        3'b101: begin 
                            data1=ram_data[32*6-1:5*32];
                            data2=ram_data[32*7-1:6*32];
                        end
                        3'b110: begin 
                            data1=ram_data[32*7-1:6*32];
                            data2=ram_data[32*8-1:7*32];
                        end
                        3'b111:  begin 
                            data1=ram_data[32*8-1:7*32];
                            is_single=1'b1;
                        end
                        default: begin 
                            data1=`ZeroWord;
                            data2=`ZeroWord;
                            is_single=1'b0;
                        end
                    endcase
             
         end
         else begin 
             data1=`ZeroWord;
             data2=`ZeroWord;
             is_single=1'b0;
         end                   
    end                        
    /*always @(*) begin //����data1���,��way1����ʱ
        if(rst==`RstEnable) begin 
            data=`ZeroWord;
        end
        
        
         else begin 
             data=`ZeroWord;
         end
    end*/
     
    
     //next_state���ɣ�����߼�
    always @(*) begin 
        if(rst==`RstEnable) begin 
            next_state=`Look_UP;
        end
        else begin 
            
        if(cache_flush==1'b1) begin //����״̬��
            next_state=`Look_UP;
        end
        else begin 
            case(state) 
                `Look_UP: begin 
                    if(data_req_i==1'b0) begin 
                        next_state=`Scanf_cache;
                    end
                    else begin
                        next_state=`Look_UP;
                    end
                end
                `Scanf_cache: begin 
                     if(hit_way0==`hit||hit_way1==`hit) begin /////////////////////////////////////////////////////////////////////
                         if(cpu_we==1'b1) begin 
                             next_state=`Write_ram;
                         end
                         else begin 
                             next_state=`Look_UP;
                         end
                         
                     end
                    /* else if(dirt_reg[lru_reg[group_addr]][group_addr]==1'b1)begin 
                         next_state=`Write_ram;
                     end*/
                     else begin
                         next_state=`Miss_hit;
                     end
                 end
                 `Write_ram: begin 
                     if(write_finish==1'b1) begin 
                         next_state=`Scanf_cache;
                     end
                     else begin 
                         next_state=`Write_ram;
                     end
                 end
                 `Miss_hit: begin 
                     if(read_finish==1'b0) begin 
                         next_state=`Miss_hit;
                     end

                     else begin 
                        next_state=`Write_data;
                     end
                  end
                     
                 `Write_data:  begin 
                     if(cpu_we==1'b1) begin 
                         next_state=`Write_ram;
                     end
                      else begin 
                          next_state=`Look_UP;
                      end
                 end
                 
            endcase
        end
        end
    end
    TAGV_ram tagv_way0(
    .clka(clk),
    .ena(tagv_way0_ena),
    .wea(tagv_way0_wea),
    .addra(group_addr),
    .dina(trgv_way0_in),
    .douta(trgv_way0_out)
    );
    TAGV_ram tagv_way1(
     .clka(clk),
    .ena(tagv_way1_ena),
    .wea(tagv_way1_wea),
    .addra(group_addr),
    .dina(trgv_way1_in),
    .douta(trgv_way1_out)
    );
    doublebank_ram way0_bank0_ram(
    .clka(clk),
    .ena(tagv_way0_ena),
    .wea(tagv_way0_wea),
    .addra(group_addr),
    .dina(ram_data[32*1-1:0*32]),
    .douta(way0_bank0)
    );
    doublebank_ram way0_bank1_ram(
    .clka(clk),
    .ena(tagv_way0_ena),
    .wea(tagv_way0_wea),
    .addra(group_addr),
    .dina(ram_data[32*2-1:1*32]),
    .douta(way0_bank1)
    );
    doublebank_ram way0_bank2_ram(
    .clka(clk),
    .ena(tagv_way0_ena),
    .wea(tagv_way0_wea),
    .addra(group_addr),
    .dina(ram_data[32*3-1:2*32]),
    .douta(way0_bank2)
    );
    doublebank_ram way0_bank3_ram(
    .clka(clk),
    .ena(tagv_way0_ena),
    .wea(tagv_way0_wea),
    .addra(group_addr),
    .dina(ram_data[32*4-1:3*32]),
    .douta(way0_bank3)
    );
    doublebank_ram way0_bank4_ram(
    .clka(clk),
    .ena(tagv_way0_ena),
    .wea(tagv_way0_wea),
    .addra(group_addr),
    .dina(ram_data[32*5-1:4*32]),
    .douta(way0_bank4)
    );
    doublebank_ram way0_bank5_ram(
    .clka(clk),
    .ena(tagv_way0_ena),
    .wea(tagv_way0_wea),
    .addra(group_addr),
    .dina(ram_data[32*6-1:5*32]),
    .douta(way0_bank5)
    );
    doublebank_ram way0_bank6_ram(
    .clka(clk),
    .ena(tagv_way0_ena),
    .wea(tagv_way0_wea),
    .addra(group_addr),
    .dina(ram_data[32*7-1:6*32]),
    .douta(way0_bank6)
    );
    doublebank_ram way0_bank7_ram(
    .clka(clk),
    .ena(tagv_way0_ena),
    .wea(tagv_way0_wea),
    .addra(group_addr),
    .dina(ram_data[32*8-1:7*32]),
    .douta(way0_bank7)
    );
    doublebank_ram way1_bank0_ram(
    .clka(clk),
    .ena(tagv_way1_ena),
    .wea(tagv_way1_wea),
    .addra(group_addr),
    .dina(ram_data[32*1-1:0*32]),
    .douta(way1_bank0)
    );
    doublebank_ram way1_bank1_ram(
    .clka(clk),
    .ena(tagv_way1_ena),
    .wea(tagv_way1_wea),
    .addra(group_addr),
    .dina(ram_data[32*2-1:1*32]),
    .douta(way1_bank1)
    );
    doublebank_ram way1_bank2_ram(
    .clka(clk),
    .ena(tagv_way1_ena),
    .wea(tagv_way1_wea),
    .addra(group_addr),
    .dina(ram_data[32*3-1:2*32]),
    .douta(way1_bank2)
    );
    doublebank_ram way1_bank3_ram(
    .clka(clk),
    .ena(tagv_way1_ena),
    .wea(tagv_way1_wea),
    .addra(group_addr),
    .dina(ram_data[32*4-1:3*32]),
    .douta(way1_bank3)
    );
    doublebank_ram way1_bank4_ram(
    .clka(clk),
    .ena(tagv_way1_ena),
    .wea(tagv_way1_wea),
    .addra(group_addr),
    .dina(ram_data[32*5-1:4*32]),
    .douta(way1_bank4)
    );
    doublebank_ram way1_bank5_ram(
    .clka(clk),
    .ena(tagv_way1_ena),
    .wea(tagv_way1_wea),
    .addra(group_addr),
    .dina(ram_data[32*6-1:5*32]),
    .douta(way1_bank5)
    );
    doublebank_ram way1_bank6_ram(
    .clka(clk),
    .ena(tagv_way1_ena),
    .wea(tagv_way1_wea),
    .addra(group_addr),
    .dina(ram_data[32*7-1:6*32]),
    .douta(way1_bank6)
    );
    doublebank_ram way1_bank7_ram(
    .clka(clk),
    .ena(tagv_way1_ena),
    .wea(tagv_way1_wea),
    .addra(group_addr),
    .dina(ram_data[32*8-1:7*32]),
    .douta(way1_bank7)
    );
    
    
endmodule