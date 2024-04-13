#ifndef	encoder_h
#define	encoder_h
#include <ioavr.h>
//_________________________________________
//порт и выводы к которым подключен энкодер
#define PORT_Enc 	PORTA 	
#define PIN_Enc 	PINA
#define DDR_Enc 	DDRA
#define Pin1_Enc 	2
#define Pin2_Enc 	1
//______________________
#define RIGHT_SPIN 0x01 
#define LEFT_SPIN 0xff

void ENC_InitEncoder(void);
void ENC_PollEncoder(void);
unsigned char ENC_GetStateEncoder(void);
#endif  //encoder_h
