/*
 * File:   Codigo_C.c
 * Author: Danika
 *
 * Created on 13 de abril de 2021, 02:38 PM
 */
//******************************************************************************
/*
 *Incrementar y decrementar un contadro con 2 botones
 * 
 *Que el contador incremente y decremente con tmr0 cada 5ms 
 * 
 * 3 displays 7 muestren el numero del contador
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

#define value 236

void setup(void);
    

char u, d, c, i, f;

const char tabla[]={
        0x3f,
        0x06,
        0x5b,
        0x4f,
        0x66,
        0x6d,
        0x7d,
        0x07,
        0x7f
};


void __interrupt() isr (void){
    
    
    if (T0IF==1){
        PORTD++; 
        PORTB =0;
                
        if (i==4){
                        
            RB7     = 1;
            PORTC   = tabla[c];
        }        
        else if(i==3){
            RB6     = 1;
            PORTC   = tabla[d];
        }
        else if(i==2){
            RB5     =1;
            PORTC   =tabla[u];
        }
        
        i--;
        if(i==1){
            i=4;
        }
        
        INTCONbits.T0IF = 0;
        TMR0= value;            //5ms
    } 
    
    if (RBIF==1){
        
        if (RB0==0){
            PORTA++;
        }
        if (RB1==0){
            PORTA--;
        }
        INTCONbits.RBIF=0;
    }
}


void main(void) {
    setup();
    
    
    while(1){
        
        c   = PORTA/100;
        d   = (PORTA -(c * 100))/10;
        u   = PORTA - (c * 100) - (d *10);
        
    }
    
}

void setup (void){
 
    ANSEL   = 0x00;
    ANSELH  = 0x00;
    
    TRISA   = 0x00;
    TRISB   = 0x03;
    TRISD   = 0x00;
    TRISC   = 0x00;
    
    PORTB   = 0x00;
    PORTA   = 0x00;
    PORTD   = 0x00;
    PORTC   = 0x00;
    
    OPTION_REGbits.nRBPU=0;
    IOCB=0x03;
    WPUB=0x03;
    
    //oscilador a 4M Hz
    OSCCONbits.IRCF2 =1;
    OSCCONbits.IRCF1 =1;
    OSCCONbits.IRCF0 =0;
    OSCCONbits.SCS   =1;
    
    //*configuracion de timer0, prescaler 1:256
    OPTION_REGbits.T0CS =0;
    OPTION_REGbits.PSA =0;
    OPTION_REGbits.PS2 =1;
    OPTION_REGbits.PS1 =1;
    OPTION_REGbits.PS0 =1;
    TMR0 = value; 
    
    //configuracion de interrupciones
    INTCONbits.T0IF =0;
    INTCONbits.T0IE =1;
    
    //interrupciones portb
    INTCONbits.RBIF =1;
    INTCONbits.RBIE=1;
    INTCONbits.GIE=1;
    
    i   = 4;
    u   = 0;
    d   = 0;
    c   = 0;
    return;
    
}
