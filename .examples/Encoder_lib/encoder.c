//����� ������� ��� ������������ ���������������� ��������
//����� s_black - www.embed.com.ua
//���� 2010 �. 	

#include "encoder.h"

void Encoder_init (void)//������� ������������� ��������
{
    DDR_encoder &= ~_BV(ENC_0);//�������������� �����
	DDR_encoder &= ~_BV(ENC_1);//��� ����������� ��������
	PORT_encoder |= _BV(ENC_0) | _BV(ENC_1);//���������� ���������� ��������
}

void Encoder_Scan(unsigned int min, unsigned int max)//������� ��������� ��������
{
    static unsigned char New, EncPlus, EncMinus;//���������� ������ �������� ��������, ������������� ���������� + � -
 
    New = PIN_encoder & (_BV(ENC_1) | _BV(ENC_0));// ��������� ��������� ��������� ��������
 
    if(New != EncState)//���� �������� ���������� �� ��������� � ��������
    {
        switch(EncState) //������� �������� �������� ��������
	    {
	    case state_2:if(New == state_3) EncPlus++;//� ����������� �� �������� �����������
		             if(New == state_0) EncMinus++;//��� ���������  
		       break;
	    case state_0:if(New == state_2) EncPlus++;
		             if(New == state_1) EncMinus++; 
		       break;
	    case state_1:if(New == state_0) EncPlus++;
		             if(New == state_3) EncMinus++; 
		       break;
	    case state_3:if(New == state_1) EncPlus++;
		             if(New == state_2) EncMinus++; 
		       break;
        default:break;
	    }
		
		if(EncPlus == num_of_st) //���� ������ ���� "������"
		{
		    if(EncData++ >= max) EncData = max;//����������� ��������, ������, ����� �� ����� �� ������� ��������
			EncPlus = 0;
		}
		
		if(EncMinus == num_of_st) //���� ������ ���� "������"
		{
		    if(EncData-- <= min) EncData = min;//��������� ��������, ������ ����� �� ����� �� ������� ������� ��������
			EncMinus = 0;
		}
        EncState = New;	// ���������� ����� �������� ����������� ���������
	}
}