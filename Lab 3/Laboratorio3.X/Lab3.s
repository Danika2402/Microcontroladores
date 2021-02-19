    ;Archivo:	    Lab 3-codigo
    ;Dispositivo:   PIC16F887
    ;Autor:	    Danika Geraldine
    ;Compilador:    pic-as (v2.30), MPLABX V5.45
    ;
    ;Programa:	    contador activado con timr 0 y delay hexadecimal
    ;Hardware:	    Leds puerto A , delay puerto B
    ;
    ;Creado:	    16 feb, 2021
    ;Ultima modificacion:  16 feb, 2021
    
    
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
    
     ;PSECT udata_bank0 ;common memory
	;cont:	DS 1; 1 byte
    
    PSECT resVect, class=CODE, abs, delta=2
    ;------------Vector reset---------------------------------------------------
    ORG 00h
    resetVec:
	PAGESEL main
	goto main
    
	
    PSECT code, delta=2,abs
    ORG 100h
    
    ;----------------configuracion----------------------------------------------
    main:
	call	    config_reloj
	call	    config_io
	call	    config_tmr0
	banksel	    PORTA
	
    loop:
	btfss	    T0IF
	goto	    $-1
	call	    reinicio_tmr0
	incf	    PORTA ,1
	goto	    loop
    
    ;----------------sub rutinas  TIMER 0---------------------------------------
    config_tmr0:
	banksel	    TRISA
	bcf	    T0CS	    ;reloj interno
	bcf	    PSA
	bsf	    PS2
	bsf	    PS1
	bcf	    PS0		    ; PS=111 = 1:256
	banksel	    PORTA
	call	    reinicio_tmr0
	return

    reinicio_tmr0:
	movlw	    12
	movwf	    TMR0
	bcf	    T0IF
	return

    config_reloj:
	banksel	    OSCCON	;500kHz
	bcf	    OSCCON,6
	bsf	    OSCCON,5
	bsf	    OSCCON,4
	bcf	    SCS		;reloj interno
	return
	
    config_io:
	banksel	    ANSEL	;banco 11
	clrf	    ANSEL
	clrf	    ANSELH
	
	banksel	    TRISA	;banco 01
	clrf	    TRISA
	
	banksel	    PORTA	;banco 00
	clrf	    TRISA
	
	return
 
    END