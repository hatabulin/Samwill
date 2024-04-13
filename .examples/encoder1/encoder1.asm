;CodeVisionAVR C Compiler V1.24.4 Standard
;(C) Copyright 1998-2004 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com
;e-mail:office@hpinfotech.com

;Chip type           : ATmega16
;Program type        : Application
;Clock frequency     : 7,372800 MHz
;Memory model        : Small
;Optimize for        : Size
;(s)printf features  : int, width
;(s)scanf features   : int, width
;External SRAM size  : 0
;Data Stack size     : 256 byte(s)
;Heap size           : 0 byte(s)
;Promote char to int : No
;char is unsigned    : Yes
;8 bit enums         : Yes
;Enhanced core instructions    : On
;Automatic register allocation : On

	.EQU UDRE=0x5
	.EQU RXC=0x7
	.EQU USR=0xB
	.EQU UDR=0xC
	.EQU SPSR=0xE
	.EQU SPDR=0xF
	.EQU EERE=0x0
	.EQU EEWE=0x1
	.EQU EEMWE=0x2
	.EQU EECR=0x1C
	.EQU EEDR=0x1D
	.EQU EEARL=0x1E
	.EQU EEARH=0x1F
	.EQU WDTCR=0x21
	.EQU MCUCR=0x35
	.EQU GICR=0x3B
	.EQU SPL=0x3D
	.EQU SPH=0x3E
	.EQU SREG=0x3F

	.DEF R0X0=R0
	.DEF R0X1=R1
	.DEF R0X2=R2
	.DEF R0X3=R3
	.DEF R0X4=R4
	.DEF R0X5=R5
	.DEF R0X6=R6
	.DEF R0X7=R7
	.DEF R0X8=R8
	.DEF R0X9=R9
	.DEF R0XA=R10
	.DEF R0XB=R11
	.DEF R0XC=R12
	.DEF R0XD=R13
	.DEF R0XE=R14
	.DEF R0XF=R15
	.DEF R0X10=R16
	.DEF R0X11=R17
	.DEF R0X12=R18
	.DEF R0X13=R19
	.DEF R0X14=R20
	.DEF R0X15=R21
	.DEF R0X16=R22
	.DEF R0X17=R23
	.DEF R0X18=R24
	.DEF R0X19=R25
	.DEF R0X1A=R26
	.DEF R0X1B=R27
	.DEF R0X1C=R28
	.DEF R0X1D=R29
	.DEF R0X1E=R30
	.DEF R0X1F=R31

	.EQU __se_bit=0x40
	.EQU __sm_mask=0xB0
	.EQU __sm_adc_noise_red=0x10
	.EQU __sm_powerdown=0x20
	.EQU __sm_powersave=0x30
	.EQU __sm_standby=0xA0
	.EQU __sm_ext_standby=0xB0

	.MACRO __CPD1N
	CPI  R30,LOW(@0)
	LDI  R26,HIGH(@0)
	CPC  R31,R26
	LDI  R26,BYTE3(@0)
	CPC  R22,R26
	LDI  R26,BYTE4(@0)
	CPC  R23,R26
	.ENDM

	.MACRO __CPD2N
	CPI  R26,LOW(@0)
	LDI  R30,HIGH(@0)
	CPC  R27,R30
	LDI  R30,BYTE3(@0)
	CPC  R24,R30
	LDI  R30,BYTE4(@0)
	CPC  R25,R30
	.ENDM

	.MACRO __CPWRR
	CP   R@0,R@2
	CPC  R@1,R@3
	.ENDM

	.MACRO __CPWRN
	CPI  R@0,LOW(@2)
	LDI  R30,HIGH(@2)
	CPC  R@1,R30
	.ENDM

	.MACRO __ADDD1N
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	SBCI R22,BYTE3(-@0)
	SBCI R23,BYTE4(-@0)
	.ENDM

	.MACRO __ADDD2N
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	SBCI R24,BYTE3(-@0)
	SBCI R25,BYTE4(-@0)
	.ENDM

	.MACRO __SUBD1N
	SUBI R30,LOW(@0)
	SBCI R31,HIGH(@0)
	SBCI R22,BYTE3(@0)
	SBCI R23,BYTE4(@0)
	.ENDM

	.MACRO __SUBD2N
	SUBI R26,LOW(@0)
	SBCI R27,HIGH(@0)
	SBCI R24,BYTE3(@0)
	SBCI R25,BYTE4(@0)
	.ENDM

	.MACRO __ANDD1N
	ANDI R30,LOW(@0)
	ANDI R31,HIGH(@0)
	ANDI R22,BYTE3(@0)
	ANDI R23,BYTE4(@0)
	.ENDM

	.MACRO __ORD1N
	ORI  R30,LOW(@0)
	ORI  R31,HIGH(@0)
	ORI  R22,BYTE3(@0)
	ORI  R23,BYTE4(@0)
	.ENDM

	.MACRO __DELAY_USB
	LDI  R24,LOW(@0)
__DELAY_USB_LOOP:
	DEC  R24
	BRNE __DELAY_USB_LOOP
	.ENDM

	.MACRO __DELAY_USW
	LDI  R24,LOW(@0)
	LDI  R25,HIGH(@0)
__DELAY_USW_LOOP:
	SBIW R24,1
	BRNE __DELAY_USW_LOOP
	.ENDM

	.MACRO __CLRD1S
	LDI  R30,0
	STD  Y+@0,R30
	STD  Y+@0+1,R30
	STD  Y+@0+2,R30
	STD  Y+@0+3,R30
	.ENDM

	.MACRO __GETD1S
	LDD  R30,Y+@0
	LDD  R31,Y+@0+1
	LDD  R22,Y+@0+2
	LDD  R23,Y+@0+3
	.ENDM

	.MACRO __PUTD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R31
	STD  Y+@0+2,R22
	STD  Y+@0+3,R23
	.ENDM

	.MACRO __POINTB1MN
	LDI  R30,LOW(@0+@1)
	.ENDM

	.MACRO __POINTW1MN
	LDI  R30,LOW(@0+@1)
	LDI  R31,HIGH(@0+@1)
	.ENDM

	.MACRO __POINTW1FN
	LDI  R30,LOW(2*@0+@1)
	LDI  R31,HIGH(2*@0+@1)
	.ENDM

	.MACRO __POINTB2MN
	LDI  R26,LOW(@0+@1)
	.ENDM

	.MACRO __POINTW2MN
	LDI  R26,LOW(@0+@1)
	LDI  R27,HIGH(@0+@1)
	.ENDM

	.MACRO __POINTBRM
	LDI  R@0,LOW(@1)
	.ENDM

	.MACRO __POINTWRM
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __POINTBRMN
	LDI  R@0,LOW(@1+@2)
	.ENDM

	.MACRO __POINTWRMN
	LDI  R@0,LOW(@2+@3)
	LDI  R@1,HIGH(@2+@3)
	.ENDM

	.MACRO __GETD1N
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __GETD2N
	LDI  R26,LOW(@0)
	LDI  R27,HIGH(@0)
	LDI  R24,BYTE3(@0)
	LDI  R25,BYTE4(@0)
	.ENDM

	.MACRO __GETD2S
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	LDD  R24,Y+@0+2
	LDD  R25,Y+@0+3
	.ENDM

	.MACRO __GETB1MN
	LDS  R30,@0+@1
	.ENDM

	.MACRO __GETW1MN
	LDS  R30,@0+@1
	LDS  R31,@0+@1+1
	.ENDM

	.MACRO __GETD1MN
	LDS  R30,@0+@1
	LDS  R31,@0+@1+1
	LDS  R22,@0+@1+2
	LDS  R23,@0+@1+3
	.ENDM

	.MACRO __GETBRMN
	LDS  R@2,@0+@1
	.ENDM

	.MACRO __GETWRMN
	LDS  R@2,@0+@1
	LDS  R@3,@0+@1+1
	.ENDM

	.MACRO __GETWRZ
	LDD  R@0,Z+@2
	LDD  R@1,Z+@2+1
	.ENDM

	.MACRO __GETB2MN
	LDS  R26,@0+@1
	.ENDM

	.MACRO __GETW2MN
	LDS  R26,@0+@1
	LDS  R27,@0+@1+1
	.ENDM

	.MACRO __GETD2MN
	LDS  R26,@0+@1
	LDS  R27,@0+@1+1
	LDS  R24,@0+@1+2
	LDS  R25,@0+@1+3
	.ENDM

	.MACRO __PUTB1MN
	STS  @0+@1,R30
	.ENDM

	.MACRO __PUTW1MN
	STS  @0+@1,R30
	STS  @0+@1+1,R31
	.ENDM

	.MACRO __PUTD1MN
	STS  @0+@1,R30
	STS  @0+@1+1,R31
	STS  @0+@1+2,R22
	STS  @0+@1+3,R23
	.ENDM

	.MACRO __PUTDZ2
	STD  Z+@0,R26
	STD  Z+@0+1,R27
	STD  Z+@0+2,R24
	STD  Z+@0+3,R25
	.ENDM

	.MACRO __PUTBMRN
	STS  @0+@1,R@2
	.ENDM

	.MACRO __PUTWMRN
	STS  @0+@1,R@2
	STS  @0+@1+1,R@3
	.ENDM

	.MACRO __PUTBZR
	STD  Z+@1,R@0
	.ENDM

	.MACRO __PUTWZR
	STD  Z+@2,R@0
	STD  Z+@2+1,R@1
	.ENDM

	.MACRO __GETW1R
	MOV  R30,R@0
	MOV  R31,R@1
	.ENDM

	.MACRO __GETW2R
	MOV  R26,R@0
	MOV  R27,R@1
	.ENDM

	.MACRO __GETWRN
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __PUTW1R
	MOV  R@0,R30
	MOV  R@1,R31
	.ENDM

	.MACRO __PUTW2R
	MOV  R@0,R26
	MOV  R@1,R27
	.ENDM

	.MACRO __ADDWRN
	SUBI R@0,LOW(-@2)
	SBCI R@1,HIGH(-@2)
	.ENDM

	.MACRO __ADDWRR
	ADD  R@0,R@2
	ADC  R@1,R@3
	.ENDM

	.MACRO __SUBWRN
	SUBI R@0,LOW(@2)
	SBCI R@1,HIGH(@2)
	.ENDM

	.MACRO __SUBWRR
	SUB  R@0,R@2
	SBC  R@1,R@3
	.ENDM

	.MACRO __ANDWRN
	ANDI R@0,LOW(@2)
	ANDI R@1,HIGH(@2)
	.ENDM

	.MACRO __ANDWRR
	AND  R@0,R@2
	AND  R@1,R@3
	.ENDM

	.MACRO __ORWRN
	ORI  R@0,LOW(@2)
	ORI  R@1,HIGH(@2)
	.ENDM

	.MACRO __ORWRR
	OR   R@0,R@2
	OR   R@1,R@3
	.ENDM

	.MACRO __EORWRR
	EOR  R@0,R@2
	EOR  R@1,R@3
	.ENDM

	.MACRO __GETWRS
	LDD  R@0,Y+@2
	LDD  R@1,Y+@2+1
	.ENDM

	.MACRO __PUTWSR
	STD  Y+@2,R@0
	STD  Y+@2+1,R@1
	.ENDM

	.MACRO __MOVEWRR
	MOV  R@0,R@2
	MOV  R@1,R@3
	.ENDM

	.MACRO __INWR
	IN   R@0,@2
	IN   R@1,@2+1
	.ENDM

	.MACRO __OUTWR
	OUT  @2+1,R@1
	OUT  @2,R@0
	.ENDM

	.MACRO __CALL1MN
	LDS  R30,@0+@1
	LDS  R31,@0+@1+1
	ICALL
	.ENDM


	.MACRO __CALL1FN
	LDI  R30,LOW(2*@0+@1)
	LDI  R31,HIGH(2*@0+@1)
	CALL __GETW1PF
	ICALL
	.ENDM


	.MACRO __CALL2EN
	LDI  R26,LOW(@0+@1)
	LDI  R27,HIGH(@0+@1)
	CALL __EEPROMRDW
	ICALL
	.ENDM


	.MACRO __GETW1STACK
	IN   R26,SPL
	IN   R27,SPH
	ADIW R26,@0+1
	LD   R30,X+
	LD   R31,X
	.ENDM

	.MACRO __NBST
	BST  R@0,@1
	IN   R30,SREG
	LDI  R31,0x40
	EOR  R30,R31
	OUT  SREG,R30
	.ENDM


	.MACRO __PUTB1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RNS
	MOVW R26,R@0
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	CALL __PUTDP1
	.ENDM


	.MACRO __GETB1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R30,Z
	.ENDM

	.MACRO __GETW1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z+
	LD   R23,Z
	MOVW R30,R0
	.ENDM

	.MACRO __GETB2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R26,X
	.ENDM

	.MACRO __GETW2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	.ENDM

	.MACRO __GETD2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R1,X+
	LD   R24,X+
	LD   R25,X
	MOVW R26,R0
	.ENDM

	.MACRO __GETBRSX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	LD   R@0,Z
	.ENDM

	.MACRO __GETWRSX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	LD   R@0,Z+
	LD   R@1,Z
	.ENDM

	.MACRO __LSLW8SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	CLR  R30
	.ENDM

	.MACRO __PUTB1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __CLRW1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	CLR  R0
	ST   Z+,R0
	ST   Z,R0
	.ENDM

	.MACRO __CLRD1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	CLR  R0
	ST   Z+,R0
	ST   Z+,R0
	ST   Z+,R0
	ST   Z,R0
	.ENDM

	.MACRO __PUTB2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R26
	.ENDM

	.MACRO __PUTW2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z,R27
	.ENDM

	.MACRO __PUTBSRX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R@1
	.ENDM

	.MACRO __PUTWSRX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	ST   Z+,R@0
	ST   Z,R@1
	.ENDM

	.MACRO __PUTB1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __MULBRR
	MULS R@0,R@1
	MOV  R30,R0
	.ENDM

	.MACRO __MULBRRU
	MUL  R@0,R@1
	MOV  R30,R0
	.ENDM

	.CSEG
	.ORG 0

	.INCLUDE "encoder1.vec"
	.INCLUDE "encoder1.inc"

__RESET:
	CLI
	CLR  R30
	OUT  EECR,R30

;INTERRUPT VECTORS ARE PLACED
;AT THE START OF FLASH
	LDI  R31,1
	OUT  GICR,R31
	OUT  GICR,R30
	OUT  MCUCR,R30

;DISABLE WATCHDOG
	LDI  R31,0x18
	OUT  WDTCR,R31
	OUT  WDTCR,R30

;CLEAR R2-R14
	LDI  R24,13
	LDI  R26,2
	CLR  R27
__CLEAR_REG:
	ST   X+,R30
	DEC  R24
	BRNE __CLEAR_REG

;CLEAR SRAM
	LDI  R24,LOW(0x400)
	LDI  R25,HIGH(0x400)
	LDI  R26,0x60
__CLEAR_SRAM:
	ST   X+,R30
	SBIW R24,1
	BRNE __CLEAR_SRAM

;GLOBAL VARIABLES INITIALIZATION
	LDI  R30,LOW(__GLOBAL_INI_TBL*2)
	LDI  R31,HIGH(__GLOBAL_INI_TBL*2)
__GLOBAL_INI_NEXT:
	LPM  R24,Z+
	LPM  R25,Z+
	SBIW R24,0
	BREQ __GLOBAL_INI_END
	LPM  R26,Z+
	LPM  R27,Z+
	LPM  R0,Z+
	LPM  R1,Z+
	MOVW R22,R30
	MOVW R30,R0
__GLOBAL_INI_LOOP:
	LPM  R0,Z+
	ST   X+,R0
	SBIW R24,1
	BRNE __GLOBAL_INI_LOOP
	MOVW R30,R22
	RJMP __GLOBAL_INI_NEXT
__GLOBAL_INI_END:

;STACK POINTER INITIALIZATION
	LDI  R30,LOW(0x45F)
	OUT  SPL,R30
	LDI  R30,HIGH(0x45F)
	OUT  SPH,R30

;DATA STACK POINTER INITIALIZATION
	LDI  R28,LOW(0x160)
	LDI  R29,HIGH(0x160)

	JMP  _main

	.ESEG
	.ORG 0

	.DSEG
	.ORG 0x160
;       1 /*****************************************************
;       2 This program was produced by the
;       3 CodeWizardAVR V1.24.4 Standard
;       4 Automatic Program Generator
;       5 © Copyright 1998-2004 Pavel Haiduc, HP InfoTech s.r.l.
;       6 http://www.hpinfotech.com
;       7 e-mail:office@hpinfotech.com
;       8 
;       9 Project : 
;      10 Version : 
;      11 Date    : 08.12.2008
;      12 Author  : GNN                             
;      13 Company : t                               
;      14 Comments: 
;      15 
;      16 
;      17 Chip type           : ATmega16
;      18 Program type        : Application
;      19 Clock frequency     : 7,372800 MHz
;      20 Memory model        : Small
;      21 External SRAM size  : 0
;      22 Data Stack size     : 256
;      23 *****************************************************/
;      24 
;      25 #include <mega16.h>
;      26 
;      27 // External Interrupt 0 service routine
;      28 interrupt [EXT_INT0] void ext_int0_isr(void)
;      29 {

	.CSEG
_ext_int0_isr:
	ST   -Y,R30
	ST   -Y,R31
;      30 // Place your code here
;      31 volatile EncoderStateType EncoderState[NUM_ENCODERS];
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
;      32 }
	LD   R31,Y+
	LD   R30,Y+
	RETI
;      33 
;      34 // Standard Input/Output functions
;      35 #include <stdio.h>
;      36 // Global variables
;      37 #define CYCLES_PER_US ((F_CPU+500000)/1000000) 	// cpu cycles per microsecond  
;      38 #define NUM_ENCODERS				2
;      39 
;      40 // Functions
;      41 
;      42 // encoderInit() initializes hardware and encoder position readings
;      43 //		Run this init routine once before using any other encoder functions.
;      44 void encoderInit(void)
;      45 {
;      46 	u08 i;
;      47 
;      48 	// initialize/clear encoder data
;      49 	for(i=0; i<NUM_ENCODERS; i++)
;      50 	{
;      51 		EncoderState[i].position = 0;
;      52 		//EncoderState[i].velocity = 0;		// NOT CURRENTLY USED
;      53 	}
;      54 
;      55 	// configure direction and interrupt I/O pins:
;      56 	// - for input
;      57 	// - apply pullup resistors
;      58 	// - any-edge interrupt triggering
;      59 	// - enable interrupt
;      60 
;      61 	#ifdef ENC0_SIGNAL
;      62 		// set interrupt pins to input and apply pullup resistor
;      63 		cbi(ENC0_PHASEA_DDR, ENC0_PHASEA_PIN);
;      64 		sbi(ENC0_PHASEA_PORT, ENC0_PHASEA_PIN);
;      65 		// set encoder direction pin for input and apply pullup resistor
;      66 		cbi(ENC0_PHASEB_DDR, ENC0_PHASEB_PIN);
;      67 		sbi(ENC0_PHASEB_PORT, ENC0_PHASEB_PIN);
;      68 		// configure interrupts for any-edge triggering
;      69 		sbi(ENC0_ICR, ENC0_ISCX0);
;      70 		cbi(ENC0_ICR, ENC0_ISCX1);
;      71 		// enable interrupts
;      72 		sbi(IMSK, ENC0_INT);	// ISMK is auto-defined in encoder.h
;      73 	#endif
;      74 	#ifdef ENC1_SIGNAL
;      75 		// set interrupt pins to input and apply pullup resistor
;      76 		cbi(ENC1_PHASEA_DDR, ENC1_PHASEA_PIN);
;      77 		sbi(ENC1_PHASEA_PORT, ENC1_PHASEA_PIN);
;      78 		// set encoder direction pin for input and apply pullup resistor
;      79 		cbi(ENC1_PHASEB_DDR, ENC1_PHASEB_PIN);
;      80 		sbi(ENC1_PHASEB_PORT, ENC1_PHASEB_PIN);
;      81 		// configure interrupts for any-edge triggering
;      82 		sbi(ENC1_ICR, ENC1_ISCX0);
;      83 		cbi(ENC1_ICR, ENC1_ISCX1);
;      84 		// enable interrupts
;      85 		sbi(IMSK, ENC1_INT);	// ISMK is auto-defined in encoder.h
;      86 	#endif
;      87 	#ifdef ENC2_SIGNAL
;      88 		// set interrupt pins to input and apply pullup resistor
;      89 		cbi(ENC2_PHASEA_DDR, ENC2_PHASEA_PIN);
;      90 		sbi(ENC2_PHASEA_PORT, ENC2_PHASEA_PIN);
;      91 		// set encoder direction pin for input and apply pullup resistor
;      92 		cbi(ENC2_PHASEB_DDR, ENC2_PHASEB_PIN);
;      93 		sbi(ENC2_PHASEB_PORT, ENC2_PHASEB_PIN);
;      94 		// configure interrupts for any-edge triggering
;      95 		sbi(ENC2_ICR, ENC2_ISCX0);
;      96 		cbi(ENC2_ICR, ENC2_ISCX1);
;      97 		// enable interrupts
;      98 		sbi(IMSK, ENC2_INT);	// ISMK is auto-defined in encoder.h
;      99 	#endif
;     100 	#ifdef ENC3_SIGNAL
;     101 		// set interrupt pins to input and apply pullup resistor
;     102 		cbi(ENC3_PHASEA_DDR, ENC3_PHASEA_PIN);
;     103 		sbi(ENC3_PHASEA_PORT, ENC3_PHASEA_PIN);
;     104 		// set encoder direction pin for input and apply pullup resistor
;     105 		cbi(ENC3_PHASEB_DDR, ENC3_PHASEB_PIN);
;     106 		sbi(ENC3_PHASEB_PORT, ENC3_PHASEB_PIN);
;     107 		// configure interrupts for any-edge triggering
;     108 		sbi(ENC3_ICR, ENC3_ISCX0);
;     109 		cbi(ENC3_ICR, ENC3_ISCX1);
;     110 		// enable interrupts
;     111 		sbi(IMSK, ENC3_INT);	// ISMK is auto-defined in encoder.h
;     112 	#endif
;     113 	
;     114 	// enable global interrupts
;     115 	sei();
;     116 }
;     117 
;     118 // encoderOff() disables hardware and stops encoder position updates
;     119 void encoderOff(void)
;     120 {
;     121 	// disable encoder interrupts
;     122 	#ifdef ENC0_SIGNAL
;     123 		// disable interrupts
;     124 		sbi(IMSK, INT0);	// ISMK is auto-defined in encoder.h
;     125 	#endif
;     126 	#ifdef ENC1_SIGNAL
;     127 		// disable interrupts
;     128 		sbi(IMSK, INT1);	// ISMK is auto-defined in encoder.h
;     129 	#endif
;     130 	#ifdef ENC2_SIGNAL
;     131 		// disable interrupts
;     132 		sbi(IMSK, INT2);	// ISMK is auto-defined in encoder.h
;     133 	#endif
;     134 	#ifdef ENC3_SIGNAL
;     135 		// disable interrupts
;     136 		sbi(IMSK, INT3);	// ISMK is auto-defined in encoder.h
;     137 	#endif
;     138 }
;     139 
;     140 // encoderGetPosition() reads the current position of the encoder 
;     141 s32 encoderGetPosition(u08 encoderNum)
;     142 {  if(encoderNum < NUM_ENCODERS)
;     143 		return EncoderState[encoderNum].position;
;     144 	else
;     145 		return 0;
;     146 	// sanity check
;     147 	
;     148 }
;     149 
;     150 // encoderSetPosition() sets the current position of the encoder
;     151 void encoderSetPosition(u08 encoderNum, s32 position)
;     152 {       	if(encoderNum < NUM_ENCODERS)
;     153 		EncoderState[encoderNum].position = position;
;     154 	// sanity check
;     155 
;     156 	// else do nothing
;     157 }
;     158 
;     159 #ifdef ENC0_SIGNAL
;     160 //! Encoder 0 interrupt handler
;     161 SIGNAL(ENC0_SIGNAL)
;     162 {
;     163 	// encoder has generated a pulse
;     164 	// check the relative phase of the input channels
;     165 	// and update position accordingly
;     166 	if( ((inb(ENC0_PHASEA_PORTIN) & (1<<ENC0_PHASEA_PIN)) == 0) ^
;     167 		((inb(ENC0_PHASEB_PORTIN) & (1<<ENC0_PHASEB_PIN)) == 0) )
;     168 	{
;     169 		EncoderState[0].position++;
;     170 	}
;     171 	else
;     172 	{
;     173 		EncoderState[0].position--;
;     174 	}
;     175 }
;     176 #endif
;     177 
;     178 #ifdef ENC1_SIGNAL
;     179 //! Encoder 1 interrupt handler
;     180 SIGNAL(ENC1_SIGNAL)
;     181 {
;     182 	// encoder has generated a pulse
;     183 	// check the relative phase of the input channels
;     184 	// and update position accordingly
;     185 	if( ((inb(ENC1_PHASEA_PORTIN) & (1<<ENC1_PHASEA_PIN)) == 0) ^
;     186 		((inb(ENC1_PHASEB_PORTIN) & (1<<ENC1_PHASEB_PIN)) == 0) )
;     187 	{
;     188 		EncoderState[1].position++;
;     189 	}
;     190 	else
;     191 	{
;     192 		EncoderState[1].position--;
;     193 	}
;     194 }
;     195 #endif
;     196 
;     197 #ifdef ENC2_SIGNAL
;     198 //! Encoder 2 interrupt handler
;     199 SIGNAL(ENC2_SIGNAL)
;     200 {
;     201 	// encoder has generated a pulse
;     202 	// check the relative phase of the input channels
;     203 	// and update position accordingly
;     204 	if( ((inb(ENC2_PHASEA_PORTIN) & (1<<ENC2_PHASEA_PIN)) == 0) ^
;     205 		((inb(ENC2_PHASEB_PORTIN) & (1<<ENC2_PHASEB_PIN)) == 0) )
;     206 	{
;     207 		EncoderState[2].position++;
;     208 	}
;     209 	else
;     210 	{
;     211 		EncoderState[2].position--;
;     212 	}
;     213 }
;     214 #endif
;     215 
;     216 #ifdef ENC3_SIGNAL
;     217 //! Encoder 3 interrupt handler
;     218 SIGNAL(ENC3_SIGNAL)
;     219 {
;     220 	// encoder has generated a pulse
;     221 	// check the relative phase of the input channels
;     222 	// and update position accordingly
;     223 	if( ((inb(ENC3_PHASEA_PORTIN) & (1<<ENC3_PHASEA_PIN)) == 0) ^
;     224 		((inb(ENC3_PHASEB_PORTIN) & (1<<ENC3_PHASEB_PIN)) == 0) )
;     225 	{
;     226 		EncoderState[3].position++;
;     227 	}
;     228 	else
;     229 	{
;     230 		EncoderState[3].position--;
;     231 	}
;     232 }
;     233 #endif
;     234 
;     235 // Declare your global variables here
;     236 
;     237 void main(void)
;     238 {
_main:
;     239 // Declare your local variables here
;     240 
;     241 
;     242 
;     243 // -------------------- Encoder 0 connections --------------------
;     244 // Phase A quadrature encoder output should connect to this interrupt line:
;     245 // *** NOTE: the choice of interrupt PORT, DDR, and PIN must match the external
;     246 // interrupt you are using on your processor.  Consult the External Interrupts
;     247 // section of your processor's datasheet for more information.
;     248 
;     249 // Interrupt Configuration
;     250 #define ENC0_SIGNAL					SIG_INTERRUPT0	// Interrupt signal name
;     251 #define ENC0_INT					INT0	// matching INTx bit in GIMSK/EIMSK
;     252 #define ENC0_ICR					MCUCR	// matching Int. Config Register (MCUCR,EICRA/B)
;     253 #define ENC0_ISCX0					ISC00	// matching Interrupt Sense Config bit0
;     254 #define ENC0_ISCX1					ISC01	// matching Interrupt Sense Config bit1
;     255 // PhaseA Port/Pin Configuration
;     256 // *** PORTx, DDRx, PINx, and Pxn should all have the same letter for "x" ***
;     257 #define ENC0_PHASEA_PORT			PORTD	// PhaseA port register
;     258 #define ENC0_PHASEA_DDR				DDRD	// PhaseA port direction register
;     259 #define ENC0_PHASEA_PORTIN			PIND	// PhaseA port input register
;     260 #define ENC0_PHASEA_PIN				PD2		// PhaseA port pin
;     261 // Phase B quadrature encoder output should connect to this direction line:
;     262 // *** PORTx, DDRx, PINx, and Pxn should all have the same letter for "x" ***
;     263 #define ENC0_PHASEB_PORT			PORTC	// PhaseB port register
;     264 #define ENC0_PHASEB_DDR				DDRC	// PhaseB port direction register
;     265 #define ENC0_PHASEB_PORTIN			PINC	// PhaseB port input register
;     266 #define ENC0_PHASEB_PIN				PC0		// PhaseB port pin
;     267 
;     268 
;     269 // -------------------- Encoder 1 connections --------------------
;     270 // Phase A quadrature encoder output should connect to this interrupt line:
;     271 // *** NOTE: the choice of interrupt pin and port must match the external
;     272 // interrupt you are using on your processor.  Consult the External Interrupts
;     273 // section of your processor's datasheet for more information.
;     274 
;     275 // Interrupt Configuration
;     276 #define ENC1_SIGNAL					SIG_INTERRUPT1	// Interrupt signal name
;     277 #define ENC1_INT					INT1	// matching INTx bit in GIMSK/EIMSK
;     278 #define ENC1_ICR					MCUCR	// matching Int. Config Register (MCUCR,EICRA/B)
;     279 #define ENC1_ISCX0					ISC10	// matching Interrupt Sense Config bit0
;     280 #define ENC1_ISCX1					ISC11	// matching Interrupt Sense Config bit1
;     281 // PhaseA Port/Pin Configuration
;     282 // *** PORTx, DDRx, PINx, and Pxn should all have the same letter for "x" ***
;     283 #define ENC1_PHASEA_PORT			PORTD	// PhaseA port register
;     284 #define ENC1_PHASEA_PORTIN			PIND	// PhaseA port input register
;     285 #define ENC1_PHASEA_DDR				DDRD	// PhaseA port direction register
;     286 #define ENC1_PHASEA_PIN				PD3		// PhaseA port pin
;     287 // Phase B quadrature encoder output should connect to this direction line:
;     288 // *** PORTx, DDRx, PINx, and Pxn should all have the same letter for "x" ***
;     289 #define ENC1_PHASEB_PORT			PORTC	// PhaseB port register
;     290 #define ENC1_PHASEB_DDR				DDRC	// PhaseB port direction register
;     291 #define ENC1_PHASEB_PORTIN			PINC	// PhaseB port input register
;     292 #define ENC1_PHASEB_PIN				PC1		// PhaseB port pin
;     293 // Input/Output Ports initialization
;     294 // Port A initialization
;     295 // Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In 
;     296 // State7=T State6=T State5=T State4=T State3=T State2=T State1=T State0=T 
;     297 PORTA=0x00;
	LDI  R30,LOW(0)
	OUT  0x1B,R30
;     298 DDRA=0x00;
	OUT  0x1A,R30
;     299 
;     300 // Port B initialization
;     301 // Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In 
;     302 // State7=T State6=T State5=T State4=T State3=T State2=T State1=T State0=T 
;     303 PORTB=0x00;
	OUT  0x18,R30
;     304 DDRB=0x00;
	OUT  0x17,R30
;     305 
;     306 // Port C initialization
;     307 // Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In 
;     308 // State7=T State6=T State5=T State4=T State3=T State2=T State1=T State0=P 
;     309 PORTC=0x01;
	LDI  R30,LOW(1)
	OUT  0x15,R30
;     310 DDRC=0x00;
	LDI  R30,LOW(0)
	OUT  0x14,R30
;     311 
;     312 // Port D initialization
;     313 // Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In 
;     314 // State7=T State6=T State5=T State4=T State3=T State2=P State1=T State0=T 
;     315 PORTD=0x04;
	LDI  R30,LOW(4)
	OUT  0x12,R30
;     316 DDRD=0x00;
	LDI  R30,LOW(0)
	OUT  0x11,R30
;     317 
;     318 // Timer/Counter 0 initialization
;     319 // Clock source: System Clock
;     320 // Clock value: Timer 0 Stopped
;     321 // Mode: Normal top=FFh
;     322 // OC0 output: Disconnected
;     323 TCCR0=0x00;
	OUT  0x33,R30
;     324 TCNT0=0x00;
	OUT  0x32,R30
;     325 OCR0=0x00;
	OUT  0x3C,R30
;     326 
;     327 // Timer/Counter 1 initialization
;     328 // Clock source: System Clock
;     329 // Clock value: Timer 1 Stopped
;     330 // Mode: Normal top=FFFFh
;     331 // OC1A output: Discon.
;     332 // OC1B output: Discon.
;     333 // Noise Canceler: Off
;     334 // Input Capture on Falling Edge
;     335 TCCR1A=0x00;
	OUT  0x2F,R30
;     336 TCCR1B=0x00;
	OUT  0x2E,R30
;     337 TCNT1H=0x00;
	OUT  0x2D,R30
;     338 TCNT1L=0x00;
	OUT  0x2C,R30
;     339 ICR1H=0x00;
	OUT  0x27,R30
;     340 ICR1L=0x00;
	OUT  0x26,R30
;     341 OCR1AH=0x00;
	OUT  0x2B,R30
;     342 OCR1AL=0x00;
	OUT  0x2A,R30
;     343 OCR1BH=0x00;
	OUT  0x29,R30
;     344 OCR1BL=0x00;
	OUT  0x28,R30
;     345 
;     346 // Timer/Counter 2 initialization
;     347 // Clock source: System Clock
;     348 // Clock value: Timer 2 Stopped
;     349 // Mode: Normal top=FFh
;     350 // OC2 output: Disconnected
;     351 ASSR=0x00;
	OUT  0x22,R30
;     352 TCCR2=0x00;
	OUT  0x25,R30
;     353 TCNT2=0x00;
	OUT  0x24,R30
;     354 OCR2=0x00;
	OUT  0x23,R30
;     355 
;     356 // External Interrupt(s) initialization
;     357 // INT0: On
;     358 // INT0 Mode: Any change
;     359 // INT1: Off
;     360 // INT2: Off
;     361 GICR|=0x40;
	IN   R30,0x3B
	ORI  R30,0x40
	OUT  0x3B,R30
;     362 MCUCR=0x01;
	LDI  R30,LOW(1)
	OUT  0x35,R30
;     363 MCUCSR=0x00;
	LDI  R30,LOW(0)
	OUT  0x34,R30
;     364 GIFR=0x40;
	LDI  R30,LOW(64)
	OUT  0x3A,R30
;     365 
;     366 // Timer(s)/Counter(s) Interrupt(s) initialization
;     367 TIMSK=0x00;
	LDI  R30,LOW(0)
	OUT  0x39,R30
;     368 
;     369 // USART initialization
;     370 // Communication Parameters: 8 Data, 1 Stop, No Parity
;     371 // USART Receiver: Off
;     372 // USART Transmitter: On
;     373 // USART Mode: Asynchronous
;     374 // USART Baud rate: 9600
;     375 UCSRA=0x00;
	OUT  0xB,R30
;     376 UCSRB=0x08;
	LDI  R30,LOW(8)
	OUT  0xA,R30
;     377 UCSRC=0x86;
	LDI  R30,LOW(134)
	OUT  0x20,R30
;     378 UBRRH=0x00;
	LDI  R30,LOW(0)
	OUT  0x20,R30
;     379 UBRRL=0x2F;
	LDI  R30,LOW(47)
	OUT  0x9,R30
;     380 
;     381 // Analog Comparator initialization
;     382 // Analog Comparator: Off
;     383 // Analog Comparator Input Capture by Timer/Counter 1: Off
;     384 ACSR=0x80;
	LDI  R30,LOW(128)
	OUT  0x8,R30
;     385 SFIOR=0x00;
	LDI  R30,LOW(0)
	OUT  0x30,R30
;     386 
;     387 // Global enable interrupts
;     388 #asm("sei")
	sei
;     389 
;     390 while (1)
_0x8:
;     391       {
;     392       // Place your code here
;     393 
;     394       };
	RJMP _0x8
;     395 }
_0xB:
	RJMP _0xB

;END OF CODE MARKER
__END_OF_CODE:
