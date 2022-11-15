`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/22 15:39:22
// Design Name: 
// Module Name: isram_ctrl
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
`include "defines.v"

module isram_ctrl(
    input wire clk,
     input wire rst,
    
     input wire [`cache_lineBus] write_data,//cache�滻��������
     input wire [19:0] addr,//д���߶���ַ
     input wire we,//��д�źţ�1Ϊд��0Ϊ��
     input wire sram_flush,//״̬�����ã�����Ч
     
     //�����ź�
     input wire addr_valid,//�����ַ��Ч,����Ч
     output reg write_finish,//д���������,����Ч
     output reg read_finish,//��ȡ������ɣ�����Ч
     //����������
     output reg [`cache_lineBus] read_data,//��ȡ������
     //���͸�sram���ź�
    inout wire[31:0] data,//˫�����ݴ���˿�
    output reg ram_ce,//ramƬѡ�źţ�����Ч
    output reg ram_oe,//��ʹ�ܣ�����Ч
    output reg ram_we,//дʹ�ܣ�����Ч
    output wire[19:0] ram_addr,//��д���ݵ�ַ
    output wire[3:0] ram_sel//�ֽ�Ƭѡ�źţ�0��Ч
    );
    reg [2:0] state;
    reg [2:0] next_state;
    
    reg [`DataBus] write_data_reg;
    reg [3:0] count;
    
    reg [19:0]addr_reg;
    assign ram_sel=4'b0000;
    
    assign ram_addr=addr_reg;
    assign data=we? write_data_reg:32'bz;
    //assign read_data=
    always @(posedge clk ) begin //״̬ת��
        if(rst==`RstEnable) begin 
            state<=`START_IDIE;
        end
        else if (addr_valid==1'b0)begin 
            state<=`START_IDIE;
        end
        else begin 
            state<=next_state;
        end
    end
    
    always @(posedge clk) begin //������ȡ��8������
        if(rst==`RstEnable) begin 
            count<=4'b0000;
        end
        else begin 
            if(state== `START_READ&&next_state!= `START_IDIE) begin 
                count<=count+1'b1;
            end
            else if((state== `START_WRITE&&next_state!= `START_IDIE)||(state==`START_IDIE&&next_state==`START_WRITE))begin 
                count<=count+1'b1;
            end
            else begin 
                count<=4'b0000;
            end
        end
    end
    
    always @(posedge clk) begin //��ַ����
        if(rst==`RstEnable) begin 
            addr_reg<=20'hzzzzz;
        end
        else begin 
            if(((next_state==`START_READ&&state==`START_IDIE)||(next_state==`START_WRITE&&state==`START_IDIE))&&addr_valid==1'b1) begin 
                addr_reg<=addr;
            end
            else if((state==`START_READ||state==`START_WRITE)&&addr_valid==1'b1) begin 
                addr_reg=addr_reg+1'b1;
            end
            /*else if(next_state==`START_IDIE) begin 
                addr_reg<=20'hzzzzz;
            end*/
            else begin 
                addr_reg<=20'hzzzzz;
            end
        end
    end
    
    always @(posedge clk) begin //������ȡ��
        if(rst==`RstEnable) begin 
            read_data<=256'hzzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz;
        end
        else begin 
            if(state== `START_READ) begin 
                case(count)
                    4'h0: begin 
                        read_data[32*1-1:0*32]<=data;
                    end
                     4'h1: begin 
                        read_data[32*2-1:1*32]<=data;
                    end
                     4'h2: begin 
                        read_data[32*3-1:2*32]<=data;
                    end
                    4'h3: begin 
                        read_data[32*4-1:3*32]<=data;
                    end
                    4'h4: begin 
                        read_data[32*5-1:4*32]<=data;
                    end
                    4'h5: begin 
                        read_data[32*6-1:5*32]<=data;
                    end
                    4'h6: begin 
                        read_data[32*7-1:6*32]<=data;
                    end
                    4'h7: begin 
                        read_data[32*8-1:7*32]<=data;
                    end
                endcase
            end
            else begin 
            
            end
        end
    end
    
    always @(posedge clk) begin //����д������
        if(rst==`RstEnable) begin 
            write_data_reg<=32'hzzzz_zzzz;
        end
        else begin 
            if(state== `START_WRITE||next_state== `START_WRITE) begin //
                case(count)
                    4'h0: begin 
                        write_data_reg<=write_data[32*1-1:0*32];
                    end
                     4'h1: begin 
                        write_data_reg<=write_data[32*2-1:1*32];
                    end
                     4'h2: begin 
                        write_data_reg<=write_data[32*3-1:2*32];
                    end
                    4'h3: begin 
                        write_data_reg<=write_data[32*4-1:3*32];
                    end
                    4'h4: begin 
                        write_data_reg<=write_data[32*5-1:4*32];
                    end
                    4'h5: begin 
                        write_data_reg<=write_data[32*6-1:5*32];
                    end
                    4'h6: begin 
                        write_data_reg<=write_data[32*7-1:6*32];
                    end
                    4'h7: begin 
                        write_data_reg<=write_data[32*8-1:7*32];
                    end
                endcase
            end
            else begin 
            
            end
        end
    end
    
    
    
    always @(*) begin 
        if(rst==`RstEnable) begin 
            write_finish=`MEMNoready;
            read_finish=`MEMNoready;
            ram_oe=1'b1;
            ram_we=1'b1;
            ram_ce=1'b1;
            
        end
        else begin 
            ram_oe=1'b1;
            ram_we=1'b1;
            ram_ce=1'b1;
            write_finish=`MEMNoready;
            read_finish=`MEMNoready;
            case(state)
                `START_IDIE: begin 
                    
                    if(addr_valid==1'b1) begin 
                        
                        if(we==1'b1) begin 
                            ram_oe=1'b1;
                            ram_we=1'b0;
                            ram_ce=1'b0;
                            
                            write_finish=`MEMNoready;
                            read_finish=`MEMNoready;
                        end 
                        else if(we==1'b0) begin 
                            ram_oe=1'b0;
                            ram_we=1'b1;
                            ram_ce=1'b0;
                            
                            write_finish=`MEMNoready;
                            read_finish=`MEMNoready;
                        end
                        else begin 
                            ram_oe=1'b1;
                            ram_we=1'b1;
                            ram_ce=1'b1;
                            write_finish=`MEMNoready;
                            read_finish=`MEMNoready;
                           // ram_addr=20'bz;
                        end
                    end
                    else begin 
                        write_finish=`MEMNoready;
                        read_finish=`MEMNoready;
                        ram_oe=1'b1;
                        ram_we=1'b1;
                        ram_ce=1'b1;
                            
                       // ram_addr=20'bz;
                    end
                    
                    
                end
               `START_READ: begin 
                    ram_oe=1'b0;
                    ram_we=1'b1;
                    ram_ce=1'b0;
                    
                   
                   if(count==4'h8) begin 
                       read_finish=`MEMready;
                   end
                end
                `START_WRITE: begin
                    ram_oe=1'b1;
                    ram_we=1'b0;
                    ram_ce=1'b0;
                    if(count==4'h8) begin 
                       write_finish=`MEMready;
                   end
                   // ram_addr=cpu_addr[`Log2:2];
                end
                
                
                default : begin 
                    ram_oe=1'b1;
                    ram_we=1'b1;
                    ram_ce=1'b1;
                    write_finish=`MEMNoready;
                    read_finish=`MEMNoready;
                    //ram_addr=20'bz;
                end
            endcase
        end
    end
    always @ (*)
    begin 
        if(sram_flush==1'b1) begin 
                next_state=`START_IDIE;
            end
            else begin 
                case(state)
                `START_IDIE: begin 
                    if(we==1'b1 && addr_valid==`ChipEnable) begin  //д
                         next_state=`START_WRITE;
                    end
                    else if(we==1'b0 && addr_valid==`ChipEnable)begin 
                        next_state=`START_READ;
                    end
                    else begin 
                        next_state=`START_IDIE;
                    end
                end
                `START_READ: begin 
                    if(count==4'h8) begin 
                        next_state=`START_IDIE;
                    end
                    else begin 
                        next_state=`START_READ;
                    end
                end
                `START_WRITE:begin 
                    if(count==4'h8) begin 
                        next_state=`START_IDIE;
                    end
                    else begin 
                        next_state=`START_WRITE;
                    end
                end

                default: next_state=`START_IDIE;
            endcase
            end
            
            
    end
    
    
endmodule
