
    ////////////////////////////////////////////////////////////////////
//
// <NAME PROJECT WITH MORE INFO>
// 
// Name:		Hatab Samwill
// Version:		2.0 
// Project started:	16.03.2013: 
// Project ended::
// 
// version 1 - 
// build: 160313
// 
// EEPROM 24c64 - 64Kbit (8 Kbytes)
// OSCILLATOR 24Mhz on p0.2, p0.3
//
// ������� 1-2 �� �� 20 ��
// ��� "��������" � ���������
//
#define VERSION1 	// ������ �����: 
					// ------------
					// 1.0 - ������ ����
					// 2.0 - 
					// 3.0 - 
					// 3.1 - 
					// 3.2 - 
#define ALGO3
#define DEFAULT_DISCRET		100;
#define EEPROM_24C128
#define REVISION_VER_DIGIT1 0x01 // ������ ��������
#define REVISION_VER_DIGIT2 0x00

#define EncA    2
#define EncB    3
#define EncSw   6
#define EncIN   P0
#define EncPort P0
#define EncMask ((1<<EncB)|(1<<EncA)|(1<<EncSw))

#include "compiler_defs.h"
#include "C8051f340_defs.h"
//#include "C8051f340.h"
#include "USB_API.h"
#include <math.h>
#include <string.h>

#define INTERRUPT_USBXpress 17
//#define _GENERATOR_MODE_ON_OFF_ ~state
//////////////////////////////////////////////////////
///
///            PORT PINS CONFIGURATIONS (Defines)
/// 
//////////////////////////////////////////////////////
// 
// PINS
// 
sbit EEPROM_SDA 			= P0^0;
sbit EEPROM_SCL 			= P0^1;

#ifdef VERSION1
sbit KEY_RESET				= P2^2;
sbit KEY_INCREMENT			= P2^4;
sbit KEY_MODE 				= P2^3;
sbit KEY_STORE				= P2^1;

sbit SEGMENT_A				= P1^6;
sbit SEGMENT_B				= P1^5;
sbit SEGMENT_C				= P1^1;
sbit SEGMENT_D				= P1^3;
sbit SEGMENT_E				= P1^4;
sbit SEGMENT_F				= P1^7;
sbit SEGMENT_G				= P1^2;
sbit SEGMENT_POINT			= P1^0;

sbit LED1					= P2^0;
sbit LED2					= P0^5;
sbit LED3					= P0^7;
sbit LED4					= P0^6;

sbit EXT_INT0				= P0^4;
sbit EXT_INT1				= P0^5;
#endif

//
// ������ ������� EEPROM
//
#define EEPROM_TEST_ADDR1 					0x00
#define EEPROM_TEST_ADDR2 					0x01
#define EEPROM_CONST_ADDR					0x02
#define EEPROM_RESET_COUNTER_ADDR			0x03
#define EEPROM_COUNTER_ADDR_LOW				0x04
#define EEPROM_COUNTER_ADDR_HIGH			0x05
#define EEPROM_LCDMODE_ADDR					0x10
#define EEPROM_DISCRET_ADDR_LOW				0x20
#define EEPROM_DISCRET_ADDR_HIGH			0x21

// Device addresses (7 bits, lsb is a don't care)
#define  SYSCLK         12000000
#define  SMB_FREQUENCY  40000          // Target SCL clock rate
                                       // This example supports between 10kHz
                                       // and 100kHz

#define  WRITE          0x00           // SMBus WRITE command
#define  READ           0x01           // SMBus READ command
#define  EEPROM_ADDR    0xA0           // Device address for slave target
                                       // Note: This address is specified
                                       // in the Microchip 24LC02B
                                       // datasheet.
#define  TARGET			0xA0           // Target SMBus slave address


// SMBus Buffer Size
#define  SMB_BUFF_SIZE  0x08           // Defines the maximum number of bytes
                                       // that can be sent or received in a
                                      // single transfer
// Status vector - top 4 bits only
#define  SMB_MTSTA      0xE0           // (MT) start transmitted
#define  SMB_MTDB       0xC0           // (MT) data byte transmitted
#define  SMB_MRDB       0x80           // (MR) data byte received
//
// ..
#define TIMER0_RELOAD_HIGH 0xF8
#define TIMER0_RELOAD_LOW  0xF8

//--------------------------TIMER DEFINITIONS ------
#define TIMER_PRESCALER           32  //48  // Based on Timer CKCON settings

#define TIMER_TICKS_PER_MS  SYSCLK/TIMER_PRESCALER/1500 //1000

#define AUX1     TIMER_TICKS_PER_MS
#define AUX2     -AUX1

#define READ_TEMP_COUNT 255
#define Timer0_Rate 10
#define Timer0_RateEncoder 5
//
// SYSCLK/SMB_FREQUENCY/4/3) < 255)
//---------------------------------------------------------

// Prototypes
//
void Initialize(void);
void Timer0_Init(void);
void Timer1_Init(void);
void Timer3_Init(void);
void Timer3_ISR(void);
void Timer0_ISR(void);
void OSCILLATOR_Init (void);
void Ext_Interrupt_Init (void);
void Port_Init(void);
void SMBus_Init (void);
void SMBus_ISR(void);
//
// ������� ����������� ���� ������������
void EEPROM_ByteWrite(U16 addr, unsigned char dat);
unsigned char EEPROM_ByteRead(U16 addr);
void LedsSwitchOff(void);
void OutSymbol(unsigned char , unsigned char);
void WriteCounterToEEprom(void);
void WriteDiscretToEEprom(void);
void LcdOutputLine(unsigned char);
//
void ResetCounterToOutputBuffer(void);
void OutputBufferToResetCounter(void);
//
void Del_10mks(void);
void Del_25ms(void);
void Del_100ms(void);
void Del_500mks(void);
void Del_10ms(void);
void Del(int);
////////////////////////////
////////////////////////////
// GLOBAL ���������� !!!
////////////////////////////
unsigned char Flag = 0;
unsigned long Counter = 0, TempCounter, Discret ;
bit Flag1 = 1;
bit FlagPoint = 0;
bit KeyFlag1 = 0;
bit KeyFlag2 = 0;
bit KeyFlag3 = 0;
bit KeyFlag4 = 0;
bit LongKeyFlag = 0;
unsigned int LongKeyFlagCounter = 0;
unsigned char LcdMode = 0;
//unsigned int Discret = 0;
unsigned char EncData, EncState, OldState, EncTemp;
unsigned char EncN = 0, EncOld[4] = {0, 0, 1, 0};
unsigned char Step,Low,High;
bit Rotate;

bit now_a, now_b, pre_a, pre_b;

static unsigned char New, EncPlus, EncMinus;//���������� ������ �������� ��������, ������������� ���������� + � -

//
// �������
//
unsigned char data	OutputBuffer[6];
unsigned char data	In_Packet[10];

//unsigned char waveform[256];
//
// ���������� ��� ������� ������ � EEPROM

unsigned char* pSMB_DATA_IN;           // Global pointer for SMBus data
                                       // All receive data is written here

unsigned char SMB_SINGLEBYTE_OUT;      // Global holder for single byte writes.

unsigned char* pSMB_DATA_OUT;          // Global pointer for SMBus data.
                                       // All transmit data is read from here

unsigned char SMB_DATA_LEN;            // Global holder for number of bytes
                                       // to send or receive in the current
                                       // SMBus transfer.

unsigned char WORD_ADDR_HIGH;               // Global holder for the EEPROM word
                                       // address that will be accessed in
                                       // the next transfer

unsigned char WORD_ADDR_LOW;

bit SMB_BUSY = 0;                      // Software flag to indicate when the
                                       // EEPROM_ByteRead() or
                                       // EEPROM_ByteWrite()
                                       // functions have claimed the SMBus

bit SMB_RW;                            // Software flag to indicate the
                                       // direction of the current transfer

bit SMB_SENDWORDADDR_LOW;                  // When set, this flag causes the ISR
                                       // to send the 8-bit <WORD_ADDR>
                                       // after sending the slave address.
bit SMB_SENDWORDADDR_HIGH;

bit SMB_RANDOMREAD;                    // When set, this flag causes the ISR
                                       // to send a START signal after sending
                                       // the word address.
                                       // For the 24LC02B EEPROM, a random read
                                       // (a read from a particular address in
                                       // memory) starts as a write then
                                       // changes to a read after the repeated
                                       // start is sent. The ISR handles this
                                       // switchover if the <SMB_RANDOMREAD>
                                       // bit is set.

bit SMB_ACKPOLL;                       // When set, this flag causes the ISR
                                       // to send a repeated START until the
                                       // slave has acknowledged its address

/*** [BEGIN] USB Descriptor Information [BEGIN] ***/

SEGMENT_VARIABLE(USB_VID, U16, SEG_CODE) = 0x10c4;
SEGMENT_VARIABLE(USB_PID, U16, SEG_CODE) = 0xea61;
SEGMENT_VARIABLE(USB_MfrStr[], char , SEG_CODE) = // Manufacturer String
{
   0x1A,
   0x03,
   'H',0,
   'a',0,
   't',0,
   'a',0,
   'b',0,
   '@',0,
   'C',0,
   'o',0,
   ' ',0

};
SEGMENT_VARIABLE(USB_ProductStr[], unsigned char , SEG_CODE) = // Product Desc. String
{
   0x10,
   0x03,
   'H',0,
   'a',0,
   't',0,
   'S',0,
   'a',0,
   'm',0,
   'w',0,
   'i',0,
   'l',0,
   'l',0
};

SEGMENT_VARIABLE(USB_SerialStr[], unsigned char , SEG_CODE) = // Serial Number String
{
   0x0A,
   0x03,
   '0',0,
   '0',0,
   '0',0,
   '1',0,
};

SEGMENT_VARIABLE(USB_MaxPower, unsigned char , SEG_CODE) = 15;    // Max current = 30 mA
                                                      // (15 * 2)
SEGMENT_VARIABLE(USB_PwAttributes, unsigned char , SEG_CODE) = 0x80;    // Bus-powered,
                                                          // remote wakeup not
                                                         // supported
SEGMENT_VARIABLE(USB_bcdDevice, U16, SEG_CODE) = 0x0100;    // Device release
                                                            // number 1.00

SEGMENT_VARIABLE(DEVICE_NAME_Str[], unsigned char , SEG_CODE) = // Serial Number String
{'H','a','t','S','a','m' };
SEGMENT_VARIABLE(DEVICE_SN_Str[], unsigned char , SEG_CODE) = { 1,2,3,4 };
SEGMENT_VARIABLE(LCD_STRING[], unsigned char, SEG_CODE) = {'-','-','-','-','-','-'};
/*** [ END ] USB Descriptor Information [ END ] ***/

#define ERROR_EEPROM 1

void main(void)
{
	unsigned char i;
	bit UpDown = 0;
	long	temp;
	PCA0MD &= ~0x40;                       // Disable Watchdog timer
	Initialize();

//	USB_Clock_Start();                     // Init USB clock *before* calling USB_Init
//	USB_Init(USB_VID,USB_PID,USB_MfrStr,USB_ProductStr,USB_SerialStr,USB_MaxPower,USB_PwAttributes,USB_bcdDevice);
	
//	USB_Int_Enable();

// If slave is holding SDA low because of an improper SMBus reset or error
 	
//	while (1)

	LedsSwitchOff();
	
	SEGMENT_A = 1;
	LED1 = 0;

//	while (1);
	while(!EEPROM_SDA)
   	{

  // Provide clock pulses to allow the slave to advance out
      // of its current state. This will allow it to release SDA.
		XBR1 = 0x40;                     // Enable Crossbar
    	EEPROM_SCL = 0;                  // Drive the clock low
    	for (i = 0; i < 255; i++) {  } // Hold the clock low
    	EEPROM_SCL = 1; ;//                 // Release the clock
    	while(!EEPROM_SCL);// { }//;              // Wait for open-drain
                                       	 // clock output to rise
    	for(i = 0; i < 10; i++);         // Hold the clock high

		XBR1 = 0x00;                     // Disable Crossbar
   	}
	SEGMENT_A = 0;
	LED1 = 1;

	EIE1 |= 0x01;                       // Enable the SMBus interrupt
	EA = 1;
	ET0 = 1; // Timer0

	LcdOutputLine(5);

	ResetCounterToOutputBuffer();

// ���������� �������� ������ <HARD_RESET>
	if (OutputBuffer[0] < 0xFF) OutputBuffer[0]++;
	else 
	{ 
		OutputBuffer[0] = 0; 
		if (OutputBuffer[1] < 0xFF) OutputBuffer[1]++;
		else
		{
			OutputBuffer[1] = 0;
			if (OutputBuffer[2] < 0xFF) OutputBuffer[2]++;
			else
			{
				OutputBuffer[2] = 0;
				if (OutputBuffer[3] < 0xFF) OutputBuffer[3]++;
			}
		}
	}
	OutputBufferToResetCounter();

	LcdOutputLine(5);
//	SoftReset(SOFT_RESET);

	Counter = 0;
	Counter = EEPROM_ByteRead(EEPROM_COUNTER_ADDR_HIGH);
	Counter = Counter<<8;
	Counter |= EEPROM_ByteRead(EEPROM_COUNTER_ADDR_LOW);
	
	Discret = 0;
	Discret = EEPROM_ByteRead(EEPROM_DISCRET_ADDR_HIGH);
	Discret = Discret <<8;
	Discret |= EEPROM_ByteRead(EEPROM_DISCRET_ADDR_LOW);

	LcdMode = EEPROM_ByteRead(EEPROM_LCDMODE_ADDR);

	if (LcdMode >1) { LcdMode = 0; LcdOutputLine(1); EEPROM_ByteWrite(EEPROM_LCDMODE_ADDR,LcdMode); }
	while (1) 
	{
//	if (Counter > 39000) Counter = 39000;
//	EncoderScan5();
	FlagPoint = 0;

	switch (LcdMode)
	{
	case 0:
		{
			TempCounter = Counter & 0xFFFF;
			if (TempCounter > 999) 
			{
				temp = TempCounter / 1000;
				OutputBuffer[0] = temp;
				TempCounter = TempCounter - temp*1000;
			} else OutputBuffer[0] = 0;

			if (TempCounter > 99) 
			{
				temp = TempCounter / 100;
				OutputBuffer[1] = temp;
				TempCounter = TempCounter - temp*100;
			} else OutputBuffer[1] = 0;

			if (TempCounter > 9) 
			{
				temp = TempCounter / 10;
				OutputBuffer[2] = temp;
				TempCounter = TempCounter - temp*10;
			} else OutputBuffer[2] = 0;
			OutputBuffer[3] = TempCounter ;
		} break;
	case 1:
		{
			TempCounter = (Counter / Discret);
			if (TempCounter > 999) 
			{
				temp = TempCounter / 1000;
				OutputBuffer[0] = temp;
				TempCounter = TempCounter - temp*1000;
			} else OutputBuffer[0] = 0;

			if (TempCounter > 99) 
			{
				temp = TempCounter / 100;
				OutputBuffer[1] = temp;
				TempCounter = TempCounter - temp*100;
			} else OutputBuffer[1] = 0;
			if (TempCounter > 9) 
			{
				temp = TempCounter / 10;
				OutputBuffer[2] = temp;
				TempCounter = TempCounter - temp*10;
			} else OutputBuffer[2] = 0;
			OutputBuffer[3] = TempCounter ;
		} break;
	}


	if ((KEY_RESET == 0) & (LongKeyFlag == 0)) 
	{
		LongKeyFlagCounter++;
		if (LongKeyFlagCounter > 1000) 
		{ 
			LongKeyFlag = 1;
			LongKeyFlagCounter = 0;
		} 
	}

	if (KEY_INCREMENT == 0) 
	{
		if ((KeyFlag1 == 0) | (LongKeyFlag == 1))
		{
			Counter ++;
			KeyFlag1 = 1; 
		}
	} else { KeyFlag1 = 0; LongKeyFlag = 0; }

	if (KEY_RESET == 0) Counter = 0;

	if (KEY_MODE == 0)  // ����� ������ ������ �� ������� (�� ��� ������� ��������)
	{
		if (KeyFlag3 == 0)
		{
			if (LcdMode == 0) LcdMode = 1; else LcdMode = 0;
			LcdOutputLine(2);
			EEPROM_ByteWrite(EEPROM_LCDMODE_ADDR,LcdMode);
			KeyFlag3 = 1;
		}
	} else KeyFlag3 = 0;

	if (KEY_STORE == 0) // ������ � ������ EEPROM ������������� (�������/1 ��)
	{
		if (KeyFlag4 == 0)
		{
			Discret = Counter;
			LcdOutputLine(4);
			WriteDiscretToEEprom();
			WriteCounterToEEprom();
			KeyFlag4 = 1;
		} else KeyFlag4 = 0;
	}

	}
}

void LcdOutputLine(unsigned char delay)
{
	unsigned char i,y;
	TCON &= ~0x10;
	ET0 = 0;
	
	LedsSwitchOff();
	SEGMENT_G = 1;
	
	for (i=0;i<6;i++)
	{
		for (y=0;y<delay*2;y++) { Del_500mks();Del_500mks();Del_500mks();Del_500mks();}
		switch (i)
		{
			case 0: LED1 = 0; break;
			case 1: LED2 = 0; break;
			case 2: LED3 = 0; break;
			case 3: LED4 = 0; break;
		}	
	}
	ET0 = 1;
	TCON |= 0x10;
}

void WriteCounterToEEprom(void)
{
	unsigned char temp_byte;
	temp_byte = Counter;
	EEPROM_ByteWrite(EEPROM_COUNTER_ADDR_LOW, temp_byte);
	temp_byte = Counter>>8;
	EEPROM_ByteWrite(EEPROM_COUNTER_ADDR_HIGH,temp_byte);

	LedsSwitchOff();
	LcdOutputLine(2);
}

void WriteDiscretToEEprom(void)
{
	unsigned char temp_byte;
	
	if (Discret == 0) Discret = DEFAULT_DISCRET;
	temp_byte = Discret;
	EEPROM_ByteWrite(EEPROM_DISCRET_ADDR_LOW, temp_byte);
	temp_byte = Discret>>8;
	EEPROM_ByteWrite(EEPROM_DISCRET_ADDR_HIGH,temp_byte);

	LedsSwitchOff();
	LcdOutputLine(2);
}

void ResetCounterToOutputBuffer(void)
{
	OutputBuffer[0] = EEPROM_ByteRead(EEPROM_RESET_COUNTER_ADDR);
	OutputBuffer[1] = EEPROM_ByteRead(EEPROM_RESET_COUNTER_ADDR+1);
	OutputBuffer[2] = EEPROM_ByteRead(EEPROM_RESET_COUNTER_ADDR+2);
	OutputBuffer[3] = EEPROM_ByteRead(EEPROM_RESET_COUNTER_ADDR+3);
}

void OutputBufferToResetCounter(void)
{
		EEPROM_ByteWrite(EEPROM_RESET_COUNTER_ADDR, OutputBuffer[0]);
		EEPROM_ByteWrite(EEPROM_RESET_COUNTER_ADDR+1, OutputBuffer[1]);
		EEPROM_ByteWrite(EEPROM_RESET_COUNTER_ADDR+2, OutputBuffer[2]);
		EEPROM_ByteWrite(EEPROM_RESET_COUNTER_ADDR+3, OutputBuffer[3]);
}

void OutSymbol(unsigned char LedNumber, unsigned char SymbolCode)
{
	LedsSwitchOff();

	switch (SymbolCode)
	{
		case 0x2D:
		{
			SEGMENT_G = 1;
		} break;
		case 0x30:
		{
			SEGMENT_A = 1;
			SEGMENT_B = 1;
			SEGMENT_C = 1;
			SEGMENT_D = 1;
			SEGMENT_E = 1;
			SEGMENT_F = 1;
		} break;
		case 0x31:
		{
			SEGMENT_B = 1;
			SEGMENT_C = 1;
		} break;
		case 0x32:
		{
			SEGMENT_A = 1;
			SEGMENT_B = 1;
			SEGMENT_G = 1;
			SEGMENT_E = 1;
			SEGMENT_D = 1;
		} break;
		case 0x33:
		{
			SEGMENT_A = 1;
			SEGMENT_B = 1;
			SEGMENT_C = 1;
			SEGMENT_D = 1;
			SEGMENT_G = 1;
		} break;
		case 0x34:
		{
			SEGMENT_B = 1;
			SEGMENT_C = 1;
			SEGMENT_F = 1;
			SEGMENT_G = 1;
		} break;
		case 0x35:
		{
			SEGMENT_A = 1;
			SEGMENT_F = 1;
			SEGMENT_G = 1;
			SEGMENT_C = 1;
			SEGMENT_D = 1;
		} break;
		case 0x36:
		{
			SEGMENT_A = 1;
			SEGMENT_F = 1;
			SEGMENT_G = 1;
			SEGMENT_E = 1;
			SEGMENT_D = 1;
			SEGMENT_C = 1;
		} break;
		case 0x37:
		{
			SEGMENT_A = 1;
			SEGMENT_B = 1;
			SEGMENT_C = 1;
		} break;
		case 0x38:
		{
			SEGMENT_A = 1;
			SEGMENT_B = 1;
			SEGMENT_C = 1;
			SEGMENT_D = 1;
			SEGMENT_E = 1;
			SEGMENT_F = 1;
			SEGMENT_G = 1;
		} break;
		case 0x39:
		{
			SEGMENT_A = 1;
			SEGMENT_B = 1;
			SEGMENT_C = 1;
			SEGMENT_D = 1;
			SEGMENT_F = 1;
			SEGMENT_G = 1;
		} break;
	}

	if (FlagPoint == 1) SEGMENT_POINT = 1;
	switch (LedNumber)
	{
		case 1: LED1 = 0; break;
		case 2: LED2 = 0; break;
		case 3: LED3 = 0; break;
		case 4: LED4 = 0; break;
	}	
}

void LedsSwitchOff(void)
{
	LED1 = 1;
	LED2 = 1;
	LED3 = 1;
	LED4 = 1;

	SEGMENT_A = 0;
	SEGMENT_B = 0;
	SEGMENT_C = 0;
	SEGMENT_D = 0;
	SEGMENT_E = 0;
	SEGMENT_F = 0;
	SEGMENT_G = 0;
	SEGMENT_POINT = 0;
}

//-------------------------
// Initialize
//-------------------------
// Called when a DEV_CONFIGURED interrupt is received.
// - Enables all peripherals needed for the application
//
void Initialize(void)
{
	Port_Init();                           // Initialize crossbar and GPIO
	OSCILLATOR_Init ();
//	OSCICN |= 0x83;							// ����� �������
	Timer0_Init();                          // Initialize timer2
	Timer1_Init(); // smbus SCL
	Timer3_Init(); // smbus
	SMBus_Init ();
	Ext_Interrupt_Init();
}

void OSCILLATOR_Init (void)
{
#ifdef EXTERNAL_CRYSTAL
	int i;
    OSCXCN    = 0x67;
    for (i = 0; i < 256; i++);  // Wait 1ms for initialization
    while (!(OSCXCN & 0x80));           // Wait for crystal osc. to settle
   	RSTSRC = 0x06;                      	// Enable missing clock detector and
    	                                   	// VDD Monitor reset

//   	CLKMUL = 0x00;
	CLKSEL = 0x01;                      	// Select external oscillator as system
                                       		// clock source
//	CLKMUL |= 0x80;
//    for (i = 0; i < 256; i++);  // Wait 1ms for initialization
//    CLKMUL |= 0xC0;
//	while (!(CLKMUL & 0x20));           // 
	
   	OSCICN = 0x03;                      	// Disable the internal oscillator.
#else
	OSCICN = 0x83;							// ����� �������
	RSTSRC |= 0x04;                      	// Enable missing clock detector and
#endif
}

//-------------------------
// Timer_Init
//-------------------------
// Timer initialization
// - 1 mhz timer 2 reload, used to check if switch pressed on overflow and
// used for ADC continuous conversion
//
void Timer0_Init(void)
{
	TL0 = 0;
	TH0 = 1;

	TMOD = 0x02; 	//	00 - 13bit, 01 - 16bit, 02 - 8 bit;;
					//	T0M1=0; // 16-��������� ������

#ifdef EXTERNAL_CRYSTAL
	CKCON = 0x03; 
#else
	CKCON = 0x00; // �������� �� 12 (01 - �� 4, 10 - �� 48, �� 8  - EXT CLK)
#endif
	TCON = 0x10;                        // Timer0 ON
}

void Timer1_Init (void)
{
#if ((SYSCLK/SMB_FREQUENCY/3) < 255)
   #define SCALE 1
      CKCON |= 0x08;                   // Timer1 clock source = SYSCLK
#elif ((SYSCLK/SMB_FREQUENCY/4/3) < 255)
   #define SCALE 4
      CKCON |= 0x01;
      CKCON &= ~0x0A;                  // Timer1 clock source = SYSCLK / 4
#endif

   TMOD |= 0x20;                        // Timer1 in 8-bit auto-reload mode

   TH1 = -(SYSCLK/SMB_FREQUENCY/12/3); // Timer1 configured to overflow at 1/3
                                       // the rate defined by SMB_FREQUENCY

   TL1 = TH1;                          // Init Timer1

   TR1 = 1;                            // Timer1 enabled
}


void Timer3_Init (void)
{
   TMR3CN = 0x00;                      // Timer3 configured for 16-bit auto-
                                       // reload, low-byte interrupt disabled

   CKCON &= ~0x40;                     // Timer3 uses SYSCLK/12
   TMR3RL = -(SYSCLK/12/40);           // Timer3 configured to overflow after
   TMR3 = TMR3RL;                      // ~25ms (for SMBus low timeout detect)

   EIE1 |= 0x80;                       // Timer3 interrupt enable
   TMR3CN |= 0x04;                     // Start Timer3
}

/*
sbit KEY_RESET				= P2^1;
sbit KEY_INCREMENT			= P2^2;
sbit KEY_MODE 				= P2^3;
sbit KEY_STORE 				= P2^4;

sbit SEGMENT_A				= P1^6;
sbit SEGMENT_B				= P1^5;
sbit SEGMENT_C				= P1^1;
sbit SEGMENT_D				= P1^3;
sbit SEGMENT_E				= P1^4;
sbit SEGMENT_F				= P1^7;
sbit SEGMENT_G				= P1^2;
sbit SEGMENT_POINT			= P1^0;

sbit LED1					= P2^0;
sbit LED2					= P0^5;
sbit LED3					= P0^7;
sbit LED4					= P0^6;

sbit EXT_INT0				= P0^4;
sbit EXT_INT1				= P0^5;
*/

void Port_Init(void)
{
	P0MDOUT = 0xFF; // ��� �� �����
	P0MDOUT &= ~0x7F; // bit6,5,4,3 - ����������, bit2 ���� /INT0, /INT1, bit0,1 - I2C EEprom
	P1MDOUT = 0xFF;  // ��� �� �����

	P2MDOUT = 0xFF;  // ��� �� �����
	P2MDOUT &= ~0x20; // Int0 ���������� - ����
	P2MDOUT &= ~0x02; // KEY_RESET
	P2MDOUT &= ~0x04; // KEY_INCREMENT
	P2MDOUT &= ~0x08; // KEY_MODE 
	P2MDOUT &= ~0x10; // KEY_STORE

	P2 |= 0x1E; // p2.1 - p2.4 - ����������
	P0 |= 0x0C; // p0.2, p0.3  - ���� /INT0
	P0 &= ~0x03; // p0.0 , p0.1 - TX / RX I2C

	XBR0    = 0x04;						// SMBUS enabled
	XBR1    = 0x40;                     // Enable Crossbar and weak pull-ups
}

//
// SMBUS INIT
//
//
void SMBus_Init (void)
{
	SMB0CF = 0x5D;                      // Use Timer1 overflows as SMBus clock
                                       // source;
                                       // Disable slave mode;
                                       // Enable setup & hold time extensions;
                                       // Enable SMBus Free timeout detect;
                                       // Enable SCL low timeout detect;

	SMB0CF |= 0x80;                     // Enable SMBus;
}

void Ext_Interrupt_Init (void)
{
	IP = 0x05;// int1, int0 ������� ���������

	TCON |= 0x05; // �������
	IT01CF |= 0x88;	// ���������� /INT0 ( 1 - ������� �������� �������)
// ����� ���������� ��� HIGH ��� LOW

	IT01CF |= 0x02;	// 
	IT01CF &= ~0x05; // ����� ����� P0.2 ��� /INT0

	IT01CF |= 0x30;	// 
	IT01CF &= ~0x40; // ����� ����� P0.3 ��� /INT1

	EX0 = 1;                            // Enable /INT0 interrupts
	EX1 = 1;                            // Enable /INT1 interrupts
}


//-----------------------------------------------------------------------------
// EEPROM_ByteWrite ()
//-----------------------------------------------------------------------------
//
// Return Value : None
// Parameters   :
//   1) unsigned char addr - address to write in the EEPROM
//                        range is full range of character: 0 to 255
//
//   2) unsigned char dat - data to write to the address <addr> in the EEPROM
//                        range is full range of character: 0 to 255
//
// This function writes the value in <dat> to location <addr> in the EEPROM
// then polls the EEPROM until the write is complete.
//
void EEPROM_ByteWrite(U16 addr, unsigned char dat)
{
   while (SMB_BUSY);                   // Wait for SMBus to be free.
   SMB_BUSY = 1;                       // Claim SMBus (set to busy)

	WORD_ADDR_HIGH = addr >> 8;                   // Set the target address in the
	WORD_ADDR_LOW = addr & 0xFF;

   // Set SMBus ISR parameters
#ifdef EEPROM_24C128
	SMB_SENDWORDADDR_HIGH = 1;
#endif
#ifdef EEPROM_24C16
	SMB_SENDWORDADDR_HIGH = 0;
#endif
	SMB_RW = WRITE;                     // Mark next transfer as a write
	SMB_SENDWORDADDR_LOW = 1;               // Send Word Address after Slave Address

	SMB_RANDOMREAD = 0;                 // Do not send a START signal after
                                       // the word address
	SMB_ACKPOLL = 1;                    // Enable Acknowledge Polling (The ISR
                                       // will automatically restart the
                                       // transfer if the slave does not
                                       // acknoledge its address.

   // Specify the Outgoing Data
	SMB_SINGLEBYTE_OUT = dat;           // Store <dat> (local variable) in a
                                       // global variable so the ISR can read
                                       // it after this function exits

   // The outgoing data pointer points to the <dat> variable
	pSMB_DATA_OUT = &SMB_SINGLEBYTE_OUT;

//	SMB_DATA_LEN = 1;                   // Specify to ISR that the next transfer
                                       // will contain one data byte

   // Initiate SMBus Transfer
	STA = 1;
}


//-----------------------------------------------------------------------------
// EEPROM_ByteRead ()
//-----------------------------------------------------------------------------
//
// Return Value :
//   1) unsigned char data - data read from address <addr> in the EEPROM
//                        range is full range of character: 0 to 255
//
// Parameters   :
//   1) unsigned char addr - address to read data from the EEPROM
//                        range is full range of character: 0 to 255
//
// This function returns a single byte from location <addr> in the EEPROM then
// polls the <SMB_BUSY> flag until the read is complete.
//
unsigned char EEPROM_ByteRead(U16 addr)
{
   unsigned char retval;               // Holds the return value

   
   while (SMB_BUSY);                   // Wait for SMBus to be free.
   SMB_BUSY = 1;                       // Claim SMBus (set to busy)


	WORD_ADDR_HIGH = addr >> 8;                   // Set the target address in the
	WORD_ADDR_LOW = addr & 0xFF; 

   // Set SMBus ISR parameters
#ifdef EEPROM_24C128
	SMB_SENDWORDADDR_HIGH = 1;
#endif
#ifdef EEPROM_24C16
	SMB_SENDWORDADDR_HIGH = 0;
#endif

   SMB_SENDWORDADDR_LOW = 1;               // Send Word Address after Slave Address
   SMB_RW = WRITE;                     // A random read starts as a write
                                       // then changes to a read after
                                       // the repeated start is sent. The
                                       // ISR handles this switchover if
                                       // the <SMB_RANDOMREAD> bit is set.
   SMB_RANDOMREAD = 1;                 // Send a START after the word address
   SMB_ACKPOLL = 1;                    // Enable Acknowledge Polling


   // Specify the Incoming Data
   pSMB_DATA_IN = &retval;             // The incoming data pointer points to
                                       // the <retval> variable.

//   SMB_DATA_LEN = 1;                   // Specify to ISR that the next transfer
                                       // will contain one data byte

   // Initiate SMBus Transfer
   STA = 1;
   while(SMB_BUSY);                    // Wait until data is read

   return retval;

}

void Suspend_Device(void)
{
   // Disable peripherals before calling USB_Suspend()
//	P0MDIN = 0x0;                       // Port 0 configured as analog input
//	P1MDIN = 0x00;                       // Port 1 configured as analog input
//	P2MDIN = 0x0;
//	ADC0CN &= ~0x80;                     // Disable ADC0
//	ET0 = 0;
//	ET2 = 0;                             // Disable Timer 2 Interrupts

	USB_Suspend();                       // Put the device in suspend state
										// Once execution returns from USB_Suspend(), device leaves suspend state.
										// Reenable peripherals
//	ADC0CN |= 0x80;                      // Enable ADC0
//	P0MDIN = 0xFF;
//	P1MDIN = 0xFF;                       // Port 1 pin 7 set as analog input
//	P2MDIN = 0xFF;
//	ET0 = 1;
//	ET2 = 1;							// Enable Timer 2 Interrupts
}

//
//  IIII  SS  RRR                                   
//   II  S  S R  R                                  
//   II  SS   R  R                                  
//   II   SS  RRR                                   
//   II    SS R  R                                  
//   II  S  S R  R                                  
//  IIII  SS  R  R                                  
//
//
//
//-----------------------------------------------------------------------------
// /INT0 ISR
//-----------------------------------------------------------------------------
//
// Whenever a negative edge appears on P0.0, LED1 is toggled.
// The interrupt pending flag is automatically cleared by vectoring to the ISR
//
//-----------------------------------------------------------------------------
void INT0_ISR (void) interrupt 0
{
	Counter++;
}
void INT1_ISR (void) interrupt 2
{
	Counter--;
}

//-----------------------------------------------------------------------------
// SMBus Interrupt Service Routine (ISR)
//-----------------------------------------------------------------------------
//
void SMBus_ISR (void) interrupt 7
{
   bit FAIL = 0;                       // Used by the ISR to flag failed
                                       // transfers

   static char i;                      // Used by the ISR to count the
                                       // number of data bytes sent or
                                       // received

   static bit SEND_START = 0;          // Send a start

   switch (SMB0CN & 0xF0)              // Status vector
   {
      // Master Transmitter/Receiver: START condition transmitted.
      case SMB_MTSTA:
         SMB0DAT = TARGET;             // Load address of the target slave
         SMB0DAT &= 0xFE;              // Clear the LSB of the address for the
                                       // R/W bit
         SMB0DAT |= SMB_RW;            // Load R/W bit

#ifdef EEPROM_24C16
		SMB0DAT = SMB0DAT | ((WORD_ADDR_HIGH & 0x07)<<1);
#endif

         STA = 0;                      // Manually clear START bit
         i = 0;                        // Reset data byte counter
         break;

      // Master Transmitter: Data byte (or Slave Address) transmitted
      case SMB_MTDB:
         if (ACK)                      // Slave Address or Data Byte
         {                             // Acknowledged?
            if (SEND_START)
            {
               STA = 1;
               SEND_START = 0;
               break;
            }

            if(SMB_SENDWORDADDR_HIGH)       // Are we sending the word address?
            {
               SMB_SENDWORDADDR_HIGH = 0;   // Clear flag
               SMB0DAT = WORD_ADDR_HIGH;    // Send word address
               break;
            }

            if(SMB_SENDWORDADDR_LOW)       // Are we sending the word address?
            {
               SMB_SENDWORDADDR_LOW = 0;   // Clear flag
               SMB0DAT = WORD_ADDR_LOW;    // Send word address

               if (SMB_RANDOMREAD)
               {
                  SEND_START = 1;      // Send a START after the next ACK cycle
                  SMB_RW = READ;
               }

               break;
            }

            if (SMB_RW==WRITE)         // Is this transfer a WRITE?
            {

               if (i < 1)   // Is there data to send?
               {
//                  // send data byte
                  SMB0DAT = *pSMB_DATA_OUT;
//
                  // increment data out pointer
                  pSMB_DATA_OUT++;

                  // increment number of bytes sent
                  i++;
               }
               else
               {
                 STO = 1;              // Set STO to terminte transfer
                 SMB_BUSY = 0;         // Clear software busy flag
               }
            }
            else {}                    // If this transfer is a READ,
                                       // then take no action. Slave
                                       // address was transmitted. A
                                       // separate 'case' is defined
                                       // for data byte recieved.
         }
         else                          // If slave NACK,
         {
            if(SMB_ACKPOLL)
            {
               STA = 1;                // Restart transfer
            }
            else
            {
               FAIL = 1;               // Indicate failed transfer
            }                          // and handle at end of ISR
         }
         break;

      // Master Receiver: byte received
      case SMB_MRDB:
         if ( i < 1 )       // Is there any data remaining?
         {
            *pSMB_DATA_IN = SMB0DAT;   // Store received byte
            pSMB_DATA_IN++;            // Increment data in pointer
            i++;                       // Increment number of bytes received
            ACK = 1;                   // Set ACK bit (may be cleared later
                                       // in the code)

         }

         if (i == 1)        // This is the last byte
         {
            SMB_BUSY = 0;              // Free SMBus interface
            ACK = 0;                   // Send NACK to indicate last byte
                                       // of this transfer
            STO = 1;                   // Send STOP to terminate transfer
         }

         break;

      default:
         FAIL = 1;                     // Indicate failed transfer
                                       // and handle at end of ISR
         break;
   }

   if (FAIL)                           // If the transfer failed,
   {
      SMB0CF &= ~0x80;                 // Reset communication
      SMB0CF |= 0x80;
      STA = 0;
      STO = 0;
      ACK = 0;

      SMB_BUSY = 0;                    // Free SMBus

      FAIL = 0;
   }

   SI = 0;                             // Clear interrupt flag

}

//-------------------------
// Timer0_ISR
//-------------------------
// Called when timer 2 overflows, check to see if switch is pressed,
// then watch for release.
//
INTERRUPT(Timer0_ISR, INTERRUPT_TIMER0)
{
	unsigned char i;
	static int low_counter=0;  // Define counter variable

	TL0 = TIMER0_RELOAD_LOW;            // Reinit Timer0 Low register

//	if ((low_counter2++) == Timer0_RateEncoder )
//	{
//		EncoderScan5();
//		low_counter2 = 0;
//	}
	if ((low_counter++) == Timer0_Rate)
	{
//		if (LcdMode = 0) j = 5; else j = 6;
		for (i=0;i<(4 + LcdMode);i++) 
		{
			if (i == 2) FlagPoint = 1; else FlagPoint = 0;
			if (LcdMode == 0) FlagPoint = 1;
			OutSymbol(i+1,0x30 | OutputBuffer[i]);
			Del	(200);
		}
		low_counter = 0;
	}
}
//-------------------------
// Timer2_ISR
//-------------------------
// Called when timer 2 overflows, check to see if switch is pressed,
// then watch for release.
//
INTERRUPT(Timer2_ISR, INTERRUPT_TIMER2)
{
	TF2H = 0;                              // Clear Timer2 interrupt flag
	ET2=1;
}

//-----------------------------------------------------------------------------
// Timer3 Interrupt Service Routine (ISR)
//-----------------------------------------------------------------------------
//
// A Timer3 interrupt indicates an SMBus SCL low timeout.
// The SMBus is disabled and re-enabled if a timeout occurs.
//
void Timer3_ISR (void) interrupt 14
{
   SMB0CF &= ~0x80;                    // Disable SMBus
   SMB0CF |= 0x80;                     // Re-enable SMBus
   TMR3CN &= ~0x80;                    // Clear Timer3 interrupt-pending flag
   SMB_BUSY = 0;                       // Free bus
}

INTERRUPT(USB_API_TEST_ISR, INTERRUPT_USBXpress)
{
	unsigned char INTVAL = Get_Interrupt_Source();

   if (INTVAL & RX_COMPLETE)
   {
		Block_Read(In_Packet, sizeof(In_Packet));

		switch (In_Packet[0])
		{
		default:;
   		}
	}

   if (INTVAL & DEV_SUSPEND)
   {
        Suspend_Device();
   }

   if (INTVAL & DEV_CONFIGURED)
   {
//      Initialize();
   }
}

//
//
//
//

//;=============================================================================================
//; ��������� ��������
//;
// 1 ��� = 24 �����
//; �������: 8+(2+((R0-1)*3)+2)+(2+(((R2-1)*3)+2))+9
//; ������:  R0 = 140, R0=79
//;          R1 = 253
//; �����:   8+(2+((140-1)*3)+2)+(2+(((253-1)*3)+2)+(2+(((79-1)*3)+2))+2+9 = 1440
//;---------------------------------------------------------------------------------------------
/*
void Del_10mks(void)
{
	#pragma asm
	push	00h							; 2 �����             | 6 ������
	mov   R0,#75						; 2 �����             |
	djnz  R0,$							; (74*3)+2=224 �����  | 227 ������
	nop									; 1 ����              |
	
	pop	00h							; 2 �����             | 7 ������
	ret									; ������� 5 ������    |
	#pragma endasm
}
*/

void Del_500mks(void)
{
	#pragma asm
	push	00h							; 2 �����             |
	push	01h							; 2 �����             |
	push	02h							; 2 �����             | 12 ������
											;                     |
	mov   R1,#20						; 2 �����             |
		
	mov   R0,#195						; 2 �����             | (589*20)-1=
	djnz  R0,$							; (194*3)+2=584 ����� | 11779 ������
	djnz	R1,$-4						; 3 �����             |

	mov   R2,#65						; 2 �����             |
	djnz  R2,$							; (64*3)+2=194 ������ | 198 ������
	nop									; 1 ����              |
	nop									; 1 ����              |
						
	pop	02h							; 2 �����             |
	pop	01h							; 2 �����             | 11 ������
	pop	00h							; 2 �����             |
	ret									; ������� 5 ������    |
	#pragma endasm
}

/*
void Del_10ms(void)
{
	#pragma asm
	push	00h							; 2 �����             |
	push	01h							; 2 �����             |
	push	02h							; 2 �����             | 14 ������
	push	03h							; 2 �����             |
																;                     |
	mov   R2,#6							; 2 �����             |					
									
	mov   R1,#168	;              | 2 ����� +           |
	mov   R0,#78	; 2 ����� +    |                     | (39988*6)-1=
	djnz	R0,$		; (77*3)+2=233 | (((235+3)*168)-1)=  | 239927 ������
	djnz  R1,$-4	;              |    55249 ������     |   
	djnz	R2,$-8	;              | + 3 �����           |

	mov   R3,#15						; 2 �����             |
	djnz  R3,$							; (14*3)+2=44 ������  | 46 ������
						
	pop	03h							; 2 �����             |
	pop	02h							; 2 �����             |
	pop	01h							; 2 �����             | 13 ������
	pop	00h							; 2 �����             |
	ret									; ������� 5 ������    |
	#pragma endasm
}

void Del_25ms(void)
{
	#pragma asm
	push	00h							; 2 �����             |
	push	01h							; 2 �����             |
	push	02h							; 2 �����             | 14 ������
	push	03h							; 2 �����             |
																;                     |
	mov   R2,#15						; 2 �����             |					
					
	mov   R1,#168	;              | 2 ����� +           |
	mov   R0,#78	; 2 ����� +    |                     | (39988*15)-1=
	djnz	R0,$		; (77*3)+2=233 | (((235+3)*168)-1)=  | 599819 ������
	djnz  R1,$-4	;              |    55249 ������     |   
	djnz	R2,$-8	;              | + 3 �����           |

	mov   R3,#51						; 2 �����             |
	djnz  R3,$							; (50*3)+2=152 ������ | 154 ������
						
	pop	03h							; 2 �����             |
	pop	02h							; 2 �����             |
	pop	01h							; 2 �����             | 13 ������
	pop	00h							; 2 �����             |
	ret									; ������� 5 ������    |
	#pragma endasm
}
*/

void Del_100ms(void)
{
	#pragma asm
	push	00h							; 2 �����             |
	push	01h							; 2 �����             |
	push	02h							; 2 �����             | 14 ������
	push	03h							; 2 �����             |
											;                     |
	mov   R2,#60						; 2 �����             |					
								
	mov   R1,#168	;              | 2 ����� +           |
	mov   R0,#78	; 2 ����� +    |                     | (39988*60)-1=
	djnz	R0,$		; (77*3)+2=233 | (((235+3)*168)-1)=  | 2399279 ������
	djnz  R1,$-4	;              |    55249 ������     |   
	djnz	R2,$-8	;              | + 3 �����           |

	mov   R3,#231						; 2 �����             |
	djnz  R3,$							; (230*3)+2=692 ������| 694 ������
	
	pop	03h							; 2 �����             |
	pop	02h							; 2 �����             |
	pop	01h							; 2 �����             | 13 ������
	pop	00h							; 2 �����             |
	ret									; ������� 5 ������    |
	#pragma endasm
}

void Del(int a)
{
	int i;
	for (i=0;i<a;i++)
	{
	}
}

