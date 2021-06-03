/*
 * File:   Brazo.c
 * Author: Danika
 *
 * Created on 26 de mayo de 2021, 01:12 PM
 */
//******************************************************************************
/*/
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

#define _XTAL_FREQ  4000000


void setup(void);
char i;
uint8_t adc_val;
uint8_t RB0_old = 1;

void setup(void);
void writeEEPROM(uint8_t data, uint8_t address);
int8_t readEEPROM(uint8_t address);

void __interrupt() isr (void){
    
    if(PIR1bits.ADIF){ 
        
        if(i == 2){
            CCPR1L  = (ADRESH >> 1) + 35;           
            
        }else if (i == 1){                      
            CCPR2L  = (ADRESH >> 1) + 35;         //y se realiza lo mismo

        }
        
        i--;                                    //Con la variable i realizamos
        if (i == 0){                            // un loop donde
            i = 2;                              //cada uno es dedicado a un
        }                                       //PWM diferente
        PIR1bits.ADIF = 0;                      //se baja la bandera
    }
}

void main(void) {
    setup();
    
    while(1){
        
        if(ADCON0bits.GO == 0){                 //Aqui se realiza otro loop 
                                                //constantemente cambiando 
            if (ADCON0bits.CHS == 5){           //los canales
               
                adc_val = ADRESH;
                __delay_us(100);
                ADCON0bits.CHS = 6;             //si esta en el canal 0
                                                //entonces cambia al canal 1 
            }else if (ADCON0bits.CHS == 6){     // y viceversa    
                
                adc_val = ADRESH;
                __delay_us(100);
                
                
                ADCON0bits.CHS = 5;                               
            }
                          
            __delay_us(50);
            ADCON0bits.GO = 1;      //se baja bandera
        }
        if(RB0 == 1 && RB0_old == 0){
            TRISBbits.TRISB5 = 1;
            writeEEPROM(adc_val, 0x5);
        }
        
        RB0_old = RB0;
        
        if(RB1 == 0){
            TRISBbits.TRISB6 = 1;
            SLEEP();
    }
        PORTA   = (char)readEEPROM(0x05);
        PORTD   = (char)readEEPROM(0x10);
}
}

void setup(void){
    
    ANSEL   = 0b01100000;     //se activa el canal 5 y 6
    ANSELH  = 0x00;
    
    TRISA   = 0x00;
    TRISB   = 0b111;
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
    
    ADCON0bits.CHS  =5;
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
    INTCONbits.GIE  = 1;
    
    OPTION_REGbits.nRBPU = 0;
    WPUB    = 0b111;
    
    INTCONbits.RBIE = 1;
    INTCONbits.RBIF = 0;
    IOCB    = 0b0100;
    
    i   = 2;
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
    INTCONbits.GIE  = 1;
    
    return;
}
int8_t readEEPROM(uint8_t address){
    
    EEADR   = address;
    EECON1bits.EEPGD = 0;
    EECON1bits.RD    = 1;
    int8_t data = (int8_t)EEDAT;
    
    return data;
}
