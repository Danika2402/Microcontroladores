; Archivo:	Estados.s
 ; Dispositivo:	PIC16F887
 ; Autor:	José Morales
 ; Compilador:	pic-as (v2.30), MPLABX V5.45
 ;                
 ; Programa:	1 boton de cambio de estado. S0 = incrementar, S1 = decrementar
 ; Hardware:	LEDs en el puerto A, botones en RB0 y RB1, leds en RC1 y RC2
 ;                       
 ; Creado: 10 feb, 2021
 ; Última modificación: 
 
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
    cont:	DS 1
    t0_temp:	DS 1 ;1 byte
    t0_act:	DS 1
    estado:	DS 1
    
    BMODO   EQU 4
    BARRIBA EQU 5
    BABAJO  EQU 6
	    
    LS0	    EQU 1
    LS1	    EQU 2
    LS2	    EQU 3
	    
    reinicio_tmr0 macro
	banksel PORTA   ;200ms
	movlw   61
	movwf   t0_act
	movf    t0_act, W
	movwf   TMR0	
	bcf 	T0IF
	endm
	    
 PSECT udata_shr
    STATUS_TEMP: DS 1
    W_TEMP:	 DS 1
    PCLATH_TEMP: DS 1
    
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
    movwf   W_TEMP
    swapf   STATUS, W
    movwf   STATUS_TEMP
    movf    PCLATH, W
    movwf   PCLATH_TEMP

isr:
    btfsc   RBIF
    call    int_ioc
    
    btfsc   T0IF
    call    int_tmr0
    
pop:
    swapf	STATUS_TEMP,W 
    movwf	STATUS 
    swapf	W_TEMP,F 
    swapf	W_TEMP,W 
    retfie
    
;--------- subrutinas de la interrupcion----------------------------------------
    
int_tmr0:
    reinicio_tmr0
    incf    cont
    movf    cont,W
    sublw   5
    btfss   ZERO
    goto    $+2
    clrf    cont
    incf    PORTA
    return
    
int_ioc:
    movf    estado, W
    clrf    PCLATH
    andlw   0x05
    addwf   PCL	; inst 103, PC 104 + 5
    goto    estado_1_int      
    goto    estado_2_int      
    goto    estado_3_int
    goto    estado_4_int
    goto    estado_5_int
    
estado_1_int:
    btfsc   PORTB, BMODO
    goto    end_ioc
    incf    estado
    movf    t0_act, W
    movwf   t0_temp
    goto    end_ioc
    
estado_2_int:
    btfss   PORTB, BARRIBA
    incf    t0_temp
    btfss   PORTB, BABAJO
    decf    t0_temp
    
    btfss   PORTB, BMODO
    incf    estado
    goto    end_ioc
    
estado_3_int:
    btfss   PORTB, BARRIBA
    incf    t0_temp
    btfss   PORTB, BABAJO
    decf    t0_temp
    
    btfss   PORTB, BMODO
    incf    estado
    goto    end_ioc
    
estado_4_int:
    btfss   PORTB, BARRIBA
    incf    t0_temp
    btfss   PORTB, BABAJO
    decf    t0_temp
    
    btfss   PORTB, BMODO
    incf    estado
    goto    end_ioc
    
estado_5_int:
    btfss   PORTB, BARRIBA
    clrf    estado
    btfsc   PORTB, BABAJO
    goto    end_ioc
    
    movf    t0_temp, W
    movwf   t0_act
    clrf    estado
    
end_ioc:
    bcf	    RBIF
    return
    
 PSECT code, delta=2, abs
 ORG 100h	; posición para el código
 ;-------------configuración------------------
 main:
    call    config_io
    call    config_reloj
    call    config_rbioc
    call    config_tmr0	    
    banksel PORTA
    clrf    estado
;------------loop principal---------          
 loop:
    movf    estado, W
    clrf    PCLATH
    bsf	    PCLATH, 0   ; 0100h
    andlw   0x05
    addwf   PCL	; inst 103, PC 104 + 5
    goto    estado_1      
    goto    estado_2      
    goto    estado_3
    goto    estado_4
    goto    estado_5
 
estado_1:
    movlw   100B
    movwf   PORTE
    btfss   T0IF
    goto    $-1
    reinicio_tmr0
    
    goto    loop
    
estado_2:
    movlw   010B
    movwf   PORTE
    goto    via_1
    goto    loop
    
estado_3:
    movlw   110B
    movwf   PORTE
    goto    via_2
    goto    loop
    
estado_4:
    movlw   001B
    movwf   PORTE
    goto    via_3
    goto    loop
    
estado_5:
    movlw   101B
    movwf   PORTE
    goto    loop
    
;------------sub rutinas-------------------------------------------------------- 

via_1:
    movlw   0x03
    movwf   PORTA
    incf    PORTA
    return
    
via_2:
    movlw   0x0e
    movwf   PORTA
    incf    PORTA
    return
    
via_3:
    movlw   0x03
    movwf   PORTB
    return
    
config_tmr0:
    banksel TRISA
    bcf	    T0CS
    bcf	    PSA
    bsf	    PS2
    bsf	    PS1
    bsf	    PS0
    reinicio_tmr0
    
    bsf	    GIE	    ;config int enable
    bsf	    T0IE
    bcf	    T0IF
    return

config_rbioc:
    banksel TRISA
    bsf	    IOCB, BMODO	; interupt en RB7, iocb para pines individuales
    bsf	    IOCB, BARRIBA
    bsf	    IOCB, BABAJO
    
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
    clrf    TRISE
    
    bsf	    TRISB, BMODO
    bsf	    TRISB, BARRIBA
    bsf	    TRISB, BABAJO
    
    bcf	    OPTION_REG, 7 ;RBPU
    bsf	    WPUB, BMODO
    bsf	    WPUB, BARRIBA
    bsf	    WPUB, BABAJO
    
    banksel PORTA
    clrf    PORTA
    return
    
config_reloj:
    banksel OSCCON
    bsf	    IRCF2	; OSCCON, 6,  1	; 1MHz  
    bcf	    IRCF1	; OSCCON, 5,  0
    bcf	    IRCF0	; OSCCON, 4,  0
    bsf	    SCS		; reloj interno
    return
   
END 



