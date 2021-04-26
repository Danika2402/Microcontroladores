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

#define value 236       //tmr0 de 5ms

#define _XTAL_FREQ  4000000

void setup(void);

char u, d, c, i, p;     //variables a usar

const char tabla[]={
        0x7e,   //0
        0x3f,   //1
        0x06,   //2
        0x5b,   //3
        0x4f,   //4
        0x66,   //5
        0x6d,   //6
        0x7d,   //7
        0x07,   //8
        0x7f    //9
};

void __interrupt() isr (void){
    
    if(PIR1bits.ADIF){
        
        if (ADCON0bits.CHS  == 12){     //cuando este en el canal 12 
            PORTA   = ADRESH;           //El potenciometro esta conectado a ese canal
                                        //entonces se llama PORTA para que el valor del
            ADCON0bits.CHS  = 10;       //pot se convierte y se muestre en el puerto
            __delay_us(50);
            
        } else if (ADCON0bits.CHS  == 10){
                                        //Despues de eso se cambia al canal 10 
            p   = ADRESH;               //donde hay un segundo potenciometro
            ADCON0bits.CHS  = 12;       //este manda sus valores a convertirlos
            __delay_us(50);             //y los guarda en la variable p
        }
        
        PIR1bits.ADIF    =0;       
    }
    
    if (T0IF){
        PORTD   =0;
        
        if (i==4){                  //la variable i esta en un constante loop
                                    //dependiendo de su valor chequea cada bit 
            RD0     = 1;            //conectado a un transistor del display
            PORTC   = tabla[c];     //cuando termine y llegua a i=1
        }                           //vuelve a convertirse i=4 
        else if(i==3){              //y repite el proceso
            RD1     = 1;
            PORTC   = tabla[d];
        }                           //dependiendo del display, muestra el numero
        else if(i==2){              //en centena, decena o unidad
            RD2     =1;             //que son las varianles c,d,u respectivamente
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
    ADCON0bits.GO_nDONE =1;             //delay para el adcon y los canales
        
    while(1){
            
            
            c   = p/100;
            d   = (p -(c * 100))/10;        //esto determina el valor que se
            u   = p - (c * 100) - (d *10);  //muestra en el display
                                            //c = centena
            ADCON0bits.GO_nDONE =1;         //d = decena
            __delay_us(50);                 //u = unidad
        
    }
}
    

void setup (void){
    ANSEL   = 0x00;
    ANSELH  = 0b00010100;               //se activan el canal 12 y 10
                                        //que son RB1 y RB0
    TRISA   = 0x00;
    TRISC   = 0x00;
    TRISB   = 0x03;                     //solo primeros bits de puerto b 
    TRISD   = 0x00;                     //como entrada
    
    PORTA   = 0;                        //puerto a,c,d son salida
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
    
    //configuracion de interrupciones
    INTCONbits.T0IF = 0;
    INTCONbits.T0IE = 1;
     
    ADCON0bits.CHS0 = 0;
    ADCON0bits.CHS1 = 0;
    ADCON0bits.CHS2 = 1;
    ADCON0bits.CHS3 = 1;    //canal 12
    
    
    ADCON0bits.ADON = 1;    //enciende modulo y permite conversion 
    __delay_us(50);
    ADCON0bits.GO_nDONE = 1;    
    
    ADCON1bits.VCFG0 = 0;   //voltajes de referencia
    ADCON1bits.VCFG1 = 0;
    
    ADCON0bits.ADCS0 = 1;   //fosc/8, Tad = 2us
    ADCON0bits.ADCS1 = 1;
    
    INTCONbits.GIE  = 1;    //abilita interrupciones
    INTCONbits.PEIE  =1;
    
    PIR1bits.ADIF   = 0;    //bajando bandera
    PIE1bits.ADIE   = 1;    //habilitando bandera
    
    ADCON1bits.ADFM =0; //izquierda
    
    i   = 4;
    u   = 0;
    d   = 0;
    c   = 0;
    
}