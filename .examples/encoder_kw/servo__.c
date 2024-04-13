/*****************************************************

CVAVR 1.25.9 Pro - ������� - http://www.roboforum.ru/viewtopic.php?f=2&t=1070

PROTEUS 7.4 sp3 - ������� - http://www.roboforum.ru/viewtopic.php?f=2&t=2398
��� �������� � PROTEUS  www.proteus123.narod.ru/01.htm

����� ����������� ���������� - http://www.eFind.ru/

����� ������� - http://www.avr123.nm.ru

 *****************************************************


Project : SERVO controller

http://forums.airbase.ru/2008/11/t64517,5--Kobra-prodolzhenie.html

Version : 20081117-001  �������� ����� ������������� ��������

Date    : 17.11.2008
Author  : avr123

Chip type           : ATtiny13
Clock frequency     : 9,600000 MHz
Memory model        : Tiny
External SRAM size  : 0
Data Stack size     : 16
****************************************************

_tn13_servo �������� �������  2008-11-15

���������� ��� ����������� �������-��������� ����� ������������� ����� � �������� �����-������
����������� ���������� ��� ����� � ���������� - ������� ���������� 10-25 ��.

http://forums.airbase.ru/2008/11/t64517,5--Kobra-prodolzhenie.html

����� �������� 1500 ��� ����������� �������� ��������� ����� ���������.
� �������� 1000 ��� � 2000 ��� - ���� ������� ���������� �����.

�������� ����� �� ��������� ����� - ������������ ������� �� ���� ������ - � ����� 45 ���
� �� ������ ��� ����� ���������� 4.5 �������� ����� �������� � ���� ������.

��������������� ATtiny13  ������� ����������� ����������  9.6 ���

������� 5 ����� ���������� � ������� 4 (GND) � 8 (VCC) � 8 �������� �������.
����� 1(RESET) ��������� ���������� 10 ��� � 8(VCC)
������ 1 � 8 ���������� �������������� 0.1-0.22 ��� � "�����" - 4 (GND).

��������������� "��������" ������������� ������������� �������� �������� �� ��� �� 5 �����,
� �������� �� ��������� ����������� �� 10 ��� � ���������� �� ����� ������� ���������� PB3
� PB4 - ������� ������� �� "�" � "B".

����� ����������� - ��� ��������������� (2 ������� � ����������� �� ������� PB0 � PB1) ���
������ �������� 9600/256/2 = 18750 ��   ������� �������� �� ������ �������� �������.

��� 50%  - ������ ������ �������, ��� �� 5 �� 95 % - ����� �������
������ ���������������� �������� �������� ���% - 50%.

������ ���������� ������������� �������� �� ���� PB2 ����� �������� 10 ���.

��� ��������� ������� ������ ��������� �������� �� ����� � ���� � ������ ������� �����
��������� ������� ��������� � ��� ��������� ������� ���������� ���������� � ������� ���������.

���� ������ ���������� ��������� ����� ��� �� 50 �� �� ������ ������ (300 �� ��������)
     ���������� � ������� ���������.

===============

__  ����� ATtiny13

PB2 - ������ ����������.

PB3  "�" ���� ��������.
PB4  "B" ���� ��������.

��������� ������� �� ���� ������ �������� ���������� PCINT0 (��� 42 � ��)

__  ������  ATtiny13

PB0  �
PB1 ���  �������� 18750 �� �� ������ �������� �������.

==============

���������������� � CVAVR 1.25.9  � ������������� � PROTEUS

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

volatile char temp;         // ��������� ����������
volatile char po_chasovoi = 1; // "1" - ������ �������� �� �������
volatile char enc_ctr; // ������� �������� - ����. �� ������� �����������.

bit cotrol_state = 0; // ������ ������. ����� �������� �� PB2

bit now_a; // ������ �� ����� "�" �������� PB3
bit now_b; // ������ �� ����� "B" �������� PB4

bit pre_a; // ������ �� ����� "�" �������� PB3
bit pre_b; // ������ �� ����� "B" �������� PB4

/* ���������� ���������� ��� ��������� �������
   �� ������ PB2 PB3 PB4 - �.�. ��� ���������
   �������� � �������� ��� ����������.

Pin change interrupt service routine */
interrupt [PCINT0] void pin_change_isr(void)
{
// Place your code here
// �������� - �� ��������� �� ������ ������ ?
if (PINB.2 != cotrol_state) // ���� ������. ������ ���������
{  cotrol_state = PINB.2;   // ��������� ����� ��������� �������
  if (cotrol_state) // ���� ������. ������ ���� "1" (�� ����)
  {
    // ��������� ��������� ����� ������. ��������.
    // � ������� �� ����� ����� 800 � ����� 2200 ���.
  }
  else {
      // ��������� ��������� ����� �������� � ���������
      // ������� 50 �� �� ���������� ��������.
       }
}

/* ��������� �������� � ��������

 �� 1 ������ ����� �������� ����� ������� �������� ������� ���������
 � �����, �.�. ������� ����� ����� ����� ������ ������� A ��� B  */

 // ��������� ������� ��������� �������� ��������.
 now_a = PINB.3; // ������ �� ������ "�" �������� PB3
 now_b = PINB.4; // ������ �� ������ "B" �������� PB4

 ADCSRA = 0; //debug  ����� ��������� ������� � � � � ����� 1 � 0
 ADCSRA = (pre_a << 1)|(pre_b); //debug

 ADMUX = 0; //debug  ����� ��������� ������� � � � � ����� 1 � 0
 ADMUX = (now_a << 1)|(now_b); //debug

 if ((pre_b != now_b)||(pre_a != now_a)) { // ���� ��������� ������ � ��� � ��
 /*  "+" ��� (������ ������� "�� �������") ���� ����������� 4 �������:      */
 if (!now_b){           // 1) � = 0
 if (now_a) {           // 2) A = 1
 if (now_a != pre_a){   // 3) A ���������
 if (now_b == pre_b){   // 4) B �� ���������
     enc_ctr ++ ;               // ��������� ��� "�� �������"
     po_chasovoi = 1; }}}}     // �������� ���������� ��-�������
                                // ADMUX = enc_ctr; //debug
 /*  "-" ��� (������ ������� "������ �������") ���� ����������� 4 �������:   */
 if (now_b){            // 1) � = 1
 if (!now_a) {          // 2) A = 0
 if (now_a == pre_a){   // 3) A �� ���������
 if (now_b != pre_b){   // 4) B ���������
     enc_ctr -- ;               // ��������� ��� "������ �������"
     po_chasovoi = 0; }}}}}    // �������� ���������� ������-�������
                                // ADMUX = enc_ctr; //debug
pre_a = now_a; // �������� "�������" ������� ��������
pre_b = now_b; }// ��� - interrupt [PCINT0] void pin_change_isr(void)

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
CLKPR=0x00;  // debug �������� � ������ ������ ��� PROTEUS 7.2 delay_us(10);
#ifdef _OPTIMIZE_SIZE_
#pragma optsize+
#endif

PORTB=0x00; // Port B initialization
DDRB=0x03;

// Timer/Counter 0 initialization
TCCR0A=0xB1; // Clock source: System Clock Clock value: 9600,000 kHz
TCCR0B=0x01; // Mode: Phase correct PWM top=FFh  18750 �� ������ 53,(3) ���
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

// ��������� ������� ��������� �������� � ��������.
pre_a = PINB.3; // ������ �� ������ "�" �������� PB3
pre_b = PINB.4; // ������ �� ������ "B" �������� PB4

// Global enable interrupts
#asm("sei")

while (1)
      {
      // Place your code here

      };
}
