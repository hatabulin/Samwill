.include"C:\tn2313def.inc"

;***************************** Определения *************************

		.def		RegAB=r19		;регистр подсчета состояний энкодера

		.def		RegLed=r20		;при повороте энкодера влево будем уменьшать значение регистра
									;при повороте энкодера вправо будем увеличивать значение регистра

;******************************** Макросы ****************************

.macro OUTI
		ldi		r16,@1
		out		@0,r16
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
nop 	;rjmp TIMER0_COMPA ; Timer0 Compare A Handler
nop 	;rjmp TIMER0_COMPB ; Timer0 Compare B Handler
nop 	;rjmp USI_START ; USI Start Handler
nop 	;rjmp USI_OVERFLOW ; USI Overflow Handler
nop 	;rjmp EE_READY ; EEPROM Ready Handler
nop 	;rjmp Watchdog_Time_Out:


RESET:	ldi		r16,low(RAMEND)		;Определение начала 
		out		SPL,r16				;стека в ОЗУ



		ser		r16
		out		DDRB,r16			;Линии порта B - выходы
		clr		r16
		out		DDRD,r16			;Линии порта D - входы		
		out		PortB,r16

		OUTI	ACSR,0b10000000		;Отключение питания аналогова компоратора (ASD=1)
	
		clr		r16
		clr		RegAB				;очищаем нужные для работы регистры
		ldi		RegLed,16
		

start:
		out		PortB,RegLed		;показываем что у нас в регистре RegLed через PortB

		in		r16,PinD			;загружаем значение порта D в регистр 
		andi 	r16,0b00000011		;выделить два последних бита R16
		cpi		RegAB,0				;регистр RegAB равен 0?
		brne	ScanEncoder			;если нет , уходим на метку ScanEncoder
		cpi		r16,0				;на обоих портах 0?
		brne	Exit				;если нет , выходим нах
		ldi		RegAB,128			;иначе "взводим" наш алгоритм на подсчет импульсов
		rjmp	Exit				;т.е. в следующий раз пойдем по другой ветви алгоритма
ScanEncoder:
		cpi		r16,3				;на обоих линиях высокий уровень ?
		breq	GoWork				;если да , то пошли их сравнивать
		cpi		r16,1				;нет? тогда может на первой линии лог.единица
		brne	m1					;если нет то пошли проверять вторую линию
		inc		RegAB				;иначе увеличиваем значение RegA на единицу
		cpi		RegAB,250			;подстраховываемся от переполнения и если досчитали
		brsh	WorkA				;до 250,значит полюбому было вращение в сторону А
		rjmp	Exit				;и выходим
m1:		cpi		r16,2				;может на второй линии лог. единица?
		brne	m2					;если опять нет,выходим нах
		dec		RegAB				;иначе увеличиваем значение RegB на единицу
		cpi		RegAB,5				;подстраховываемся от переполнения и если досчитали
		brlo	WorkB				;до 5,значит полюбому было вращение в сторону В
m2:		rjmp	Exit				;выходим
GoWork:	
		cpi		RegAB,128			;сравниваем, что у нас там накопилось в регистре
		breq	Exit				;если ничего не изменилось - выходим (хотя такого мне кажется не должно случиться)
		brlo	WorkA				;если RegAB меньше 128 - делаем действие А
WorkB:								;иначе делаем действие В
		dec		RegLed				;ДЕЙСТВИЕ В
		clr		RegAB				;после выполнения действия ОБЯЗАТЕЛЬНО очищаем RegAB
		rjmp	Exit				;выходим
WorkA:
		inc		RegLed				;ДЕЙСТВИЕ А
		clr		RegAB				;после выполнения действия ОБЯЗАТЕЛЬНО очищаем RegAB
Exit:								;выходим
		rjmp	start				;идем в начало цикла

