.include"C:\tn2313def.inc"

;***************************** Определения *************************

		.def		RegA=r18		;регистр линии А
		.def		RegB=r19		;регистр линии В

		.def		RegLed=r20		;при повороте энкодера влево будем уменьшать значение регистра
									;при повороте энкодера вправо будем увеличивать значение регистра

;******************************** Макросы ****************************

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

;******************************** ОЗУ ************************************
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


RESET:	ldi		r16,low(RAMEND)		;Определение начала 
		out		SPL,r16				;стека в ОЗУ



		ser		r16
		out		DDRB,r16		;Линии порта B - выходы
		clr		r16
		out		DDRD,r16		;Линии порта D - входы		
		out		PortB,r16

		OUTI	ACSR,0b10000000	;Отключение питания аналогова компоратора (ASD=1)
	
		OUTI	TIMSK,(1<<OCIE0A);разрешаем прерывание по сравнению OCR0A и TCNT0
		OUTI	TCCR0A,(1<<WGM01);режим СТС
		OUTI	TCCR0B,(1<<CS01)|(1<<CS00);Исходную частоту делим на 64

		clr		r16
		clr		RegA
		clr		RegB			;очищаем нужные для работы регистры
		ldi		RegLed,16
		
		OUTI	OCR0A,122		;С таким значением OCR0A прерывания происходят один
								;раз в 1 милисекунду ( или 1000 раз в секунду ) со слишком
		sei						;большими оборотами энкодера уже не справляется, поэтому 
								;опрашивать датчик можно и почаще ( раз в 10 т.е.10000раз в сек.)
start:
		out		PortB,RegLed		;показываем что у нас в регистре RegLed через PortB		
		rjmp	start				;идем в начало цикла

TIMER0_COMPA:
		PUSHF
		in		r16,PinD			;загружаем значение порта D в регистр 
		andi 	r16,0b00000011		;выделить два последних бита R16
		cpi		RegA,0				;регистр А равен 0?
		brne	ScanEncoder			;если нет , уходим на метку ScanEncoder
		cpi		RegB,0				;а регистр В равен 0?
		brne	ScanEncoder			;если тоже нет, то уходим на метку ScanEncoder
		cpi		r16,0				;на обоих портах 0?
		brne	Exit				;если нет , выходим нах
		ldi		RegA,1				;иначе "взводим" наш алгоритм на подсчет импульсов
		ldi		RegB,1				;т.е. в следующий раз пойдем по другой ветви алгоритма
		rjmp	Exit				;зарядили - выходим
ScanEncoder:
		cpi		r16,3				;на обоих линиях высокий уровень ?
		breq	GoWork				;если да , то пошли их сравнивать
		cpi		r16,1				;нет? тогда может на первой линии лог.единица
		brne	PC+3				;если нет то пошли проверять вторую линию
		inc		RegA				;иначе увеличиваем значение RegA на единицу
		rjmp	Exit				;и выходим
		cpi		r16,2				;может на второй линии лог. единица?
		brne	PC+2				;если опять нет,выходим нах
		inc		RegB				;иначе увеличиваем значение RegB на единицу
		rjmp	Exit				;выходим
GoWork:	
		cp		RegA,RegB			;сравниваем, что у нас там накопилось в регистрах
		breq	Exit				;если регистры - выходим (хотя такого мне кажется не должно случиться)
		brlo	WorkA				;если RegA меньше RegB - делаем действие А
WorkB:								;иначе делаем действие В
		dec		RegLed				;ДЕЙСТВИЕ В
		clr		RegA				;после выполнения действия ОБЯЗАТЕЛЬНО очищаем
		clr		RegB				;подсчитанные импульсы в обоих регистрах
		rjmp	Exit				;выходим
WorkA:
		inc		RegLed				;ДЕЙСТВИЕ А
		clr		RegA				;после выполнения действия ОБЯЗАТЕЛЬНО очишаем
		clr		RegB				;подсчитанные импульсы в обоих регистрах
Exit:	
		POPF						;выходим
		reti
