/*
 * File:   PWM.c
 * Author: Danika
 *
 * Created on 27 de abril de 2021, 04:41 PM
 */
//******************************************************************************
/*Uso de 2 potenciometros y servos
 * Se usa el ADC junto con el PWM para controlar 2 servos
 * con 2 potenciometros
 */
//******************************************************************************

#pragma config  FOSC    = INTRC_NOCLKOUT
#pragma config  WDTE    = OFF
#pragma config  PWRTE   = OFF
#pragma config  MCLRE   = OFF
#pragma config  CP      = OFF
#pragma config  CPD     = OFF
#pragma config  BOREN   = OFF
#pragma config  IESO    = OFF
#pragma config  FCMEN   = ON
#pragma config  LVP     = ON

#pragma config  BOR4V   = BOR40V
#pragma config  WRT     = OFF


#include <xc.h>
#include <stdint.h>

#define _XTAL_FREQ  4000000 

char i;

void setup(void);

void __interrupt() isr(void){
    
    if(PIR1bits.ADIF){//PWM diferente 
        
        if(i == 2){
            PORTB   = ADRESH;                    //Aqui se activa CCP1
            CCPR1L  = (PORTB >> 1) + 35;         //usando el puerto para el adresh   
            CCP1CONbits.DC1B1 = PORTBbits.RB0;   //que despues se elimina el bit 
            CCP1CONbits.DC1B0 = ADRESL >> 7;     //menos significativo   
                                                 //y con 35 se ajusta para el pot
        }else if (i == 1){                      
            
            PORTD   = ADRESH;                    //Aqui se activa CCP2
            CCPR2L  = (PORTD >> 1) + 35;         //y se realiza lo mismo
            CCP1CONbits.DC1B1 = PORTDbits.RD0;
            CCP1CONbits.DC1B0 = ADRESL >> 7;
        }
        
        i--;                                    //Con la variable i realizamos
        if (i == 0){                            //realizamos un loop donde
            i = 2;                              //cada uno es dedicado a un
        }
        PIR1bits.ADIF = 0;      //se baja la bandera
    }
}

void main(void) {
    setup();
           
    while(1){
        
        if(ADCON0bits.GO == 0){                 //Aqui se realiza otro loop 
                                                //constantemente cambiando 
            if (ADCON0bits.CHS == 0){           //los canales
                ADCON0bits.CHS = 1;             //si esta en el canal 0
                                                //entonces cambia al canal 1 
            }else if (ADCON0bits.CHS == 1){     // y viceversa    
                ADCON0bits.CHS = 0;                               
            }
                          
            __delay_us(50);
            ADCON0bits.GO = 1;      //se baja bandera
        }
    }
}

void setup(void){
   
    ANSEL   = 0x03;     //se activa el canal 0 y 1
    ANSELH  = 0x00;
    
    TRISA   = 0xff;     //puerto A como entrada
    TRISB   = 0x00;     //puerto B,C y D como salida
    TRISC   = 0x00;
    TRISD   = 0x00;
    
    PORTA   = 0;
    PORTB   = 0;
    PORTC   = 0;
    PORTD   = 0;
    
    //oscilador a 4M Hz
    OSCCONbits.IRCF2 =1;    
    OSCCONbits.IRCF1 =1;
    OSCCONbits.IRCF0 =0;
    OSCCONbits.SCS   =1;
    
    //configuracion ADC
    ADCON1bits.ADFM = 0; //justificacion a la izquierda
    ADCON1bits.VCFG0 = 0;
    ADCON1bits.VCFG0 = 0;   //vref = vss y vdd
    
    ADCON0bits.ADCS0 = 1;   //fosc/32
    ADCON0bits.ADCS1 = 0;
    
    ADCON0bits.CHS  =0;
    __delay_us(50);
    ADCON0bits.ADON = 1;        //enciende adc
    
    //Configuracion PWM
    //1.
    TRISCbits.TRISC2 = 1;       //puerto C1 y C2 como entrada
    TRISCbits.TRISC1 = 1;
    //2. Setear periodo con PR2
    PR2 = 125;          //2ms
    
    //3. Configuración CCPCON PWM
    CCP1CONbits.P1M = 0b00;     //unica salida
    CCP1CONbits.CCP1M = 0b00001100; //modo PWM CCP1
    
    CCP2CONbits.CCP2M = 0b00001100; //modo PWM CCP2
    
    //4. Cargar el valor de CCPRxL
    CCPR1L  = 93;
    CCP1CONbits.DC1B0 = 1;      //bits menos significativos CCP1
    CCP1CONbits.DC1B1 = 1;   
    
    CCPR2L  = 93;
    CCP2CONbits.DC2B0 = 1;      //bits menos significativos CCP2
    CCP2CONbits.DC2B1 = 1;      //total en bits 93 + 3 = 375
    
    //5. Configurar el TmR2 
    //tmr2
    PIR1bits.TMR2IF = 0;
    T2CONbits.T2CKPS = 0b11;    //prescaler 1:16
    T2CONbits.TMR2ON = 1;
    
    //6.
    while(!PIR1bits.TMR2IF);    //espera completar tmr2
    PIR1bits.TMR2IF = 0;
    
    //7.
    TRISCbits.TRISC2 = 0;       //salida de PWM
    TRISCbits.TRISC1 = 0;
    
    //interrupciones
    PIR1bits.ADIF   = 0;        
    PIE1bits.ADIE   = 1;
    INTCONbits.PEIE = 1;
    INTCONbits.GIE = 1;
    
    i   = 2;
}