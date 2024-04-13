.include"C:\tn2313def.inc"

;***************************** ����������� *************************

		.def		RegA=r18		;������� ����� �
		.def		RegB=r19		;������� ����� �

		.def		RegLed=r20		;��� �������� �������� ����� ����� ��������� �������� ��������
									;��� �������� �������� ������ ����� ����������� �������� ��������

;******************************** ������� ****************************

.macro OUTI
		ldi		r16,@1
		out		@0,r16
.endmacro

.macro	PUSHF
		push	r16
		in		r16,SREG
		push	r16
.endmacro

.macro	POPF
		pop		r16
		out		SREG,r16
		pop		R16
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
	 	rjmp TIMER0_COMPA ; Timer0 Compare A Handler
nop 	;rjmp TIMER0_COMPB ; Timer0 Compare B Handler
nop 	;rjmp USI_START ; USI Start Handler
nop 	;rjmp USI_OVERFLOW ; USI Overflow Handler
nop 	;rjmp EE_READY ; EEPROM Ready Handler
nop 	;rjmp Watchdog_Time_Out:


RESET:	ldi		r16,low(RAMEND)		;����������� ������ 
		out		SPL,r16				;����� � ���



		ser		r16
		out		DDRB,r16		;����� ����� B - ������
		clr		r16
		out		DDRD,r16		;����� ����� D - �����		
		out		PortB,r16

		OUTI	ACSR,0b10000000	;���������� ������� ��������� ����������� (ASD=1)
	
		OUTI	TIMSK,(1<<OCIE0A);��������� ���������� �� ��������� OCR0A � TCNT0
		OUTI	TCCR0A,(1<<WGM01);����� ���
		OUTI	TCCR0B,(1<<CS01)|(1<<CS00);�������� ������� ����� �� 64

		clr		r16
		clr		RegA
		clr		RegB			;������� ������ ��� ������ ��������
		ldi		RegLed,16
		
		OUTI	OCR0A,122		;� ����� ��������� OCR0A ���������� ���������� ����
								;��� � 1 ����������� ( ��� 1000 ��� � ������� ) �� �������
		sei						;�������� ��������� �������� ��� �� �����������, ������� 
								;���������� ������ ����� � ������ ( ��� � 10 �.�.10000��� � ���.)
start:
		out		PortB,RegLed		;���������� ��� � ��� � �������� RegLed ����� PortB		
		rjmp	start				;���� � ������ �����

TIMER0_COMPA:
		PUSHF
		in		r16,PinD			;��������� �������� ����� D � ������� 
		andi 	r16,0b00000011		;�������� ��� ��������� ���� R16
		cpi		RegA,0				;������� � ����� 0?
		brne	ScanEncoder			;���� ��� , ������ �� ����� ScanEncoder
		cpi		RegB,0				;� ������� � ����� 0?
		brne	ScanEncoder			;���� ���� ���, �� ������ �� ����� ScanEncoder
		cpi		r16,0				;�� ����� ������ 0?
		brne	Exit				;���� ��� , ������� ���
		ldi		RegA,1				;����� "�������" ��� �������� �� ������� ���������
		ldi		RegB,1				;�.�. � ��������� ��� ������ �� ������ ����� ���������
		rjmp	Exit				;�������� - �������
ScanEncoder:
		cpi		r16,3				;�� ����� ������ ������� ������� ?
		breq	GoWork				;���� �� , �� ����� �� ����������
		cpi		r16,1				;���? ����� ����� �� ������ ����� ���.�������
		brne	PC+3				;���� ��� �� ����� ��������� ������ �����
		inc		RegA				;����� ����������� �������� RegA �� �������
		rjmp	Exit				;� �������
		cpi		r16,2				;����� �� ������ ����� ���. �������?
		brne	PC+2				;���� ����� ���,������� ���
		inc		RegB				;����� ����������� �������� RegB �� �������
		rjmp	Exit				;�������
GoWork:	
		cp		RegA,RegB			;����������, ��� � ��� ��� ���������� � ���������
		breq	Exit				;���� �������� - ������� (���� ������ ��� ������� �� ������ ���������)
		brlo	WorkA				;���� RegA ������ RegB - ������ �������� �
WorkB:								;����� ������ �������� �
		dec		RegLed				;�������� �
		clr		RegA				;����� ���������� �������� ����������� �������
		clr		RegB				;������������ �������� � ����� ���������
		rjmp	Exit				;�������
WorkA:
		inc		RegLed				;�������� �
		clr		RegA				;����� ���������� �������� ����������� �������
		clr		RegB				;������������ �������� � ����� ���������
Exit:	
		POPF						;�������
		reti
