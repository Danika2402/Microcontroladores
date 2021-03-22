; Archivo:	Estados.s
 ; Dispositivo:	PIC16F887
 ; Autor:	José Morales
 ; Compilador:	pic-as (v2.30), MPLABX V5.45
 ;                
 ; Programa:	1 boton de cambio de estado. S0 = incrementar, S1 = decrementar
 ; Hardware:	LEDs en el puerto A, botones en RB0 y RB1, leds en RC1 y RC2
 ;                       
 ; Creado: 10 feb, 2021
 ; Última modificación: 10 feb, 2021
 
 PROCESSOR 16F887
 #include <xc.inc>
 
 ;configuration word 1
  CONFIG FOSC=INTRC_NOCLKOUT	// Oscillador Interno sin salidas, XT
  CONFIG WDTE=OFF   // WDT disabled (reinicio repetitivo del pic)
  CONFIG PWRTE=ON   // PWRT enabled  (espera de 72ms al iniciar)
  CONFIG MCLRE=OFF  // El pin de MCLR se utiliza como I/O
  CONFIG CP=OFF	    // Sin protección de código
  CONFIG CPD=OFF    // Sin protección de datos
  
  CONFIG BOREN=OFF  // Sin reinicio cuándo el voltaje de alimentación baja de 4V
  CONFIG IESO=OFF   // Reinicio sin cambio de reloj de interno a externo
  CONFIG FCMEN=OFF  // Cambio de reloj externo a interno en caso de fallo
  CONFIG LVP=ON     // programación en bajo voltaje permitida
 
 ;configuration word 2
  CONFIG WRT=OFF    // Protección de autoescritura por el programa desactivada
  CONFIG BOR4V=BOR40V // Reinicio abajo de 4V, (BOR21V=2.1V)

 PSECT udata_bank0 ;common memory
    cont:	DS  2 ;1 byte
    estado:	DS 1
    
    BMODO   EQU 0
    B2	    EQU 1
    LS0	    EQU 0
    LS1	    EQU 1
	    
 PSECT udata_shr
    STATUS_TEMP: DS 1
    W_TEMP:	DS 1
    
 PSECT resVect, class=CODE, abs, delta=2
 ;--------------vector reset------------------
 ORG 00h	;posición 0000h para el reset
 resetVec:
     PAGESEL main
     goto main
 
 ;------------- vector de interrupcion--------
 PSECT	intVect, class=CODE, abs, delta=2
 ORG	04h
push:
    movwf	W_TEMP ;Copy W to TEMP register
    swapf	STATUS,W 
    movwf	STATUS_TEMP 

isr:
siempre_isr:
    btfss   RBIF
    goto    pop
    btfss   estado, 0
    goto    estado_0_int
    goto    estado_1_int
    
estado_0_int:   
    btfss   PORTB, B2	    ; acción en el modo
    incf    PORTA
    btfss   PORTB, BMODO    ; cambio de modo
    bsf	    estado, 0	    
    bcf	    RBIF	    ; reinicio de interrupcion
    goto    pop
    
estado_1_int:  
    btfss   PORTB, B2	    ; acción en el modo
    decf    PORTA
    btfss   PORTB, BMODO    ; cambio de modo
    bcf	    estado, 0	    
    bcf	    RBIF	    ; reinicio de interrupcion
    goto    pop  

pop:
    swapf	STATUS_TEMP,W ;Swap STATUS_TEMP register into W
    movwf	STATUS ;Move W into STATUS register
    swapf	W_TEMP,F ;Swap W_TEMP
    swapf	W_TEMP,W ;Swap W_TEMP into W
    retfie
    

 PSECT code, delta=2, abs
 ORG 100h	; posición para el código
 ;-------------configuración------------------
 main:
    call    config_io
    call    config_reloj
    call    config_rbioc
    banksel PORTA
;------------loop principal---------          
 loop:
    
 siempre:
    call    delay_small	;independiente de estado
    
    btfss   estado, 0	;revisión de estado
    goto    estado_0
    goto    estado_1
    
 estado_0:
    bsf	    PORTC, LS0
    bcf	    PORTC, LS1
    goto    loop   
    
 estado_1:   
    bcf	    PORTC, LS0
    bsf	    PORTC, LS1
    goto    loop        ; loop forever

 ;------------sub rutinas------------ 
 config_rbioc:
    banksel TRISA
    bsf	    IOCB, BMODO	; interupt en RB7, iocb para pines individuales
    bsf	    IOCB, B2
    
    banksel PORTB
    movf    PORTB, W
    bcf	    RBIF	; leer portb b y luego clrf intcon, rbif
    bsf	    GIE
    bsf	    RBIE
    return
    
 config_io:
    banksel ANSEL
    clrf    ANSEL	; pines digitales
    clrf    ANSELH
    
    banksel TRISA
    clrf    TRISA	; port A como salida
    bsf	    TRISB, BMODO
    bsf	    TRISB, B2
    bcf	    TRISC, LS0
    bcf	    TRISC, LS1
    bcf	    OPTION_REG, 7 ;RBPU
    bsf	    WPUB, BMODO
    bsf	    WPUB, B2
    
    banksel PORTA
    clrf    PORTA
    return
    
 config_reloj:
    banksel OSCCON
    bsf	    IRCF2	; OSCCON, 6 ; 1MHz
    bcf	    IRCF1	; OSCCON, 5
    bcf	    IRCF0	; OSCCON, 4
    bsf	    SCS		; reloj interno
    return
    
 delay_small:
    movlw   150		    ; valor inicial del contador
    movwf   cont	    
    decfsz  cont, 1	    ; decrementar el contador
    goto    $-1		    ; ejecutar línea anterior
    return
    
END 

