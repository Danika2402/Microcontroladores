/*
 * File:   eeprom.c
 * Author: Danika
 *
 * Created on 2 de junio de 2021, 06:30 PM
 */
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

uint8_t adc_val;
uint8_t RB0_old = 1;

void setup(void);
void writeEEPROM(uint8_t data, uint8_t address);
int8_t readEEPROM(uint8_t address);

void __interrupt() isr(void){
    if(INTCONbits.RBIF){
        
        
        PORTB   = PORTB;
        INTCONbits.RBIF = 0;
    }
}

void main(void) {
    
    setup();
    while(1){
        __delay_us(100);
        
        if(ADCON0bits.GO == 0){
            adc_val = ADRESH;
            PORTD   = adc_val;
            __delay_us(100);
            ADCON0bits.GO = 1;
        }
        
        if(RB0 == 1 && RB0_old == 0){
            writeEEPROM(adc_val, 0x5);
        }
        
        RB0_old = RB0;
        
        if(RB1 == 0){
            SLEEP();
        }
        PORTC   = (char)readEEPROM(0x05);
    }
}

void setup(void){
    
    ANSEL   =0b00100000;
    ANSELH  = 0x00;
    
    TRISB   = 0b111;
    TRISC   = 0x00;
    TRISD   = 0x00;
    
    PORTB   = 0x00;
    PORTC   = 0x00;
    PORTD   = 0x00;
    
    OPTION_REGbits.nRBPU = 0;
    WPUB    = 0b111;
    
    INTCONbits.RBIE = 1;
    INTCONbits.RBIF = 0;
    IOCB    = 0b0100;
    INTCONbits.GIE  = 0;
    
    OSCCONbits.IRCF = 0b110;
    OSCCONbits.SCS  = 1;
    
    ADCON1bits.ADFM = 0; //a la izquierda
    ADCON1bits.VCFG0= 0;
    ADCON1bits.VCFG1= 0;
    
    ADCON0bits.ADCS = 0b01;
    ADCON0bits.CHS  = 5;
    __delay_us(100);
    ADCON0bits.ADON = 1;
    __delay_us(100);
    
    return;
}

void writeEEPROM(uint8_t data, uint8_t address){
    
    EEADR   = address;
    EEDAT   = data;
    
    EECON1bits.EEPGD = 0;
    EECON1bits.WREN  = 1;
    
    INTCONbits.GIE  = 0;
    
    EECON2  = 0x55;
    EECON2  = 0xAA;
    EECON1bits.WR   = 1;
    
    while(!PIR2bits.EEIF);
    PIR2bits.EEIF   = 0;
    EECON1bits.WREN  = 1;
    INTCONbits.GIE  = 0;
    
    return;
}
int8_t readEEPROM(uint8_t address){
    
    EEADR   = address;
    EECON1bits.EEPGD = 0;
    EECON1bits.RD    = 1;
    int8_t data = (int8_t)EEDAT;
    
    return data;
}
