`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/22 15:42:09
// Design Name: 
// Module Name: defines
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


///////////////ȫ�ֺ궨��
`define RstEnable 1'b1  //��λ��Ч�ź�
`define RestDisable 1'b0// ��λ�ź���Ч
`define ZeroWord 32'h0000 //һ���ֵ����ź�
`define WriteEnable 1'b1 //дʹ��--��Ч
`define WriteDisable 1'b0//дʹ��--��Ч
`define ReadEnable 1'b1//��ʹ��--��Ч
`define ReadDisable 1'b0//��ʹ��--��Ч
`define AluOpBus 7:0//����׶� �����alu������Ŀ��--8λ����Ӧ256��ָ���λ��
`define AluSelBus 2:0//����׶� �����alu����Ƭѡ�Ŀ��
`define InstValid 1'b0 //ָ����Ч
`define InstInvalid 1'b1//ָ����Ч
`define Stop 1'b1  //ͣ��
`define NoStop 1'b0 //��ͣ��
`define InDelaySlot 1'b1 //���ӳٲ���
`define NotInDelaySlot 1'b0
`define Branch 1'b1  //��֧��
`define NotBranch 1'b0 //��֧��
`define InterruptAssert 1'b1//����ָ��
`define InterruptNotAssert 1'b0
`define TrapAssert 1'b1
`define TrapNotAssert 1'b0
`define True_v 1'b1       //�߼���
`define False_v 1'b0      //�߼���
`define ChipEnable 1'b1   //оƬʹ��
`define ChipDisable 1'b0 //оƬ��ֹ
`define Single_issue 1'b1
`define Dual_issue 1'b0

///////ͨ�üĴ�������ض���
`define RegAddrBus 4:0 //RegFileģ���ַ�߿��
`define RegBus 31:0 //Regfileģ�������߿��
`define RegWidth 32//ͨ�üĴ������
`define DoubleRegWidth 64
`define DoubleRegBus 63:0
`define RegNum 32   //�Ĵ���������
`define RegNumLog2 5   //�Ĵ����ĵ�ַλ��
`define NOPRegAddr 5'b00000

`define InstAddrBus 31:0  /// ROM��ַ�߿��
`define InstBus 31:0  ///ROM�����߿��


`define RstDisable 1'b0


`define START_IDIE 3'b 000
`define START_READ 3'b 001
`define START_WRITE 3'b 010
`define START_END 3'b 101

`define Log2 22

`define MEMready 1'b1
`define MEMNoready 1'b0

`define cache_lineBus 255:0

//���ݴ洢��data_ram
`define DataAddrBus 31:0
`define DataBus 31:0
`define DataMemNum 131071
`define DataMemNumLog2 17
`define ByteWidth 7:0
`define DoubleDataBus 63:0


//cache
`define miss_hit 1'b0
`define hit 1'b1
`define RstEnable 1'b1  //��λ��Ч�ź�
`define RestDisable 1'b0// ��λ�ź���Ч
`define Data_req 1'b0
`define Data_valid 1'b1
`define Data_invalid 1'b0


`define Look_UP 3'b000//��ַת�������ҽ���ַ������Ӧ��bram
`define Scanf_cache 3'b011 //����cache����
`define Miss_hit 3'b001//cache�����У��ȴ����ݴ�rom��ȡ��
`define Write_data 3'b010//������д��bram��
`define Write_ram 3'b110//������д��ram��




