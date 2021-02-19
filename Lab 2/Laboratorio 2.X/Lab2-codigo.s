    ;Archivo:	    Lab 2-codigo
    ;Dispositivo:   PIC16F887
    ;Autor:	    Danika Geraldine
    ;Compilador:    pic-as (v2.30), MPLABX V5.45
    ;
    ;Programa:	    Sumador de 4 bist
    ;Hardware:	    LEDs en puerto B y D, push butttons puerto A
    ;
    ;Creado:	    9 feb, 2021
    ;Ultima modificacion:  9 feb, 2021
    
    
    ;***************************************************************************
    
    
    PROCESSOR 16F887
    #include <xc.inc>
    
    ;Configuration word 1
    CONFIG FOSC=XT		// oscillador EXTERNO
    CONFIG WDTE=OFF		// WDT disabled (reinicio repetitivo)
    CONFIG PWRTE=ON		//PWT enabled (espera 72ms al iniciar)
    CONFIG MCLRE=OFF		//pin mclr se utiliza como I/O
    CONFIG CP=OFF		//sin proteccion de codigo
    CONFIG CPD=OFF		//sin proteccion de datos
    
    CONFIG BOREN=OFF		//sin reinicio si la alimentacion baja de 4V
    CONFIG IESO=OFF		//reinicio sin cambio de reloj,interno a externo
    CONFIG FCMEN=OFF		//cambio de reloj,ext. a intern,en caso de fallo
    CONFIG LVP=ON		//programacion de bajo voltaje permitido
    
    ;configuracion word 2
    CONFIG WRT=OFF		// proteccion de autoescritura desactivada
    CONFIG BOR4V=BOR40V		// reinicio abajo de 4V, BOR21V=2.1V
    
    
    ;----------Elementos--------------------------------------------------------
    
    PSECT udata_bank0		;commom memory
	cont_small:	DS 1		;1 byte
	cont_big:	DS 1
    
    PSECT resVect, class= CODE, abs, delta=2
 
    ;-----------Vector restet---------------------------------------------------
 
    ORG 00h
    resetVec:
	PAGESEL main
	goto main
    
	
    PSECT code, delta=2,abs
    ORG 100h
    
    ;--------Configuracion------------------------------------------------------
    
    main:
	banksel	    ANSEL	;banco donde esta ANSEL lo selecciono
	clrf	    ANSEL
	clrf	    ANSELH
	
	banksel	    TRISA	;confi. pines puerto A como entrada
	bsf	    TRISA, 0	
	
	clrf	    TRISB	;confi. pines B y D como salida
	clrf	    TRISD
	
	banksel	    PORTB	;que empiece en 0
	clrf	    PORTB
	clrf	    PORTD
	
    ;----------------loop principal---------------------------------------------
    
    loop:
	call	    delay_big
	btfsc	    PORTA, 0
	call	    inc_portb
	call	    inc_portd
	call	    decr_portb
	call	    decr_portd
	goto	    loop	;loop eterno
	
    ;-------sub rutinas---------------------------------------------------------
	
    
	//PUERTO B
    inc_portb:			;loop incrimento de bit boton
	btfsc	    PORTA,3
	goto	    $-1
	incf	    PORTB, W	
	andlw	    0x0f	;pasar bits superiores
	movwf	    PORTB
	return
	
    decr_portb:
	btfsc	    PORTA,2
	goto	    $-1
	decfsz	    PORTB, W
	andlw	    0x0f
	movwf	    PORTB
	return

	///PUERTO D
    inc_portd:
	btfsc	    PORTA,1	;loop incremento boton
	goto	    $-1
	incf	    PORTD,W
	andlw	    0x0f
	movwf	    PORTD
	return
	
    decr_portd:
	btfsc	    PORTA,0
	goto	    $-1
	decfsz	    PORTD,W
	andlw	    0x0f
	movwf	    PORTD
	return
	
	
	//SUMADOR
    sumador:
	call	    inc_portb
	call	    inc_portd
	btfsc	    PORTA, 4
	addwf	    PORTD,W
	andlw	    0x0f
	movwf	    PORTB
	return
	
	//ANTI-REBOTE
     delay_big:
	movlw	198		
	movwf	cont_big    
	call	delay_small	 
	decfsz	cont_big,   1	 
	goto	$-2		 
	return
	
	
    delay_small:
	movlw	165		    
	movwf	cont_small	    
	decfsz	cont_small, 1	  
	goto	$-1		    
	return
	
END

	
	
	
	


