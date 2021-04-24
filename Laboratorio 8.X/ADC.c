/*
 * File:   ADC.c
 * Author: Danika
 *
 * Created on 20 de abril de 2021, 06:56 PM
 */
//******************************************************************************
/*
 *
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

#define _XTAL_FREQ  4000000

void setup(void);

char u, d, c, i, p;

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
    
    if(PIR1bits.ADIF){
        
        if (ADCON0bits.CHS  == 12){
            PORTA   = ADRESH;
            __delay_us(50);
            ADCON0bits.CHS  = 10;
            
        } else if (ADCON0bits.CHS  == 10){
            
            p   = ADRESH;
            ADCON0bits.CHS  = 12;
        }
        
        PIR1bits.ADIF    =0;       
    }
    if (T0IF){
        PORTD   =0;
        
        if (i==4){
                        
            RD0     = 1;
            PORTC   = tabla[c];
        }        
        else if(i==3){
            RD1     = 1;
            PORTC   = tabla[d];
        }
        else if(i==2){
            RD2     =1;
            PORTC   =tabla[u];
        }
        
        i--;
        if(i==1){
            i=4;
        }
        
        INTCONbits.T0IF = 0;
        TMR0= value;        //5ms
    }
}

void main(void) {
    setup();
    
    __delay_us(50);
    ADCON0bits.GO_nDONE =1;
        
    while(1){
            
            PORTA = p;
            c   = PORTA/100;
            d   = (PORTA -(c * 100))/10;
            u   = PORTA - (c * 100) - (d *10);
        
            ADCON0bits.GO_nDONE =1;
            __delay_us(50);
        
    }
}
    

void setup (void){
    ANSEL   = 1;
    ANSELH  = 0xff;
    
    TRISA   = 0x00;
    TRISC   = 0x00;
    TRISB   = 0x03;
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
    
    //configuracion de timer0, prescaler 1:256
    OPTION_REGbits.T0CS =0;
    OPTION_REGbits.PSA =0;
    OPTION_REGbits.PS2 =1;
    OPTION_REGbits.PS1 =1;
    OPTION_REGbits.PS0 =1;
    TMR0 = value; 
    
     
    ADCON0bits.CHS0 = 0;
    ADCON0bits.CHS1 = 0;
    ADCON0bits.CHS2 = 1;
    ADCON0bits.CHS3 = 1;    //canal 12
    
    
    ADCON0bits.ADON = 1;
    __delay_us(50);
    
    ADCON1bits.VCFG0 = 0;
    ADCON1bits.VCFG1 = 0;
    
    ADCON0bits.ADCS0 = 1;
    ADCON0bits.ADCS1 = 1;
    
    INTCONbits.GIE  = 1;
    INTCONbits.PEIE  =1;
    
    PIR1bits.ADIF   = 0;
    PIE1bits.ADIE   = 1;
    
    ADCON1bits.ADFM =0; //izquierda
    
    i   = 4;
    u   = 0;
    d   = 0;
    c   = 0;
    
    return;
}