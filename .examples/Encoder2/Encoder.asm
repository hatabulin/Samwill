.include "m32Adef.inc"
.def     Temp=R16
.def     NewState=R17 ///Сюда записываем новое состояние 
					  ///пинов на которых висит энкодер
.def     OldState=R18 //Тут хранится состояние пинов  
					  //предыдущего опроса 

.def     Count=R20  //Перменная счётчик

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
rjmp Scan; TIM0_COMP ; Timer0 Compare Handler <--------Вызываем процедуру сканирования
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
/////////////////////Инициализация стека ////////
ldi Temp,high(RamEnd)
out SPH,Temp
ldi Temp,low(RamEnd)
out SPL,Temp
///////////////////////////////////////

clr OldState
ldi temp,255
out DDRC,temp //К этому порту подцеплены светодиоды 8 шт.
ldi temp,1     //Зажгём первый светодиод
out PORTC,temp  //зажгли
ldi count,0

///////////Инициализация таймера////////
ldi temp,0b00000010 //Настраиваем таймер так 
out TCCR0,temp		//чтоб прерывание срабатывало 
ldi temp,0b00000010 //с частотой примерно 1000 раз в секунду (частота мк 1мГц)
out TIMSK,temp      //чаще опрашивать энкодер смысла нет
ldi temp,0x8A       //это может только создать дополнительные проблемы
out OCR0,temp		//в виде дребезга
/////////////////////////////////////////
sei


//////Бесконечный цикл//
Begin:
rjmp Begin
////////////////////////



///////////////////процедура сканирования энкодера//////////////////////////
Scan:
IN NewState,PINB //Читаем порт к которому подключен энкодер
cbr NewState,0b11111100 //Зануляем ненужные биты. (все кроме первых двух)
				  ///BA
//Пины энкодера могут находится в 4- состояниях:
//1) Оба пина при прошлом опросе были равны нулю ? 
Cpi OldState,0 
brne Cpi1 //Если нет то проверяем другое условие
	Cpi NewState,2
	brne Cpi11
	Rcall RightShift
	Cpi11:
	Cpi NewState,1
	brne Cpi12
	rcall LeftShift
	Cpi12:
	mov OldState,NewState //То что было новым состоянием энкодера, стало старым...
reti
Cpi1:
//2) При прошлом опросе Пин А=1  и  Пин В=0 ? 
Cpi OldState,1
brne Cpi2 //Если нет то проверяем другое условие
	Cpi NewState,0 //
	brne Cpi21
	Rcall RightShift
	Cpi21:
	Cpi NewState,3
	brne Cpi22
	rcall LeftShift
	Cpi22:
	mov OldState,NewState //То что было новым состоянием энкодера, стало старым...
reti
Cpi2:
//3 ) При прошлом опросе  Пин В=1 и  Пин А=0 ?
Cpi OldState,2
brne Cpi3 //Если нет то проверяем другое условие
	Cpi NewState,3
	brne Cpi31
	Rcall RightShift
	Cpi31:
	Cpi NewState,0
	brne Cpi12
	rcall LeftShift
	Cpi32:
	mov OldState,NewState //То что было новым состоянием энкодера, стало старым...
reti
Cpi3:
///4) При прошлом опросе Оба пина=1 ? 
Cpi OldState,3
Brne Cpi4 //Если нет то выходим из процедуры сканирования
	Cpi NewState,1
	brne Cpi41
	Rcall RightShift
	Cpi41:
	Cpi NewState,2
	brne Cpi42
	rcall LeftShift
	Cpi42:
	mov OldState,NewState //То что было новым состоянием энкодера, стало старым...
Cpi4:
reti

////////////////////////////////////////////////////////////////

LeftShift:
	cpi count,4 //Состояние пинов сменилось 4 раза? 
	brne exitLS
	///////Здесь можно вставить свой код////////////
	//////Который будет срабатывать если крутим в лево///
	//////В демонстрационном примере мы двигаем огонек=) 
	clr count
	in temp,portc
	cpi temp,0b10000000
	breq exitLS2
	lsl temp
	out PORTC,temp
	//////////////////КОНЕЦ СВОЕГО КОДА/////////////
	brne exitLS
	exitLS:
	inc count
	exitLS2:
ret

RightShift:
	cpi count,4 //Состояние пинов сменилось 4 раза? 
	brne exitRS
	///////Здесь можно вставить свой код////////////
	//////Который будет срабатывать если крутим в право///
	//////В демонстрационном примере мы двигаем огонек=) 
	clr count
	in temp,portc
	cpi temp,0b00000001
	breq exitRS2
	lsr temp
	out PORTc,temp
	//////////////////КОНЕЦ СВОЕГО КОДА/////////////
	brne exitRS
	exitRS:
	inc count
	exitRS2:
ret
