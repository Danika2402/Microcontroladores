/*
 * File:   ASCII.c
 * Author: Danika
 *
 * Created on 4 de mayo de 2021, 05:24 PM
 */
//******************************************************************************
/*Uso de la terminal con el pic
 *Se usa la terminal para mandar caracteres al pic
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
#pragma config  FCMEN   = OFF
#pragma config  LVP     = OFF

#pragma config  BOR4V   = BOR40V
#pragma config  WRT     = OFF

#include <xc.h>
#include <stdint.h>


void setup(void);
void send_char(char i);
//void str(char str[]);
void str(char *m);

char f;
#define _XTAL_FREQ  1000000

void main(void) {
    setup();
    
    
    while(1){
        __delay_ms(500);
        str("¿Que acción desea ejecutar? \r");
        str("1) Desplegar cadena de caracteres \r");
        str("2) Cambiar PORTA \r");
        str("3) Cambiar PORTD \r\r");
        
        while(!PIR1bits.RCIF);
        f = RCREG;
        
        switch(f){
            
            case('1'):
                str('Hola');
                break;
            
            case('2'):
                str('Ingrese un caracter para PORTA');
                while(!PIR1bits.RCIF);
                PORTA   = RCREG;
                str('\r Completado \r');
                break;
                
            case('3'):
                str('Ingrese un caracter para PORTD');
                while(!PIR1bits.RCIF);
                PORTD   = RCREG;
                str('\r Completado \r');
                break;
        }
        }
    
}

void setup (void){
    
    ANSEL   = 0x00;
    ANSELH  = 0x00;
    
    TRISC   = 0x00;
    TRISCbits.TRISC7 = 1;
    TRISA   = 0x00;
    TRISD   = 0x00;
    
    PORTA   = 0;
    PORTC   = 0;
    PORTD   = 0;
    
    //oscilador a 1M Hz
    OSCCONbits.IRCF2 =1;    
    OSCCONbits.IRCF1 =0;
    OSCCONbits.IRCF0 =0;
    OSCCONbits.SCS   =1;
    
    //configuracion TX y RX
    TXSTAbits.TX9 = 0;
    
    TXSTAbits.SYNC  = 0;
    BAUDCTLbits.BRG16 = 1;      //16 bit - asincronico, alta velocidad
    TXSTAbits.BRGH  = 1;
    
    SPBRG   = 25;               //BAUD RATE 9600
    SPBRGH  = 0;
    
    RCSTAbits.SPEN  = 1;        //encender modulo 
    RCSTAbits.RX9   = 0;        //no trabajo a 9 bits
    RCSTAbits.CREN  = 1;         //recepcion activada
    TXSTAbits.TXEN  = 1;        //activar transmicion 

}

void send_char(char i){
    while(PIR1bits.TXIF){
        TXREG   = i;
    }
}

/*
void str(char str[]){
    int d = 0;
    
    while (str[d] != 0){
        send_char(str[d]);
        d++;
    }
}
*/
void str(char *m){
    while(*m != '\0'){
        send_char(*m);
        m++;
    }
}
