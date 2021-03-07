    ;Archivo:	    tmr0.s
    ;Dispositivo:   PIC16F887
    ;Autor:	    Danika Geraldine
    ;Compilador:    pic-as (v2.30), MPLABX V5.45
    ;
    ;Programa:	    incrementar porta cada 500ms con interrupcion
    ;Hardware:	    leds en porta
    ;
    ;Creado:		   24 feb, 2021
    ;Ultima modificacion:  24 feb, 2021
    
    
    ;***************************************************************************

    PROCESSOR 16F887
    #include <xc.inc>
    
     ; Configuration word 1
    CONFIG FOSC=INTRC_NOCLKOUT	// oscillador interno sin salida
    CONFIG WDTE=OFF		// WDT disabled (reinicio repetitivo)
    CONFIG PWRTE=ON		//PWT enabled (espera 72ms al iniciar)
    CONFIG MCLRE=OFF		//pin mclr se utiliza como I/O
    CONFIG CP=OFF		//sin proteccion de codigo
    CONFIG CPD=OFF		//sin proteccion de datos
    
    CONFIG BOREN=OFF		//sin reinicio si la alimentacion baja de 4V
    CONFIG IESO=OFF		//reinicio sin cambio de reloj,interno a externo
    CONFIG FCMEN=OFF		//cambio de reloj,ext. a intern., en caso de fallo
    CONFIG LVP=ON		//programacion de bajo voltaje permitido
    
    ;configuracion word 2
    CONFIG WRT=OFF		// proteccion de autoescritura desactivada
    CONFIG BOR4V=BOR40V		// reinicio abajo de 4V, BOR21V=2.1V
    
     PSECT udata_bank0 ;common memory
	
	cont:		DS 2
    
    PSECT udata_shr	;commom memory
	W_TEMP:		DS 1
	STATUS_TEMP:	DS 1
    
    PSECT resVect, class=CODE, abs, delta=2
    ;------------Vector reset---------------------------------------------------
    ORG 00h
    resetVec:
	PAGESEL main
	goto main
    
    ;------------Vector interruptor-------------------------------------------------
    ORG 04h

    push:
	movwf	    W_TEMP
	swapf	    STATUS, W
	movwf	    STATUS_TEMP	    
	
    isr:
	btfsc	    T0IF
	call	    t0_int
	
	
    pop:
	swapf	    STATUS_TEMP, W
	movwf	    STATUS
	swapf	    W_TEMP, F
	swapf	    W_TEMP, W
	retfie
    
    ;---------subrutina interrupcion------------------------------------------------
	t0_int:
	    call    reinicio_tmr0
	    incf    cont
	    movf    cont, W
	    sublw   2
	    btfss   ZERO	    ;status, 2
	    goto    return_t0	    ;1000ms
	    clrf    cont
	    
	return_t0:
	    
	    return
	
    PSECT code, delta=2,abs
    ORG 100h
    
    tabla:
	clrf	    PCLATH
	bsf	    PCLATH, 0	;pclath= 01, pcl = 02
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
	
    ;----------------configuracion----------------------------------------------
    main:
	call	config_io
	call	config_tmr0
	call	config_int_enable
	banksel PORTD
	
    loop:
	incf	PORTD
	movf	PORTD, W
	call	tabla
	movwf	PORTD
	call	t0_int
	goto	loop
    ;----------------sub rutinas---------------------------------------
    
    config_io:
	bsf	STATUS, 5
	bsf	STATUS, 6   ;banco 11
	clrf	ANSEL
	clrf	ANSELH	    ;pines digitales
	
	bsf	STATUS,5
	bcf	STATUS,6    ;banco 01
	clrf	TRISD	    ;porta salida
	
	bcf	STATUS,5
	bcf	STATUS,6    ;banco 00
	clrf	PORTD
	
	return

    config_tmr0:
	banksel	    OSCCON	;500kHz
	bcf	    OSCCON,6
	bsf	    OSCCON,5
	bsf	    OSCCON,4
	bcf	    SCS		;reloj interno
	call	    reinicio_tmr0
	return
	
    reinicio_tmr0:
	banksel	PORTD	    ;ciclo de 500ms
	movlw	12
	movwf	TMR0
	bcf	T0IF
	return
	
    config_int_enable:
	bsf	GIE	;intcon
	bsf	T0IE
	bcf	T0IF
	return
	
END