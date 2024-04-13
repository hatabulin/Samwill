#include "encoder.h"

#define SetBit(port, bit) port|= (1<<bit)
#define ClearBit(port, bit) port&= ~(1<<bit)

//��� ��� ����������� ����
#define b00000011 3
#define b11010010 210
#define b11100001 225

volatile unsigned char bufEnc = 0; //����� ��������

//������� �������������
//__________________________________________
void ENC_InitEncoder(void)
{
  ClearBit(DDR_Enc, Pin1_Enc); //����
  ClearBit(DDR_Enc, Pin2_Enc);
  SetBit(PORT_Enc, Pin1_Enc);//��� ������������� ��������
  SetBit(PORT_Enc, Pin2_Enc);
}

//������� ������ ��������
//___________________________________________
void ENC_PollEncoder(void)
{
static unsigned char stateEnc; 	//������ ������������������ ��������� ��������
unsigned char tmp;  
unsigned char currentState = 0;

//��������� ��������� ������� ����������������
if ((PIN_Enc & (1<<Pin1_Enc))!= 0) {SetBit(currentState,0);}
if ((PIN_Enc & (1<<Pin2_Enc))!= 0) {SetBit(currentState,1);}

//���� ����� �����������, �� �������
tmp = stateEnc;
if (currentState == (tmp & b00000011)) return;

//���� �� �����, �� �������� � ��������� � ���
tmp = (tmp<<2)|currentState;
stateEnc = tmp;

//���������� ������������ ������������������
if (tmp == b11100001) bufEnc = LEFT_SPIN;
if (tmp == b11010010) bufEnc = RIGHT_SPIN;
return;
}

//������� ������������ �������� ������ ��������
//_____________________________________________
unsigned char ENC_GetStateEncoder(void)
{
  unsigned char tmp = bufEnc;
  bufEnc = 0;
  return tmp;
}


