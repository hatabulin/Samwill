.include "m32Adef.inc"
.def     Temp=R16
.def     NewState=R17 ///���� ���������� ����� ��������� 
					  ///����� �� ������� ����� �������
.def     OldState=R18 //��� �������� ��������� �����  
					  //����������� ������ 

.def     Count=R20  //��������� �������

.cseg
.org 0
rjmp RESET ; Reset Handler
nop
reti; EXT_INT0 ; IRQ0 Handler
nop
reti; EXT_INT1 ; IRQ1 Handler
nop
reti; EXT_INT2 ; IRQ2 Handler
nop
reti; TIM2_COMP ; Timer2 Compare Handler
nop
reti; TIM2_OVF ; Timer2 Overflow Handler
nop
reti; TIM1_CAPT ; Timer1 Capture Handler
nop
reti; TIM1_COMPA ; Timer1 CompareA Handler
nop
reti; TIM1_COMPB ; Timer1 CompareB Handler
nop
reti; TIM1_OVF ; Timer1 Overflow Handler
nop
rjmp Scan; TIM0_COMP ; Timer0 Compare Handler <--------�������� ��������� ������������
nop
reti; TIM0_OVF ; Timer0 Overflow Handler
nop
reti; SPI_STC ; SPI Transfer Complete Handler
nop
reti; USART_RXC ; USART RX Complete Handler
nop
reti; USART_UDRE ; UDR Empty Handler
nop
reti; USART_TXC ; USART TX Complete Handler
nop
reti; ADC ; ADC Conversion Complete Handler
nop
reti; EE_RDY ; EEPROM Ready Handler
nop
reti; ANA_COMP ; Analog Comparator Handler
nop
reti; TWI ; Two-wire Serial Interface Handler
nop
reti; SPM_RDY ; Store Program Memory Ready Handler
nop
reset:
/////////////////////������������� ����� ////////
ldi Temp,high(RamEnd)
out SPH,Temp
ldi Temp,low(RamEnd)
out SPL,Temp
///////////////////////////////////////

clr OldState
ldi temp,255
out DDRC,temp //� ����� ����� ���������� ���������� 8 ��.
ldi temp,1     //����� ������ ���������
out PORTC,temp  //������
ldi count,0

///////////������������� �������////////
ldi temp,0b00000010 //����������� ������ ��� 
out TCCR0,temp		//���� ���������� ����������� 
ldi temp,0b00000010 //� �������� �������� 1000 ��� � ������� (������� �� 1���)
out TIMSK,temp      //���� ���������� ������� ������ ���
ldi temp,0x8A       //��� ����� ������ ������� �������������� ��������
out OCR0,temp		//� ���� ��������
/////////////////////////////////////////
sei


//////����������� ����//
Begin:
rjmp Begin
////////////////////////



///////////////////��������� ������������ ��������//////////////////////////
Scan:
IN NewState,PINB //������ ���� � �������� ��������� �������
cbr NewState,0b11111100 //�������� �������� ����. (��� ����� ������ ����)
				  ///BA
//���� �������� ����� ��������� � 4- ����������:
//1) ��� ���� ��� ������� ������ ���� ����� ���� ? 
Cpi OldState,0 
brne Cpi1 //���� ��� �� ��������� ������ �������
	Cpi NewState,2
	brne Cpi11
	Rcall RightShift
	Cpi11:
	Cpi NewState,1
	brne Cpi12
	rcall LeftShift
	Cpi12:
	mov OldState,NewState //�� ��� ���� ����� ���������� ��������, ����� ������...
reti
Cpi1:
//2) ��� ������� ������ ��� �=1  �  ��� �=0 ? 
Cpi OldState,1
brne Cpi2 //���� ��� �� ��������� ������ �������
	Cpi NewState,0 //
	brne Cpi21
	Rcall RightShift
	Cpi21:
	Cpi NewState,3
	brne Cpi22
	rcall LeftShift
	Cpi22:
	mov OldState,NewState //�� ��� ���� ����� ���������� ��������, ����� ������...
reti
Cpi2:
//3 ) ��� ������� ������  ��� �=1 �  ��� �=0 ?
Cpi OldState,2
brne Cpi3 //���� ��� �� ��������� ������ �������
	Cpi NewState,3
	brne Cpi31
	Rcall RightShift
	Cpi31:
	Cpi NewState,0
	brne Cpi12
	rcall LeftShift
	Cpi32:
	mov OldState,NewState //�� ��� ���� ����� ���������� ��������, ����� ������...
reti
Cpi3:
///4) ��� ������� ������ ��� ����=1 ? 
Cpi OldState,3
Brne Cpi4 //���� ��� �� ������� �� ��������� ������������
	Cpi NewState,1
	brne Cpi41
	Rcall RightShift
	Cpi41:
	Cpi NewState,2
	brne Cpi42
	rcall LeftShift
	Cpi42:
	mov OldState,NewState //�� ��� ���� ����� ���������� ��������, ����� ������...
Cpi4:
reti

////////////////////////////////////////////////////////////////

LeftShift:
	cpi count,4 //��������� ����� ��������� 4 ����? 
	brne exitLS
	///////����� ����� �������� ���� ���////////////
	//////������� ����� ����������� ���� ������ � ����///
	//////� ���������������� ������� �� ������� ������=) 
	clr count
	in temp,portc
	cpi temp,0b10000000
	breq exitLS2
	lsl temp
	out PORTC,temp
	//////////////////����� ������ ����/////////////
	brne exitLS
	exitLS:
	inc count
	exitLS2:
ret

RightShift:
	cpi count,4 //��������� ����� ��������� 4 ����? 
	brne exitRS
	///////����� ����� �������� ���� ���////////////
	//////������� ����� ����������� ���� ������ � �����///
	//////� ���������������� ������� �� ������� ������=) 
	clr count
	in temp,portc
	cpi temp,0b00000001
	breq exitRS2
	lsr temp
	out PORTc,temp
	//////////////////����� ������ ����/////////////
	brne exitRS
	exitRS:
	inc count
	exitRS2:
ret
