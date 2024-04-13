.include"C:\tn2313def.inc"

;***************************** ����������� *************************

		.def		RegAB=r19		;������� �������� ��������� ��������

		.def		RegLed=r20		;��� �������� �������� ����� ����� ��������� �������� ��������
									;��� �������� �������� ������ ����� ����������� �������� ��������

;******************************** ������� ****************************

.macro OUTI
		ldi		r16,@1
		out		@0,r16
.endmacro


;******************************** ��� ************************************
.dseg

.cseg
.org 0

 	rjmp RESET ; Reset Handler
nop		;rjmp INT_0 ; External Interrupt0 Handler
nop 	;rjmp INT_1 ; External Interrupt1 Handler
nop 	;rjmp TIM1_CAPT ; Timer1 Capture Handler
nop 	;rjmp TIM1_COMPA ; Timer1 CompareA Handler
nop 	;rjmp TIM1_OVF ; Timer1 Overflow Handler
nop 	;rjmp TIM0_OVF ; Timer0 Overflow Handler
nop		;rjmp USART0_RXC ; USART0 RX Complete Handler
nop		;rjmp USART0_DRE ; USART0,UDR Empty Handler
nop 	;rjmp USART0_TXC ; USART0 TX Complete Handler
nop		;rjmp ANA_COMP ; Analog Comparator Handler
nop		;rjmp PCINT_n ; Pin Change Interrupt	
nop 	;rjmp TIMER1_COMPB ; Timer1 Compare B Handler
nop 	;rjmp TIMER0_COMPA ; Timer0 Compare A Handler
nop 	;rjmp TIMER0_COMPB ; Timer0 Compare B Handler
nop 	;rjmp USI_START ; USI Start Handler
nop 	;rjmp USI_OVERFLOW ; USI Overflow Handler
nop 	;rjmp EE_READY ; EEPROM Ready Handler
nop 	;rjmp Watchdog_Time_Out:


RESET:	ldi		r16,low(RAMEND)		;����������� ������ 
		out		SPL,r16				;����� � ���



		ser		r16
		out		DDRB,r16			;����� ����� B - ������
		clr		r16
		out		DDRD,r16			;����� ����� D - �����		
		out		PortB,r16

		OUTI	ACSR,0b10000000		;���������� ������� ��������� ����������� (ASD=1)
	
		clr		r16
		clr		RegAB				;������� ������ ��� ������ ��������
		ldi		RegLed,16
		

start:
		out		PortB,RegLed		;���������� ��� � ��� � �������� RegLed ����� PortB

		in		r16,PinD			;��������� �������� ����� D � ������� 
		andi 	r16,0b00000011		;�������� ��� ��������� ���� R16
		cpi		RegAB,0				;������� RegAB ����� 0?
		brne	ScanEncoder			;���� ��� , ������ �� ����� ScanEncoder
		cpi		r16,0				;�� ����� ������ 0?
		brne	Exit				;���� ��� , ������� ���
		ldi		RegAB,128			;����� "�������" ��� �������� �� ������� ���������
		rjmp	Exit				;�.�. � ��������� ��� ������ �� ������ ����� ���������
ScanEncoder:
		cpi		r16,3				;�� ����� ������ ������� ������� ?
		breq	GoWork				;���� �� , �� ����� �� ����������
		cpi		r16,1				;���? ����� ����� �� ������ ����� ���.�������
		brne	m1					;���� ��� �� ����� ��������� ������ �����
		inc		RegAB				;����� ����������� �������� RegA �� �������
		cpi		RegAB,250			;����������������� �� ������������ � ���� ���������
		brsh	WorkA				;�� 250,������ �������� ���� �������� � ������� �
		rjmp	Exit				;� �������
m1:		cpi		r16,2				;����� �� ������ ����� ���. �������?
		brne	m2					;���� ����� ���,������� ���
		dec		RegAB				;����� ����������� �������� RegB �� �������
		cpi		RegAB,5				;����������������� �� ������������ � ���� ���������
		brlo	WorkB				;�� 5,������ �������� ���� �������� � ������� �
m2:		rjmp	Exit				;�������
GoWork:	
		cpi		RegAB,128			;����������, ��� � ��� ��� ���������� � ��������
		breq	Exit				;���� ������ �� ���������� - ������� (���� ������ ��� ������� �� ������ ���������)
		brlo	WorkA				;���� RegAB ������ 128 - ������ �������� �
WorkB:								;����� ������ �������� �
		dec		RegLed				;�������� �
		clr		RegAB				;����� ���������� �������� ����������� ������� RegAB
		rjmp	Exit				;�������
WorkA:
		inc		RegLed				;�������� �
		clr		RegAB				;����� ���������� �������� ����������� ������� RegAB
Exit:								;�������
		rjmp	start				;���� � ������ �����

