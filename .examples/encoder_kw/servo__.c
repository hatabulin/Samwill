/*****************************************************

CVAVR 1.25.9 Pro - скачать - http://www.roboforum.ru/viewtopic.php?f=2&t=1070

PROTEUS 7.4 sp3 - скачать - http://www.roboforum.ru/viewtopic.php?f=2&t=2398
Как работать в PROTEUS  www.proteus123.narod.ru/01.htm

Найти электронные компоненты - http://www.eFind.ru/

КНИГИ скачать - http://www.avr123.nm.ru

 *****************************************************


Project : SERVO controller

http://forums.airbase.ru/2008/11/t64517,5--Kobra-prodolzhenie.html

Version : 20081117-001  проверка счета квадратурного энкодера

Date    : 17.11.2008
Author  : avr123

Chip type           : ATtiny13
Clock frequency     : 9,600000 MHz
Memory model        : Tiny
External SRAM size  : 0
Data Stack size     : 16
****************************************************

_tn13_servo Описание проекта  2008-11-15

Контроллер для конвертации электро-актуатора замка автомобильной двери в линейный серво-привод
управляемый импульсами как серво у моделистов - частота повторений 10-25 мС.

http://forums.airbase.ru/2008/11/t64517,5--Kobra-prodolzhenie.html

Длина импульса 1500 мкС соответвует среднему положению штока актуатора.
А импульсы 1000 мкС и 2000 мкС - двум крайним положениям штока.

Обратная связь по положению штока - квадратурный энкодер на валу мотора - в диске 45 отв
и на полный ход штока приходится 4.5 оборотоа диска энкодера и вала мотора.

Микроконтроллер ATtiny13  частота внутреннего генератора  9.6 МГц

Питание 5 вольт подключено к выводам 4 (GND) и 8 (VCC) в 8 выводном корпусе.
Вывод 1(RESET) подключен резистором 10 кОМ к 8(VCC)
Выводы 1 и 8 подключены конденсаторами 0.1-0.22 мкФ к "земле" - 4 (GND).

Фототранзисторы "мышиного" фотоприемника квадратурного энкодера питаются от тех же 5 вольт,
а эммитеры их заземлены резисторами по 10 кОм и подключены на входы внешних прерываний PB3
и PB4 - условно назовем их "А" и "B".

Выход контроллера - это комплементарный (2 сигнала в противофазе на выводах PB0 и PB1) ШИМ
сигнал частотой 9600/256/2 = 18750 Гц   который подается на мощный мостовой драйвер.

ШИМ 50%  - момент мотора нулевой, ШИМ от 5 до 95 % - мотор создает
момент пропорциональный величине реальный ШИМ% - 50%.

Сигнал управления сервоприводом подается на вход PB2 через резистор 10 кОм.

При включении питания привод совершает движения до упора в одну и другую стороны чтобы
вычислить среднее положение и при отутствии сигнала управления становится в среднее положение.

Если сигнал управления пропадает более чем на 50 мС то привод плавно (300 мС примерно)
     становится в среднее положение.

===============

__  Входы ATtiny13

PB2 - сигнал управления.

PB3  "А" вход энкодера.
PB4  "B" вход энкодера.

Изменение сигнала на этих входах вызывает прерывание PCINT0 (стр 42 в ДШ)

__  ВЫходы  ATtiny13

PB0  и
PB1 ШИМ  частотой 18750 Гц на мощный мостовой драйвер.

==============

Программирование в CVAVR 1.25.9  а моделирование в PROTEUS

*/

#include <tiny13.h>
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x20
	.EQU __sm_mask=0x18
	.EQU __sm_adc_noise_red=0x08
	.EQU __sm_powerdown=0x10
	.SET power_ctrl_reg=mcucr
	#endif
#include <delay.h>

volatile char temp;         // служебная переменная
volatile char po_chasovoi = 1; // "1" - значит вращение по часовой
volatile char enc_ctr; // отсчеты энкодера - вращ. по часовой увеличивает.

bit cotrol_state = 0; // сигнал управл. серво подается на PB2

bit now_a; // сигнал на входе "А" энкодера PB3
bit now_b; // сигнал на входе "B" энкодера PB4

bit pre_a; // сигнал на входе "А" энкодера PB3
bit pre_b; // сигнал на входе "B" энкодера PB4

/* прерывание происходит при изменении сигнала
   на ножках PB2 PB3 PB4 - т.е. при изменении
   сигналов с энкодера или управления.

Pin change interrupt service routine */
interrupt [PCINT0] void pin_change_isr(void)
{
// Place your code here
// Проверим - не изменился ли управл сигнал ?
if (PINB.2 != cotrol_state) // если управл. сигнал изменился
{  cotrol_state = PINB.2;   // запомнить новое состояние сигнала
  if (cotrol_state) // если управл. сигнал стал "1" (не ноль)
  {
    // Запустить измерение длины управл. импульса.
    // и таймаут на длину менее 800 и более 2200 мкС.
  }
  else {
      // Запомнить измереную длину импульса и запустить
      // таймаут 50 мС до следующего импульса.
       }
}

/* Обработка сигналов с энкодера

 На 1 оборот диска энкодера будет столько отсчетов сколько отверстий
 в диске, т.е. частота счета будет равна чатоте сигнала A или B  */

 // запомнить текущее состояние сигналов энкодера.
 now_a = PINB.3; // сигнал на выходе "А" энкодера PB3
 now_b = PINB.4; // сигнал на выходе "B" энкодера PB4

 ADCSRA = 0; //debug  новое состояние выходов А и В в битах 1 и 0
 ADCSRA = (pre_a << 1)|(pre_b); //debug

 ADMUX = 0; //debug  новое состояние выходов А и В в битах 1 и 0
 ADMUX = (now_a << 1)|(now_b); //debug

 if ((pre_b != now_b)||(pre_a != now_a)) { // Если изменился сигнал А или В то
 /*  "+" тик (отсчет условно "по часовой") если выполняются 4 условия:      */
 if (!now_b){           // 1) В = 0
 if (now_a) {           // 2) A = 1
 if (now_a != pre_a){   // 3) A изменился
 if (now_b == pre_b){   // 4) B не изменился
     enc_ctr ++ ;               // посчитать тик "по часовой"
     po_chasovoi = 1; }}}}     // вращение происходит по-часовой
                                // ADMUX = enc_ctr; //debug
 /*  "-" тик (отсчет условно "против часовой") если выполняются 4 условия:   */
 if (now_b){            // 1) В = 1
 if (!now_a) {          // 2) A = 0
 if (now_a == pre_a){   // 3) A не изменился
 if (now_b != pre_b){   // 4) B изменился
     enc_ctr -- ;               // посчитать тик "против часовой"
     po_chasovoi = 0; }}}}}    // вращение происходит против-часовой
                                // ADMUX = enc_ctr; //debug
pre_a = now_a; // обновить "прошлые" сигналы энкодера
pre_b = now_b; }// для - interrupt [PCINT0] void pin_change_isr(void)

// Timer 0 overflow interrupt service routine
interrupt [TIM0_OVF] void timer0_ovf_isr(void)
{
// Place your code here


}

// Timer 0 output compare A interrupt service routine
interrupt [TIM0_COMPA] void timer0_compa_isr(void)
{
// Place your code here



}

// Timer 0 output compare B interrupt service routine
interrupt [TIM0_COMPB] void timer0_compb_isr(void)
{
// Place your code here


}

// =========================================================
void main(void)
{

#pragma optsize-
CLKPR=0x80;  // Crystal Oscillator division factor: 1
CLKPR=0x00;  // debug вставить в начало строки для PROTEUS 7.2 delay_us(10);
#ifdef _OPTIMIZE_SIZE_
#pragma optsize+
#endif

PORTB=0x00; // Port B initialization
DDRB=0x03;

// Timer/Counter 0 initialization
TCCR0A=0xB1; // Clock source: System Clock Clock value: 9600,000 kHz
TCCR0B=0x01; // Mode: Phase correct PWM top=FFh  18750 Гц период 53,(3) мкС
TCNT0=0x00;  // OC0A output: Non-Inverted PWM OC0B output: Inverted PWM
OCR0A=0x80;
OCR0B=0x80;

GIMSK=0x20; // External Interrupt(s) initialization
MCUCR=0x00; // INT0: Off
PCMSK=0x1C; // Interrupt on any change on pins PCINT0-5: On
GIFR=0x20;

TIMSK0=0x0E; // Timer/Counter 0 Interrupt(s) initialization

// Analog Comparator initialization
// Analog Comparator: Off
ACSR=0x80;
ADCSRB=0x00;

// запомнить текущее состояние сигналов с энкодера.
pre_a = PINB.3; // сигнал на выходе "А" энкодера PB3
pre_b = PINB.4; // сигнал на выходе "B" энкодера PB4

// Global enable interrupts
#asm("sei")

while (1)
      {
      // Place your code here

      };
}
