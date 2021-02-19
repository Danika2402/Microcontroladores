;*******************************************************************************
; Archivo: Lab-1.s
; Dispositivo: PIC16F887
; Autor: Danika Andrino
; Carnet: 19487
; Compilador: pic-as (v2.30), MPLABX v5.45
    
; Programa: contador en el puerto A
; Hardware: LEDs en el puerto A

; Creado: 2 de feb, 2021

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
    
    
    PSECT udata_bank0 ;common memory
	cont_small: DS 1; 1 byte
	cont_big: DS 1
    
    PSECT resVect, class=CODE, abs, delta =2
 ;------------Vector reset------------------------------------------------------
    ORG 00h
    resetVec:
	PAGESEL main
	goto main
    
	
    PSECT code, delta=2,abs
    ORG 100h
;----------------configuracion--------------------------------------------------
    main:
	bsf	STATUS, 5   ;banco 11
	bsf	STATUS, 6
	clrf	ANSEL	    ;pines digitales
	clrf	ANSELH
	
	
	bsf	STATUS,	5   ;banco 
	bcf	STATUS, 6
	clrf	TRISA	    ;port A salida	
	
	bcf	STATUS, 5 ; banco 00
    	bcf	STATUS, 6
	
;-----------------loop principal------------------------------------------------
    loop:
	incf	PORTA, 1
	call	delay_big
	goto	loop	    ;loop forever
	
	
;--------sub rutinas------------------------------------------------------------
	
    delay_big:
	movlw	197		;valor inicial contador
	movwf	cont_big    
	call	delay_small	 ;rutina delay   (2 ciclos)
	decfsz	cont_big,   1	 ;decrementar contador (1 ciclo)
	goto	$-2		 ;ejecutar 2 lineas atras
	return
	
	
    delay_small:
	movlw	165		    ;val. inicial (1 ciclo
	movwf	cont_small	    ; (1 ciclo)
	decfsz	cont_small, 1	    ;decrementar contador
	goto	$-1		    ; (2 ciclos)
	return
	
	
END