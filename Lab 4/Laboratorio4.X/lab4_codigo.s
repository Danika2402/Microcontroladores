;*******************************************************************************
; Archivo: Lab4_codigo.s
; Dispositivo: PIC16F887
; Autor: Danika Andrino
; Carnet: 19487
; Compilador: pic-as (v2.30), MPLABX v5.45
    
; Programa: 
; Hardware: 

; Creado: 23 de feb, 2021
;Ultima modificacion:  123 feb, 2021

  
;*******************************************************************************
    
PROCESSOR 16F887
#include <xc.inc>
    
    ; Configuration word 1
    CONFIG FOSC=INTRC_NOCLKOUT // oscillador interno sin salida
    CONFIG WDTE=OFF	     // WDT disabled (reinicio repetitivo)
    CONFIG PWRTE=ON	    //PWT enabled (espera 72ms al iniciar)
    CONFIG MCLRE=OFF	    //pin mclr se utiliza como I/O
    CONFIG CP=OFF	    //sin proteccion de codigo
    CONFIG CPD=OFF	    //sin proteccion de datos
    
    CONFIG BOREN=OFF	    //sin reinicio si la alimentacion baja de 4V
    CONFIG IESO=OFF	    //reinicio sin cambio de reloj,interno a externo
    CONFIG FCMEN=OFF	    //cambio de reloj,ext. a intern., en caso de fallo
    CONFIG LVP=ON	    //programacion de bajo voltaje permitido
    
    ;configuracion word 2
    CONFIG WRT=OFF	    // proteccion de autoescritura desactivada
    CONFIG BOR4V=BOR40V	    // reinicio abajo de 4V, BOR21V=2.1V
    
    UP	    EQU 0
    DOWN    EQU 1
    
    PSECT udata_bank0 ;common memory
	cont:		DS 2; 2 byte
    
    PSECT udata_bank0	;common memory
	W_TEMP:		DS 1
	STATUS_TEMP:	DS 1
    
    PSECT resVect, class=CODE, abs, delta =2
 ;------------Vector reset------------------------------------------------------
    ORG 00h
    resetVec:
	PAGESEL main
	goto main
    
;------------Vector interruptor-------------------------------------------------
    push:
	movwf	    W_TEMP
	swapf	    STATUS, W
	movwf	    STATUS_TEMP
	
    isr:
	btfsc	    RBIF
	call	    int_iocb	
	
    pop:
	swapf	    STATUS_TEMP, W
	movwf	    STATUS
	swapf	    W_TEMP, F
	swapf	    W_TEMP, W
	retfie
;---------subrutina interrupcion------------------------------------------------
    int_iocb:
	banksel	    PORTB
	btfSS	    PORTB, UP
	incf	    PORTA
	btfss	    PORTB, DOWN
	decf	    PORTA
	bcf	    RBIF
	
    PSECT code, delta=2,abs
	ORG 100h
;----------------configuracion--------------------------------------------------
    main:
	call	config_io
	call	config_reloj
	call	config_iocrb
	call	config_int_enable
	banksel	PORTA
	
;--------sub rutinas------------------------------------------------------------
    config_iocrb:	
	banksel	    TRISA
	bsf	    IOCB, UP
	bsf	    IOCB, DOWN
	
	banksel	    PORTA
	movf	    PORTB, W	;termina condicion mismatch al leer
	bcf	    RBIF
	return
    
    config_io:
	bsf	STATUS, 5   ;banco11
	bsf	STATUS, 6
	clrf	 ANSEL
	clrf	ANSELH	    ;pines digitales
	
	bsf	STATUS, 5   ;banco 01
	bcf	STATUS, 6
	clrf	TRISA	    ;porta salida
	bsf	TRISB, UP   ;entrada
	bsf	TRISB, DOWN ;entrada
	
	bcf	OPTION_REG, 7	;habilitar pull ups
	bsf	WPUB, UP
	bsf	WPUB, DOWN
	
	bcf	STATUS, 5   ;banco 00
	bcf	STATUS, 6
	clrf	PORTA	    
	return
	
    config_reloj:
	banksel	OSCCON
	bsf	IRCF2	
	bsf	IRCF1
	bcf	IRCF0
	bsf	SCS	    ;4M Hz
	return
	
    config_int_enable:
	bsf	GIE	    ;intcon
	bsf	RBIE
	bcf	RBIF
	return
	
END