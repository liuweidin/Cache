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

`define cache_way_valid 1'b1
//����ָ��buffer
`define InstBufferSize 64
`define InstBufferSizelog2 6
`define Valid 1'b1
`define InValid 1'b0
`define single_issue 1'b1
`define dual_issue 1'b0


/////////////////////////////////��ָ���йصĺ궨��
`define EXE_NOP 6'B000000 //
`define EXE_ORI 6'B001101 //ORIָ����
`define EXE_ANDI 6'b001100
`define EXE_XORI 6'b001110
`define EXE_LUI 6'b001111
`define EXE_PREF  6'b110011


//specialָ�����
`define EXE_AND  6'b100100
`define EXE_OR   6'b100101
`define EXE_XOR 6'b100110
`define EXE_NOR 6'b100111
`define EXE_SLLV  6'b000100
`define EXE_SRLV  6'b000110
`define EXE_SRAV  6'b000111
`define EXE_SYNC  6'b001111
//�ƶ�ָ��
`define EXE_MOVN  6'b001011
`define EXE_MOVZ  6'b001010


//�߼���λָ��
`define EXE_SLL  6'b000000
`define EXE_SRL  6'b000010
`define EXE_SRA  6'b000011
//����ָ��

`define EXE_ADD 6'b100000
`define EXE_SLT 6'b101010
`define EXE_SLTU 6'b101011
`define EXE_SLTI 6'b001010
`define EXE_SLTIU 6'b001011
`define EXE_ADDU 6'b100001
`define EXE_SUB 6'b100010
`define EXE_SUBU 6'b100011
`define EXE_ADDI 6'b001000
`define EXE_ADDIU 6'b001001


//ת��ָ��
`define EXE_J  6'b000010
`define EXE_JAL  6'b000011
`define EXE_JALR  6'b001001
`define EXE_JR  6'b001000
`define EXE_BEQ  6'b000100
`define EXE_BGEZ  5'b00001
`define EXE_BGEZAL  5'b10001
`define EXE_BGTZ  6'b000111
`define EXE_BLEZ  6'b000110
`define EXE_BLTZ  5'b00000
`define EXE_BLTZAL  5'b10000
`define EXE_BNE  6'b000101

`define SSNOP 32'b00000000000000000000000001000000

`define EXE_MULT 6'b011000
`define EXE_MULTU 6'b011001
`define EXE_MUL 6'b000010


`define EXE_LB  6'b100000
`define EXE_LBU  6'b100100
`define EXE_LH  6'b100001
`define EXE_LHU  6'b100101
`define EXE_LL  6'b110000
`define EXE_LW  6'b100011
`define EXE_SB  6'b101000
`define EXE_SC  6'b111000
`define EXE_SH  6'b101001
`define EXE_SW  6'b101011



`define EXE_SPECIAL_INST 6'b000000 //
`define EXE_REGIMM_INST 6'b000001
`define EXE_SPECIAL2_INST 6'b011100


//AluOP
`define EXE_SYSCALL_OP 8'b00001100

`define EXE_TEQ_OP 8'b00110100
`define EXE_TEQI_OP 8'b01001000
`define EXE_TGE_OP 8'b00110000
`define EXE_TGEI_OP 8'b01000100
`define EXE_TGEIU_OP 8'b01000101
`define EXE_TGEU_OP 8'b00110001
`define EXE_TLT_OP 8'b00110010
`define EXE_TLTI_OP 8'b01000110
`define EXE_TLTIU_OP 8'b01000111
`define EXE_TLTU_OP 8'b00110011
`define EXE_TNE_OP 8'b00110110
`define EXE_TNEI_OP 8'b01001001
   
`define EXE_ERET_OP 8'b01101011

`define EXE_AND_OP   8'b00100100
`define EXE_OR_OP    8'b00100101
`define EXE_XOR_OP  8'b00100110
`define EXE_NOR_OP  8'b00100111
`define EXE_ANDI_OP  8'b01011001
`define EXE_ORI_OP  8'b01011010
`define EXE_XORI_OP  8'b01011011
`define EXE_LUI_OP  8'b01011100   

`define EXE_SLL_OP  8'b01111100
`define EXE_SLLV_OP  8'b00000100
`define EXE_SRL_OP  8'b00000010
`define EXE_SRLV_OP  8'b00000110
`define EXE_SRA_OP  8'b00000011
`define EXE_SRAV_OP  8'b00000111

`define EXE_MOVN_OP  8'b00001000
`define EXE_MOVZ_OP  8'b00001001


`define EXE_NOP_OP    8'b00000000

`define EXE_SLT_OP  8'b00101010
`define EXE_SLTU_OP  8'b00101011
`define EXE_SLTI_OP  8'b01010111
`define EXE_SLTIU_OP  8'b01011000   
`define EXE_ADD_OP  8'b00100000
`define EXE_ADDU_OP  8'b00100001
`define EXE_SUB_OP  8'b00100010
`define EXE_SUBU_OP  8'b00100011
`define EXE_ADDI_OP  8'b01010101
`define EXE_ADDIU_OP  8'b01010110


`define EXE_MULT_OP  8'b00011000
`define EXE_MULTU_OP  8'b00011001
`define EXE_MUL_OP  8'b10101001


//ת��ָ��op
`define EXE_J_OP  8'b01001111
`define EXE_JAL_OP  8'b01010000
`define EXE_JALR_OP  8'b00001001
`define EXE_JR_OP  8'b00001000
`define EXE_BEQ_OP  8'b01010001
`define EXE_BGEZ_OP  8'b01000001
`define EXE_BGEZAL_OP  8'b01001011
`define EXE_BGTZ_OP  8'b01010100
`define EXE_BLEZ_OP  8'b01010011
`define EXE_BLTZ_OP  8'b01000000
`define EXE_BLTZAL_OP  8'b01001010
`define EXE_BNE_OP  8'b01010010

`define EXE_LB_OP  8'b11100000
`define EXE_LBU_OP  8'b11100100
`define EXE_LH_OP  8'b11100001
`define EXE_LHU_OP  8'b11100101
`define EXE_LW_OP  8'b11100011
`define EXE_PREF_OP  8'b11110011
`define EXE_SB_OP  8'b11101000

`define EXE_SW_OP  8'b11101011

`define EXE_SYNC_OP  8'b00001111
//�����쳣ָ��
`define EXE_SYSCALL 6'b001100
   
`define EXE_TEQ 6'b110100
`define EXE_TEQI 5'b01100
`define EXE_TGE 6'b110000
`define EXE_TGEI 5'b01000
`define EXE_TGEIU 5'b01001
`define EXE_TGEU 6'b110001
`define EXE_TLT 6'b110010
`define EXE_TLTI 5'b01010
`define EXE_TLTIU 5'b01011
`define EXE_TLTU 6'b110011
`define EXE_TNE 6'b110110
`define EXE_TNEI 5'b01110
   
`define EXE_ERET 32'b01000010000000000000000000011000

//AluSel
`define EXE_RES_LOGIC 3'b001//�߼�����ָ��
`define EXE_RES_SHIFT 3'b010//��λָ��
`define EXE_RES_MOV 3'b011//�ƶ�ָ��
`define EXE_RES_ARITHMETIC 3'b100	
`define EXE_RES_JUMP_BRANCH 3'b110
`define EXE_RES_MUL 3'b101
`define EXE_RES_LOAD_STORE 3'b111	

`define EXE_RES_NOP 3'b000


