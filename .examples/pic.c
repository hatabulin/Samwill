/*
    Rotary Encoder Demo
    
    Use a rotary encoder to control the brightness of an LED
    
    Copyright HobbyTronics 2010
    
*/

#include <p18f14k22.h>

#pragma config FOSC = IRC
#pragma config WDTEN = OFF
#pragma config BOREN = OFF
#pragma config PWRTEN = ON
#pragma config MCLRE = OFF
#pragma config LVP = OFF
#pragma config HFOFST = OFF
#pragma config PLLEN = OFF

//Define Interrupt Locations
void hi_interrupt(void);
void lo_interrupt(void);

#pragma code high_vector_section=0x8
void high_vector (void){
    _asm GOTO hi_interrupt _endasm
}
#pragma code low_vector_section=0x18
void low_vector(void){
    _asm GOTO lo_interrupt _endasm
}
#pragma code

#define ENCODER_A PORTCbits.RC0        // Encoder A Pin
#define ENCODER_B PORTCbits.RC1        // Encoder B Pin

unsigned char    encoder_counter=0;    // Used to control brightness of LED, values 0 to 25 (we dont need 250 increments)
unsigned char    encoder_A;
unsigned char    encoder_B;
unsigned char    encoder_A_prev=0;
unsigned char    flag_set_pwm=1;

#pragma interruptlow lo_interrupt
void lo_interrupt(void){
    // -----------------------
    // Low Priority Interrupts
    // -----------------------    

    if (INTCONbits.TMR0IF)
    {
        encoder_A = ENCODER_A;
        encoder_B = ENCODER_B;

        if((!encoder_A) && (encoder_A_prev)){

            // A has gone from high to low
            if(encoder_B) {
                // B is high so clockwise
                if(encoder_counter<25)    encoder_counter++;
            }    
            else {
                // B is low so counter-clockwise            
                if(encoder_counter>0) encoder_counter--;
            }    
            flag_set_pwm = 1;           // Set flag to indicate change to PWM needed
        }    
        encoder_A_prev = encoder_A;     // Store value for next time
        TMR0L = 178;                    // 200 Hz
        INTCONbits.TMR0IF = 0;          // Clear interrupt flag
    }
    
}

#pragma interrupt hi_interrupt
void hi_interrupt(void)
{
}

void SetPWM(unsigned char pwm_width){
    // set pwm values
    // input of 0 to 25
    // PWM output is on P1A (pin 5)

    unsigned char pwm_lsb;
    
    pwm_width*=10;                         // change value from 0-25 to 0-250
    //10 Bits - 2 LSB's go in CCP1CON 5:4, 8 MSB's go in CCPR1L
    pwm_lsb = pwm_width & 0b00000011;      // Save 2 LSB
    CCPR1L = pwm_width >> 2;               // Remove 2 LSB and store 8 MSB in CCPR1L (only 6 bits as max duty value = 250)
    pwm_lsb = pwm_lsb << 4;                // Move 2 LSB into correct position
    CCP1CON = pwm_lsb + 0b00001100;        // duty lowest bits (5:4) + PWM mode

}

void main(void){

    OSCCON = 0b01110010;          // Int osc at 16 MHz
    RCONbits.IPEN = 1;            // Enable interrupt priority 
    INTCONbits.PEIE = 1;          // interrupts allowed
    INTCONbits.GIE = 1;             
    INTCONbits.GIEH = 1;
    INTCONbits.GIEL = 1;

    T0CON = 0b11000111;           // 8 bit timer, prescaler 1:256, TMR0 on
    TMR0L = 178;                  // 200Hz 
    INTCON2bits.TMR0IP = 0;       // interrupt priority 0
    INTCONbits.TMR0IE = 1;        // timer0 interrupt enabled
    
    // Clear the peripheral interrupt flags
    PIR1 = 0;

    ANSEL=0;                      // Digital
    ANSELH=0;                     // Digital
    ADCON0=0;                     // A2D Off
    CM1CON0=0;                    // Comparators off
    CM2CON0=0;                    // Comparators off

    TRISA = 0b00000000;           // Set Ports
    TRISB = 0b00000000;           // 
    TRISC = 0b00000011;           // Encoder inputs on RC0 and RC1
    
    /*
    * PWM Register Values
    * Oscillator Frequency Fosc = 16000000
    * Clock Frequency Fclk = 4000000
    * PWM Freq = 250 - allows us to use a duty value of 0 to 250
    * Prescaler Value = 16
    * Postscaler Value = 16    
    * PR2 = 62
    * Maximum duty value = 250 
    */
    T2CON = 0b01111111;           // prescaler postscaler to give 250Hz + turn on TMR2;
    PR2 = 62;                     // gives 250Hz
    CCPR1L = 0b00000000;          // set duty MSB - initially 0 - off
    CCP1CON = 0b00001100;         // duty lowest bits + PWM mode    

    while(1)
    {
        if(flag_set_pwm) {
            //Set PWM values
            SetPWM(encoder_counter);
        }    
    }
}

