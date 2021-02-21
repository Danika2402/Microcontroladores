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
    
     PSECT udata_bank0 ;common memory
	cont:	DS 2; 1 byte
	cont_2: DS 1; 1 byte
    
    PSECT resVect, class=CODE, abs, delta=2
    ;------------Vector reset---------------------------------------------------
    ORG 00h
    resetVec:
	PAGESEL main
	goto main
    
	
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
	call	    config_reloj
	call	    config_io
	call	    config_tmr0
	banksel	    PORTA
	
    loop:
	call	    loop_contador
	call	    loop_delay
	goto	    loop
    
    ;----------------sub rutinas  TIMER 0---------------------------------------
    
    loop_contador:
	btfss	    T0IF	    ;el contador incrementa con cada 500ms
	goto	    $-1		    ; del timer0
	call	    reinicio_tmr0
	incf	    PORTA ,1
	return

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
	movwf	    TMR0	;timer0 500ms
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
	
	banksel	    TRISD	;puerto b como salida
	clrf	    TRISD	
	bsf	    TRISB,0	;puerto b como entrada
	bsf	    TRISB,1
	
	banksel	    PORTD	    
	clrf	    PORTD
	movlw	    0x00
	movwf	    cont_2	;mover variable y solo se usa 4 bits
	return
	
    loop_delay:
	btfsc	PORTB, 0	;incremento del delay 7
    	call	inc_boton	    
	btfsc	PORTB, 1
	call	decr_boton
	return
	
    inc_boton:
	btfsc	PORTB,0		;cuando se apacha el boton
	goto	$-1		;la variable se aumenta, guarda y se mueve
	incf	cont_2		;llamo la tabla y el dato W lo mando al
	movf	cont_2,W	;puerto D
	call	tabla
	movwf	PORTD
	return
	
    decr_boton:
	btfsc	PORTB,1	    ;igual que inc_boton pero 
	goto	$-1	    ;la variable se disminuye 
	decf	cont_2
	movf	cont_2,W 
	call	tabla
	movwf	PORTD
	return
	
    END