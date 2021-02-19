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
	cont:	DS 1		;1 byte
	
    
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
	call	    delay_small
	btfsc	    PORTA, 0
	call	    inc_portb
	goto	    loop	;loop eterno
	
    ;-------sub rutinas---------------------------------------------------------
    
    inc_portb:			;loop incrimento de bit por boton
	btfsc	    PORTA,0
	goto	    $-1
	incf	    PORTB, F	
	andlw	    0x0f	;pasar bits superiores
	return

    delay_small:		;delay antirrebote boton
	movlw	    150
	movwf	    cont
	decfsz	    cont,1
	goto	    $-1
	return
	
END

	
	
	


