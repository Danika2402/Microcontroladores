
 ; Archivo:	estados_2.s
 ; Dispositivo:	PIC16F887
 ; Autor:	José Morales
 ; Compilador:	pic-as (v2.30), MPLABX V5.45
 ;                
 ; Programa:	
 ; Hardware:	
 ;                       
 ; Creado: 10 mar, 2021
 ; Última modificación: 10 mar, 2021
 
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

 PSECT udata_bank0  ; bank0 memory
    T0_TEMP:	DS  1
    T0_ACT:	DS  1
    estado:	DS  1
    
    BMODO   EQU 7
    B2	    EQU 0
    B3	    EQU 1
	    
 PSECT udata_shr    ; common memory
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
    
    
pop:
    movf    PCLATH_TEMP, W
    movwf   PCLATH
    swapf   STATUS_TEMP, W
    movwf   STATUS
    swapf   W_TEMP, F
    swapf   W_TEMP, W
    retfie
    
;--------- subrutinas de la interrupcion------------------
int_ioc:
    movf	estado, W
    clrf	PCLATH
    andlw	0x03
    addwf	PCL	; inst 103, PC 104 + 5
    goto	estado_0_int      ;0
    goto	estado_1_int      ;0
    goto	estado_2_int      ;0
    
estado_0_int:
    btfsc   PORTB, BMODO
    goto    end_ioc
    ;estado = 1
    incf    estado
    ;T0_TEMP <= T0_ACT 
    movf    T0_ACT, W
    movwf   T0_TEMP
    goto    end_ioc
    
estado_1_int:
    btfss   PORTB, B2
    incf    T0_TEMP
    btfss   PORTB, B3
    decf    T0_TEMP
    btfss   PORTB, BMODO
    incf    estado
    goto    end_ioc
    
    
estado_2_int:
    btfss   PORTB, B3
    clrf    estado
    btfsc   PORTB, B2
    goto    end_ioc
    ; T0_ACT <= T0_TEMP
    movf    T0_TEMP, W
    movwf   T0_ACT
    ; cambio estado
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
    call    config_TMR0 ; (50ms)
    banksel PORTA
    clrf    estado
;------------loop principal---------          
 loop:
    ; ocurre siempre
    ;bcf		GIE
    ; selección de estado
    movf	estado, W
    clrf	PCLATH
    bsf		PCLATH, 0   ; 0100h
    andlw	0x03
    addwf	PCL	; inst 103, PC 104 + 5
    goto	estado_0      ;0
    goto	estado_1      ;0
    goto	estado_2      ;0
    
estado_0:
    
    ;bsf	    GIE
    clrf    PORTD
    movlw   001B
    movwf   PORTC
    btfss   T0IF	; revisa si se cumplió el tiempo del TMR0
    goto    $-1
    call    restart_TMR0;
    incf    PORTA
    goto    loop        ; loop forever
    
estado_1:
    ;bsf	    GIE
    movf    T0_TEMP, W
    movwf   PORTD
    movlw   010B
    movwf   PORTC
    goto    loop  
    
estado_2:
    ;bsf	    GIE
    movf    T0_TEMP, W
    movwf   PORTD
    movlw   100B
    movwf   PORTC
    goto    loop  
    
    

 ;------------sub rutinas------------ 
 restart_TMR0:
    movf    T0_ACT, W
    movwf   TMR0	; valor inicial de conteo
    BCF	    T0IF	; limpiar bandera
    return
    
 config_TMR0:
    banksel TRISA
    BCF	    T0CS	
    BCF	    PSA		
    BSF	    PS2		
    BSF	    PS1
    BSF	    PS0		; PS = 111 01:256
    banksel PORTA
    
    movlw   61
    movwf   T0_ACT
    movf    T0_ACT, W
    movwf   TMR0	; valor inicial de conteo
    BCF	    T0IF	; limpiar bandera
    return
    
 config_rbioc:
    banksel TRISA
    bsf	    IOCB, BMODO	; interupt en RB7, iocb para pines individuales
    bsf	    IOCB, B2
    bsf	    IOCB, B3
    
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
    clrf    TRISC
    clrf    TRISD
    movlw   0xff
    movwf   TRISB
    
    bcf	    OPTION_REG, 7 ;RBPU
    movlw   0xff
    movwf   WPUB
    
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
    
END 




