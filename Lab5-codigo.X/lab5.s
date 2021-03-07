;*******************************************************************************
; Archivo: Lab5.s
; Dispositivo: PIC16F887
; Autor: Danika Andrino
; Carnet: 19487
; Compilador: pic-as (v2.30), MPLABX v5.45
    
; Programa: 
; Hardware: 	

; Creado: 3 de mar, 2021
;Ultima modificacion:  3 mar, 2021

  
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
    
    PSECT   udata_bank0
	var:	     DS 1
	ban:	     DS 1
	nibble:	     DS 2
	display_var: DS 2
    
    PSECT   udata_shr
	W_TEMP:		DS 1
	STATUS_TEMP:	DS 1
    
    restart_tmr0    macro
	banksel	    PORTA	
	movlw	    61
	movwf	    TMR0
	bcf	    T0IF
	endm
    
;------------Vector reset-------------------------------------------------------
    
    PSECT resVect, class=CODE, abs, delta=2
	ORG 00h
    resectVect:
	PAGESEL main
	goto	main
	
;------------Vector interruptor-------------------------------------------------
	
    PSECT   inVect, class=CODE, abs, delta=2
    ORG 04h
    
    push:
	movwf	    W_TEMP
	swapf	    STATUS, W
	movwf	    STATUS_TEMP
	
    isr:
	btfsc	    RBIF
	call	    int_iocb
	btfsc	    T0IF
	call	    int_t0
    
    pop:
	swapf	    STATUS_TEMP, W
	movwf	    STATUS
	swapf	    W_TEMP, F
	swapf	    W_TEMP, W
	retfie
    
;---------subrutina interrupcion------------------------------------------------
    
    int_t0:
	restart_tmr0
	clrf	PORTD
	btfsc	ban, 0
	goto	display_1
	;goto	display_0
    display_0:
	movf	display_var, W
	movwf	PORTC
	bsf	PORTD, 0
	goto	siguiente_display
	
    display_1:
	movf	display_var + 1, W
	movwf	PORTC
	bsf	PORTD, 1
	
    siguiente_display:
	movlw	1
	xorwf	ban, F
	return
	
	
	
    int_iocb:
	banksel	    PORTA	    ;si el puertob UP se activa
	btfss	    PORTB, UP	    ;incrementa el porta
	incf	    PORTA
	btfss	    PORTB, DOWN	    ;si el puertob DOWN se activa
	decf	    PORTA	    ;decrementa el porta
	bcf	    RBIF
	return

;---------Codigo principal------------------------------------------------------
 
PSECT	code, delta=2, abs
ORG 100h
	
	tabla:
	    clrf	    PCLATH
	    bsf		    PCLATH, 0	;pclath= 01, pcl = 02
	    andlw	    0x0f
	    addwf	    PCL		;pc = pclath + pcl + w
	    retlw	    00111111B	;0
	    retlw	    00000110B	;1
	    retlw	    01011011B	;2
	    retlw	    01001111B	;3
	    retlw	    01100110B	;4
	    retlw	    01101101B	;5
	    retlw	    01111101B	;6
	    retlw	    00000111B	;7
	    retlw	    01111111B	;8
	    retlw	    01101111B	;9
	    retlw	    01110111B	;A
	    retlw	    01111100B	;B
	    retlw	    00111001B	;c
	    retlw	    01011110B	;d
	    retlw	    01111001B	;E
	    retlw	    01110001B	;F
	    
;----------------configuracion--------------------------------------------------
 
    main:
	call	    config_io   
	call	    config_reloj
	call	    config_iocrb
	call	    config_tmr0
	banksel	    PORTA
    loop:
	movlw	    0x24
	movwf	    var
	call	    separar_nibble
	call	    prep_diplays
	goto	    loop
    
;--------sub rutinas------------------------------------------------------------
    separar_nibble:
	movf	    var, W
	andlw	    0x0f
	movwf	    nibble
	swapf	    var,W
	andlw	    0x0f
	movwf	    nibble + 1
	return
	
    prep_diplays:
	movf	    nibble,W
	call	    tabla
	movwf	    display_var
	
	movf	    nibble + 1,W
	call	    tabla
	movwf	    display_var + 1
	return
	
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
	clrf	ANSEL
	clrf	ANSELH	    ;pines digitales
	
	bsf	STATUS, 5   ;banco 01
	bcf	STATUS, 6
	clrf	TRISA	    ;porta salida
	clrf	TRISC	    ;portc salida
	bsf	TRISB, UP   ;entrada
	bsf	TRISB, DOWN ;entrada
	bcf	TRISD, 0
	bcf	TRISD, 1
	
	bcf	OPTION_REG, 7	;habilitar pull ups
	bsf	WPUB, UP
	bsf	WPUB, DOWN
	
	bcf	STATUS, 5   ;banco 00
	bcf	STATUS, 6
	clrf	PORTA	
	clrf	PORTD
	
	return
    
    config_reloj:
	banksel	OSCCON
	bsf	IRCF2	
	bsf	IRCF1
	bcf	IRCF0		
	bsf	SCS	    ;reloj interno a 4M Hz
	return
	
    config_tmr0:
	banksel	    TRISA
	bcf	    T0CS
	bcf	    PSA
	bsf	    PS2
	bsf	    PS1
	bsf	    PS0
	restart_tmr0
	
	bsf	GIE		;intcon
	bsf	T0IE		;config int enable
	bcf	T0IF
	return

END