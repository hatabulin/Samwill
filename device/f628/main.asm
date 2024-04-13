;********************************************
;
; ДРАЙВЕР ЭНКОДЕРА
;
;
; File version 1.0
; Date begin:	14/04/2013
; Date end:	15/04/2013
; Last edition: 15/04/2013
;
; Author: Oborin Sergey
; UKRAINE, Lutsk
;
	list      	p=16f628	; Директива определения типа контроллера

;CONFIG      OSC=HS                       ; тактирование от кварца частотой 20МГц
;CONFIG      OSCS=OFF                ; запретить переключать частоту тактирования микроконтроллера
;CONFIG      PWRT=ON                      ; включать задержку на 72мс после включения питания      
;CONFIG      BOR=ON, BORV=45   ; схему сброса по провалу питания включить. Порог = 4,5В
; старайтесь использовать сторожевой таймер всегда!
;CONFIG      WDT=ON;, WDTPS=128 ; сторожевой таймер включить, период 2,3 сек
;CONFIG      STVR=ON                      ; по переполнению стека давать сброс микроконтроллера

	#include	<p16f628.inc>	; Подключаем стандартный файл заголовка MPLAB
	radix		hex		; Формат чисел по умолчанию - шестнадцатиричный

	

	
;------------------------------------------------------------------------------
	;Задание слова конфигурации (соответствия аббревиатур битам
	;			     см. в файле p16F84.inc)

;	__CONFIG _CP_OFF & _WDT_OFF
;	__CONFIG _CP_ON & _WDT_ON & _HS_OSC & _PWRT_ON


;------------------------------------------------------------------------------

;		--- КОНСТАНТЫ ---
F_OSC		equ		.20000000

;------------------------------------------------------------------------------

;		--- МАКРОКОМАНДЫ ---

;______________________________________________________________________________

;--------
; Start of available RAM.
;--------
;	cblock	0x21
;		safe_w		;not really temp, used by interrupt svc
;		safe_s		;not really temp, used by interrupt svc
;
;	endc
#define EXT_OUT0	PORTA,0;
#define EXT_OUT1	PORTA,1;

#define EXT_INT0	PORTB,0;
#define EXT_INT1	PORTB,1;

#define	JUMPER1		PORTB,2
#define	JUMPER2		PORTB,3

#define	ENC_PORT	PORTB

;#define PWM_INT_PIN PORTA,1

;
; Переменные
;
	CBLOCK	0Ch
	safe_w	:1
	safe_s	:1
	Reg_1	:1
	Reg_2	:1
	Reg_3	:1
	CurrentState	:1;
	OldState		:1;

	Q_1: 1;
	Q_NOW: 1;
	QUAD_ACT: 1;
	COUNT: 1;

	ENDC
;		--- ПУСК ---

		ORG	0x0000		; Вектор сброса - с этого адреса PIC
					; начинает выполнение программы
Reset	
		goto	Begin		; Безусловный переход на начало основной программы
					; (обходим обработчик прерываний и подпрограммы)

;------------------------------------------------------------------------------
;		--- ОБРАБОТЧИК ПРЕРЫВАНИЙ ---

		ORG	4			; Вектор прерываний - переход по этому адресу
;						; осуществляется аппаратно при установке флага
;						; запроса на любое незамаскированное прерывание,
;						; при этом аппаратно сбрасывается бит GIE
;
Interrupt	
		movwf	safe_w			; Сохранение контекста - содержимого регистров
		movf	STATUS,W		; W и STATUS, потому что оно может измениться
		movwf	safe_s			; в процессе работы обработчика прерываний
;
		clrwdt

;		Здесь будет располагаться сама подпрограмма обработки прерываний
ISR_0:
    ; ... test bit to see if it is set
    BTFSS   INTCON,T0IF     ; Timeer0 Overflow?
    GOTO    ISR_1           ; No, check next thing.
    ;
    ; Else process Timer 0 Overflow Interrupt
    ;
    BCF     INTCON, T0IF    ; Clear interrupt
    MOVLW   D'133'          ; Reset 1khz counter
    MOVWF   TMR0            ; Store it.

	call	Algo3
;    CALL    QUAD_STATE      ; Check Quadrature Encoders.

;	movwf	OldState

;	btfss	OldState,7
;	goto	CounterDec

;	btfss	OldState,1
;	goto	CounterInc

;    GOTO    ISR_1           ; Nope, keep counting
ISR_1:  
;
; Exit the interrupt service routine. 
; This involves recovering W and STATUS and then
; returning. Note that putting STATUS back 
; automatically pops the bank back as well.
;  This takes 6 Tcy for a total overhead of 12 Tcy for sync
;  interrupts and 13 Tcy for async interrupts.

End_int	
		movf	safe_s,W		; Восстанавливаем контекст
		movwf	STATUS	
		swapf	safe_w,F		; Тут приходится хитрить, чтобы сохранить бит Z в STATUS
		swapf	safe_w,W		; (movf его может изменить, а swapf - нет)
		retfie				; Возврат из обработчика с установкой бита GIE

;--------
; unused pins I am setting to be outputs
;--------
Port_init	
		
;		BANKSEL	trisa
		clrf	PORTA
		clrf	PORTB

		movlw	b'11111100'
		tris	PORTA; // PWM_PORT

		movlw	b'00001111'
		tris	PORTB

		retlw	0

Init
  ; * * * * * *
    ; * BANK 1 Operations
    ; * * * * * *
    BSF     STATUS,RP0      ; Set Bank 1
    MOVLW   B'0000100'      ; Set TMR0 prescaler to X
    MOVWF   OPTION_REG      ; Store it in the OPTION register
    ; * * * * * * * * * * *
    ; * BANK 0 Operations *
    ; * * * * * * * * * * *
    CLRF    STATUS          ; Back to BANK 0
    BSF     INTCON, T0IE    ; Enable Timer 0 to interrupt
    BCF     INTCON, T0IF    ; Reset interrupt flag
    BSF     INTCON, GIE     ; Enable interrupts
	retlw	0

Begin
		call	Port_init
		call	Init
		
MainCikl
		goto	MainCikl

Algo3
		movf	ENC_PORT,0		; in		r16,PinD			;загружаем значение порта D в регистр 
		andlw	3				;andi 	r16,0b00000011		;выделить два последних бита R16
		movwf	CurrentState
		subwf	OldState,0
		btfsc	STATUS,2
		goto	Algo3Exit
;switch OldState
CASE0
		movf	OldState,1
		btfss	STATUS,2
		goto	CASE1				;CASE 1
case_0
		movlw	2
		subwf	CurrentState,0
		btfss	STATUS,2
		goto	case_0_1
		goto	EncPlus
	
case_0_1
		movlw	1
		subwf	CurrentState,0
		btfss	STATUS,2
		goto	Algo3EndSwitch
		goto	EncMinus
CASE1
		movlw	1
		subwf	OldState,0
		btfss	STATUS,2
		goto	CASE2				; CASE 2
case_1
		movf	CurrentState,1
		btfss	STATUS,2
		goto	case_1_1
		goto	EncPlus
	
case_1_1
		movlw	3
		subwf	CurrentState,0
		btfss	STATUS,2
		goto	Algo3EndSwitch
		goto	EncMinus

CASE2
		movlw	2
		subwf	OldState,0
		btfss	STATUS,2
		goto	CASE3				; CASE 2
case_2
		movlw	3
		subwf	CurrentState,0
		btfss	STATUS,2
		goto	case_2_1
		goto	EncPlus
	
case_2_1
		movf	CurrentState,1
		btfss	STATUS,2
		goto	Algo3EndSwitch
		goto	EncMinus

CASE3
		movlw	3
		subwf	OldState,0
		btfss	STATUS,2
		goto	Algo3EndSwitch
case_3
		movlw	1
		subwf	CurrentState,0
		btfss	STATUS,2
		goto	case_3_1
		goto	EncPlus
	
case_3_1
		movlw	2
		subwf	CurrentState,0
		btfss	STATUS,2
		goto	Algo3EndSwitch

EncMinus
		incf	EncMinus
		goto	Algo3EndSwitch
EncPlus
		incf	EncPlus,1
		
Algo3EndSwitch
		movlw	4
		subwf	EncPlus,0
		btfss	STATUS,2
		goto	Algo3EndSwitch_1

		bcf		EXT_OUT0			; УВЕЛИЧИТЬ ТИПА КОНТЕР
		bsf		EXT_OUT0
		
		clrw
		movwf	EncPlus
		goto	Algo3EndSwitch_2

Algo3EndSwitch_1
		movlw	4
		subwf	EncMinus,0
		btfss	STATUS,2
		goto	Algo3EndSwitch_2

		bcf		EXT_OUT1
		bsf		EXT_OUT1

		clrw
		movwf	EncMinus

Algo3EndSwitch_2
		
		movf	CurrentState,0
		movwf	OldState
Algo3Exit
		return
Algo1:
		movf	ENC_PORT,0		; in		r16,PinD			;загружаем значение порта D в регистр 
		andlw	H'3'			;andi 	r16,0b00000011		;выделить два последних бита R16
		movwf	CurrentState
		subwf	OldState,0
		btfsc	STATUS,2
		goto	Exit

ScanEncoder:		
		btfsc	CurrentState,1; проверим B ;if (!now_b) // 1) B = 0
		goto	CheckNextDest

		btfss	CurrentState,0; проверим A; if (now_a) // 2) A = 1
		goto	CheckNextDest

		btfsc	OldState,0;		проверим CurrentA <> OldA (OldA = 0)
		goto	CheckNextDest

		btfss	CurrentState,1 ; проверим B на 1
		goto	ScanLabel_1

		btfss	OldState,1
		goto	CheckNextDest
		goto	CounterInc

ScanLabel_1
		btfsc	OldState,1
		goto	CheckNextDest
CounterInc
		bcf		EXT_OUT0
		bsf		EXT_OUT0
		goto	Exit

CheckNextDest
;		goto	Exit

		btfss	CurrentState,1; проверим B ;if (now_b) // 1) B = 1
		goto	CheckNextDest2

		btfsc	CurrentState,0; проверим A; if (now_a) // 2) A = 0
		goto	CheckNextDest2

		btfsc	OldState,0;		проверим CurrentA = OldA (OldA = 1)
		goto	CheckNextDest2

		btfss	CurrentState,1 ; проверим B на 1
		goto	ScanLabel_2

		btfsc	OldState,1
		goto	CheckNextDest2
		goto	CounterDec

ScanLabel_2
		btfss	OldState,1
		goto	CheckNextDest2
CounterDec
		bcf		EXT_OUT1
		bsf		EXT_OUT1
		goto	Exit
	
CheckNextDest2
Exit
		movf	CurrentState,0
		movwf	OldState
		goto	Algo1

Algo2

	movlw	0
	movwf	COUNT

Algo1_Loop
	call	QUAD_STATE
	movwf	OldState

	btfss	OldState,7
	goto	CounterDec

	btfss	OldState,1
	goto	CounterInc

	goto	Algo1_Loop
;
; QUAD State
;
; A quadrature encoder traverse a couple of states
; when it is rotating these are:
;       00      |  Counter
;       10      |  Clockwise
;       11      |     ^
;       01      V     |
;       00  Clockwise |
;
;
QUAD_STATE:
    BCF     STATUS,C        ; Force Carry to be zero
    MOVF    ENC_PORT,W         ; Read the encoder
    ANDLW   H'3'            ; And it with 0110
    MOVWF   Q_1             ; Store it
        
    RLF     Q_NOW,F         ; Rotate Q_NOW Left
    RLF     Q_NOW,W         ; by two 
    IORWF   Q_1,W           ; Or in the current value
    MOVWF   QUAD_ACT        ; Store at as next action
    MOVF    Q_1,W           ; Get last time
    MOVWF   Q_NOW           ; And store it.
;
; Return the value of what we should do to the 
; value to adjust it.
;        
QUAD_ACTION:        
    ;
    ; Computed jump based on Quadrature pin state.
    ;
    CLRF    PCLATH  ; Must be in page 0!!!
    ADDWF   PCL,F   ; Indirect jump
    RETLW   H'00'   ; 00 -> 00
    RETLW   H'FF'   ; 00 -> 01 -1
    RETLW   H'01'   ; 00 -> 10 +1
    RETLW   H'00'   ; 00 -> 11
    RETLW   H'01'   ; 01 -> 00 +1
    RETLW   H'00'   ; 01 -> 01
    RETLW   H'00'   ; 01 -> 10 
    RETLW   H'FF'   ; 01 -> 11 -1
    RETLW   H'FF'   ; 10 -> 00 -1
    RETLW   H'00'   ; 10 -> 01
    RETLW   H'00'   ; 10 -> 10
    RETLW   H'01'   ; 10 -> 11 +1
    RETLW   H'00'   ; 11 -> 00
    RETLW   H'01'   ; 11 -> 01 +1
    RETLW   H'FF'   ; 11 -> 10 -1
    RETLW   H'00'   ; 11 -> 11    ;

    ; Computed jump based on Quadrature pin state.
    ;
    MOVLW   high QUAD_STATE
    MOVWF   PCLATH
    MOVF    QUAD_ACT,W      ; Get button state
    ADDWF   PCL,F           ; Indirect jump
    RETURN                  ; 00 -> 00
    GOTO    DEC_COUNT       ; 00 -> 01 -1
    GOTO    INC_COUNT       ; 00 -> 10 +1
    RETURN                  ; 00 -> 11
    GOTO    INC_COUNT       ; 01 -> 00 +1
    RETURN                  ; 01 -> 01
    RETURN                  ; 01 -> 10 
    GOTO    DEC_COUNT       ; 01 -> 11 -1
    GOTO    DEC_COUNT       ; 10 -> 00 -1
    RETURN                  ; 10 -> 01
    RETURN                  ; 10 -> 10
    GOTO    INC_COUNT       ; 10 -> 11 +1
    RETURN                  ; 11 -> 00
    GOTO    INC_COUNT       ; 11 -> 01 +1
    GOTO    DEC_COUNT       ; 11 -> 10 -1
    RETURN                  ; 11 -> 11
INC_COUNT:
    INCF    COUNT,F
    MOVLW   D'201'
    SUBWF   COUNT,W
    BTFSS   STATUS,Z
    RETURN
    DECF    COUNT,F
    RETURN
DEC_COUNT
    DECF    COUNT,F
    MOVLW   H'FF'
    SUBWF   COUNT,W
    BTFSS   STATUS,Z
    RETURN          
    INCF    COUNT,F
    RETURN	
		

Del_500mks
; Задержка 2 500 машинных циклов
; Длительность задержки 500 микросекунд
; Частота задающего генератора 20 МГц

            movlw       .61
            movwf       Reg_1
            movlw       .4
            movwf       Reg_2
            decfsz      Reg_1,F
            goto        $-1
            decfsz      Reg_2,F
            goto        $-3
            nop
            nop			
			retlw	0

		END