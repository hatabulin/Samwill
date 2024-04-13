/*****************************************************
This program was produced by the
CodeWizardAVR V1.24.4 Standard
Automatic Program Generator
© Copyright 1998-2004 Pavel Haiduc, HP InfoTech s.r.l.
http://www.hpinfotech.com
e-mail:office@hpinfotech.com

Project : 
Version : 
Date    : 08.12.2008
Author  : GNN                             
Company : t                               
Comments: 


Chip type           : ATmega16
Program type        : Application
Clock frequency     : 7,372800 MHz
Memory model        : Small
External SRAM size  : 0
Data Stack size     : 256
*****************************************************/

#include <mega16.h>

// External Interrupt 0 service routine
interrupt [EXT_INT0] void ext_int0_isr(void)
{
// Place your code here
volatile EncoderStateType EncoderState[NUM_ENCODERS];
}

// Standard Input/Output functions
#include <stdio.h>
// Global variables
#define CYCLES_PER_US ((F_CPU+500000)/1000000) 	// cpu cycles per microsecond  
#define NUM_ENCODERS				2

// Functions

// encoderInit() initializes hardware and encoder position readings
//		Run this init routine once before using any other encoder functions.
void encoderInit(void)
{
	u08 i;

	// initialize/clear encoder data
	for(i=0; i<NUM_ENCODERS; i++)
	{
		EncoderState[i].position = 0;
		//EncoderState[i].velocity = 0;		// NOT CURRENTLY USED
	}

	// configure direction and interrupt I/O pins:
	// - for input
	// - apply pullup resistors
	// - any-edge interrupt triggering
	// - enable interrupt

	#ifdef ENC0_SIGNAL
		// set interrupt pins to input and apply pullup resistor
		cbi(ENC0_PHASEA_DDR, ENC0_PHASEA_PIN);
		sbi(ENC0_PHASEA_PORT, ENC0_PHASEA_PIN);
		// set encoder direction pin for input and apply pullup resistor
		cbi(ENC0_PHASEB_DDR, ENC0_PHASEB_PIN);
		sbi(ENC0_PHASEB_PORT, ENC0_PHASEB_PIN);
		// configure interrupts for any-edge triggering
		sbi(ENC0_ICR, ENC0_ISCX0);
		cbi(ENC0_ICR, ENC0_ISCX1);
		// enable interrupts
		sbi(IMSK, ENC0_INT);	// ISMK is auto-defined in encoder.h
	#endif
	#ifdef ENC1_SIGNAL
		// set interrupt pins to input and apply pullup resistor
		cbi(ENC1_PHASEA_DDR, ENC1_PHASEA_PIN);
		sbi(ENC1_PHASEA_PORT, ENC1_PHASEA_PIN);
		// set encoder direction pin for input and apply pullup resistor
		cbi(ENC1_PHASEB_DDR, ENC1_PHASEB_PIN);
		sbi(ENC1_PHASEB_PORT, ENC1_PHASEB_PIN);
		// configure interrupts for any-edge triggering
		sbi(ENC1_ICR, ENC1_ISCX0);
		cbi(ENC1_ICR, ENC1_ISCX1);
		// enable interrupts
		sbi(IMSK, ENC1_INT);	// ISMK is auto-defined in encoder.h
	#endif
	#ifdef ENC2_SIGNAL
		// set interrupt pins to input and apply pullup resistor
		cbi(ENC2_PHASEA_DDR, ENC2_PHASEA_PIN);
		sbi(ENC2_PHASEA_PORT, ENC2_PHASEA_PIN);
		// set encoder direction pin for input and apply pullup resistor
		cbi(ENC2_PHASEB_DDR, ENC2_PHASEB_PIN);
		sbi(ENC2_PHASEB_PORT, ENC2_PHASEB_PIN);
		// configure interrupts for any-edge triggering
		sbi(ENC2_ICR, ENC2_ISCX0);
		cbi(ENC2_ICR, ENC2_ISCX1);
		// enable interrupts
		sbi(IMSK, ENC2_INT);	// ISMK is auto-defined in encoder.h
	#endif
	#ifdef ENC3_SIGNAL
		// set interrupt pins to input and apply pullup resistor
		cbi(ENC3_PHASEA_DDR, ENC3_PHASEA_PIN);
		sbi(ENC3_PHASEA_PORT, ENC3_PHASEA_PIN);
		// set encoder direction pin for input and apply pullup resistor
		cbi(ENC3_PHASEB_DDR, ENC3_PHASEB_PIN);
		sbi(ENC3_PHASEB_PORT, ENC3_PHASEB_PIN);
		// configure interrupts for any-edge triggering
		sbi(ENC3_ICR, ENC3_ISCX0);
		cbi(ENC3_ICR, ENC3_ISCX1);
		// enable interrupts
		sbi(IMSK, ENC3_INT);	// ISMK is auto-defined in encoder.h
	#endif
	
	// enable global interrupts
	sei();
}

// encoderOff() disables hardware and stops encoder position updates
void encoderOff(void)
{
	// disable encoder interrupts
	#ifdef ENC0_SIGNAL
		// disable interrupts
		sbi(IMSK, INT0);	// ISMK is auto-defined in encoder.h
	#endif
	#ifdef ENC1_SIGNAL
		// disable interrupts
		sbi(IMSK, INT1);	// ISMK is auto-defined in encoder.h
	#endif
	#ifdef ENC2_SIGNAL
		// disable interrupts
		sbi(IMSK, INT2);	// ISMK is auto-defined in encoder.h
	#endif
	#ifdef ENC3_SIGNAL
		// disable interrupts
		sbi(IMSK, INT3);	// ISMK is auto-defined in encoder.h
	#endif
}

// encoderGetPosition() reads the current position of the encoder 
s32 encoderGetPosition(u08 encoderNum)
{  if(encoderNum < NUM_ENCODERS)
		return EncoderState[encoderNum].position;
	else
		return 0;
	// sanity check
	
}

// encoderSetPosition() sets the current position of the encoder
void encoderSetPosition(u08 encoderNum, s32 position)
{       	if(encoderNum < NUM_ENCODERS)
		EncoderState[encoderNum].position = position;
	// sanity check

	// else do nothing
}

#ifdef ENC0_SIGNAL
//! Encoder 0 interrupt handler
SIGNAL(ENC0_SIGNAL)
{
	// encoder has generated a pulse
	// check the relative phase of the input channels
	// and update position accordingly
	if( ((inb(ENC0_PHASEA_PORTIN) & (1<<ENC0_PHASEA_PIN)) == 0) ^
		((inb(ENC0_PHASEB_PORTIN) & (1<<ENC0_PHASEB_PIN)) == 0) )
	{
		EncoderState[0].position++;
	}
	else
	{
		EncoderState[0].position--;
	}
}
#endif

#ifdef ENC1_SIGNAL
//! Encoder 1 interrupt handler
SIGNAL(ENC1_SIGNAL)
{
	// encoder has generated a pulse
	// check the relative phase of the input channels
	// and update position accordingly
	if( ((inb(ENC1_PHASEA_PORTIN) & (1<<ENC1_PHASEA_PIN)) == 0) ^
		((inb(ENC1_PHASEB_PORTIN) & (1<<ENC1_PHASEB_PIN)) == 0) )
	{
		EncoderState[1].position++;
	}
	else
	{
		EncoderState[1].position--;
	}
}
#endif

#ifdef ENC2_SIGNAL
//! Encoder 2 interrupt handler
SIGNAL(ENC2_SIGNAL)
{
	// encoder has generated a pulse
	// check the relative phase of the input channels
	// and update position accordingly
	if( ((inb(ENC2_PHASEA_PORTIN) & (1<<ENC2_PHASEA_PIN)) == 0) ^
		((inb(ENC2_PHASEB_PORTIN) & (1<<ENC2_PHASEB_PIN)) == 0) )
	{
		EncoderState[2].position++;
	}
	else
	{
		EncoderState[2].position--;
	}
}
#endif

#ifdef ENC3_SIGNAL
//! Encoder 3 interrupt handler
SIGNAL(ENC3_SIGNAL)
{
	// encoder has generated a pulse
	// check the relative phase of the input channels
	// and update position accordingly
	if( ((inb(ENC3_PHASEA_PORTIN) & (1<<ENC3_PHASEA_PIN)) == 0) ^
		((inb(ENC3_PHASEB_PORTIN) & (1<<ENC3_PHASEB_PIN)) == 0) )
	{
		EncoderState[3].position++;
	}
	else
	{
		EncoderState[3].position--;
	}
}
#endif

// Declare your global variables here

void main(void)
{
// Declare your local variables here



// -------------------- Encoder 0 connections --------------------
// Phase A quadrature encoder output should connect to this interrupt line:
// *** NOTE: the choice of interrupt PORT, DDR, and PIN must match the external
// interrupt you are using on your processor.  Consult the External Interrupts
// section of your processor's datasheet for more information.

// Interrupt Configuration
#define ENC0_SIGNAL					SIG_INTERRUPT0	// Interrupt signal name
#define ENC0_INT					INT0	// matching INTx bit in GIMSK/EIMSK
#define ENC0_ICR					MCUCR	// matching Int. Config Register (MCUCR,EICRA/B)
#define ENC0_ISCX0					ISC00	// matching Interrupt Sense Config bit0
#define ENC0_ISCX1					ISC01	// matching Interrupt Sense Config bit1
// PhaseA Port/Pin Configuration
// *** PORTx, DDRx, PINx, and Pxn should all have the same letter for "x" ***
#define ENC0_PHASEA_PORT			PORTD	// PhaseA port register
#define ENC0_PHASEA_DDR				DDRD	// PhaseA port direction register
#define ENC0_PHASEA_PORTIN			PIND	// PhaseA port input register
#define ENC0_PHASEA_PIN				PD2		// PhaseA port pin
// Phase B quadrature encoder output should connect to this direction line:
// *** PORTx, DDRx, PINx, and Pxn should all have the same letter for "x" ***
#define ENC0_PHASEB_PORT			PORTC	// PhaseB port register
#define ENC0_PHASEB_DDR				DDRC	// PhaseB port direction register
#define ENC0_PHASEB_PORTIN			PINC	// PhaseB port input register
#define ENC0_PHASEB_PIN				PC0		// PhaseB port pin


// -------------------- Encoder 1 connections --------------------
// Phase A quadrature encoder output should connect to this interrupt line:
// *** NOTE: the choice of interrupt pin and port must match the external
// interrupt you are using on your processor.  Consult the External Interrupts
// section of your processor's datasheet for more information.

// Interrupt Configuration
#define ENC1_SIGNAL					SIG_INTERRUPT1	// Interrupt signal name
#define ENC1_INT					INT1	// matching INTx bit in GIMSK/EIMSK
#define ENC1_ICR					MCUCR	// matching Int. Config Register (MCUCR,EICRA/B)
#define ENC1_ISCX0					ISC10	// matching Interrupt Sense Config bit0
#define ENC1_ISCX1					ISC11	// matching Interrupt Sense Config bit1
// PhaseA Port/Pin Configuration
// *** PORTx, DDRx, PINx, and Pxn should all have the same letter for "x" ***
#define ENC1_PHASEA_PORT			PORTD	// PhaseA port register
#define ENC1_PHASEA_PORTIN			PIND	// PhaseA port input register
#define ENC1_PHASEA_DDR				DDRD	// PhaseA port direction register
#define ENC1_PHASEA_PIN				PD3		// PhaseA port pin
// Phase B quadrature encoder output should connect to this direction line:
// *** PORTx, DDRx, PINx, and Pxn should all have the same letter for "x" ***
#define ENC1_PHASEB_PORT			PORTC	// PhaseB port register
#define ENC1_PHASEB_DDR				DDRC	// PhaseB port direction register
#define ENC1_PHASEB_PORTIN			PINC	// PhaseB port input register
#define ENC1_PHASEB_PIN				PC1		// PhaseB port pin
// Input/Output Ports initialization
// Port A initialization
// Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In 
// State7=T State6=T State5=T State4=T State3=T State2=T State1=T State0=T 
PORTA=0x00;
DDRA=0x00;

// Port B initialization
// Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In 
// State7=T State6=T State5=T State4=T State3=T State2=T State1=T State0=T 
PORTB=0x00;
DDRB=0x00;

// Port C initialization
// Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In 
// State7=T State6=T State5=T State4=T State3=T State2=T State1=T State0=P 
PORTC=0x01;
DDRC=0x00;

// Port D initialization
// Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In 
// State7=T State6=T State5=T State4=T State3=T State2=P State1=T State0=T 
PORTD=0x04;
DDRD=0x00;

// Timer/Counter 0 initialization
// Clock source: System Clock
// Clock value: Timer 0 Stopped
// Mode: Normal top=FFh
// OC0 output: Disconnected
TCCR0=0x00;
TCNT0=0x00;
OCR0=0x00;

// Timer/Counter 1 initialization
// Clock source: System Clock
// Clock value: Timer 1 Stopped
// Mode: Normal top=FFFFh
// OC1A output: Discon.
// OC1B output: Discon.
// Noise Canceler: Off
// Input Capture on Falling Edge
TCCR1A=0x00;
TCCR1B=0x00;
TCNT1H=0x00;
TCNT1L=0x00;
ICR1H=0x00;
ICR1L=0x00;
OCR1AH=0x00;
OCR1AL=0x00;
OCR1BH=0x00;
OCR1BL=0x00;

// Timer/Counter 2 initialization
// Clock source: System Clock
// Clock value: Timer 2 Stopped
// Mode: Normal top=FFh
// OC2 output: Disconnected
ASSR=0x00;
TCCR2=0x00;
TCNT2=0x00;
OCR2=0x00;

// External Interrupt(s) initialization
// INT0: On
// INT0 Mode: Any change
// INT1: Off
// INT2: Off
GICR|=0x40;
MCUCR=0x01;
MCUCSR=0x00;
GIFR=0x40;

// Timer(s)/Counter(s) Interrupt(s) initialization
TIMSK=0x00;

// USART initialization
// Communication Parameters: 8 Data, 1 Stop, No Parity
// USART Receiver: Off
// USART Transmitter: On
// USART Mode: Asynchronous
// USART Baud rate: 9600
UCSRA=0x00;
UCSRB=0x08;
UCSRC=0x86;
UBRRH=0x00;
UBRRL=0x2F;

// Analog Comparator initialization
// Analog Comparator: Off
// Analog Comparator Input Capture by Timer/Counter 1: Off
ACSR=0x80;
SFIOR=0x00;

// Global enable interrupts
#asm("sei")

while (1)
      {
      // Place your code here

      };
}
