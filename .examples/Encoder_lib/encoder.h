#ifndef ENCODER_H
#define ENCODER_H

#include <avr/io.h>            

#define PORT_encoder PORTD /*������� ����� ��������*/
#define PIN_encoder  PIND  /*������� ������� ����� ��������*/
#define DDR_encoder  DDRD  /*������� �����������*/
#define ENC_0        PD5   /*����� 0 ��������*/       
#define ENC_1        PD7   /*����� 1 ��������*/
#define num_of_st    4     /*���������� ��������� �� ���� "������"*/
#define state_0      0x00  /*��������� ������� 0 ��������*/
#define state_1      _BV(ENC_0)             /*��������� ������� 1 ��������*/
#define state_2      _BV(ENC_1)             /*��������� ������� 2 ��������*/
#define state_3      _BV(ENC_1) + _BV(ENC_0)/*��������� ������� 3 ��������*/

extern unsigned int EncState,EncData;      //���������� ���������� ��������� � ������ ��������

void Encoder_init(void);                   //������� ������������� ��������
void Encoder_Scan(unsigned int min, unsigned int max);//������� ��������� ��������

#endif


