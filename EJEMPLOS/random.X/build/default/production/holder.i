# 1 "holder.s"
# 1 "<built-in>" 1
# 1 "holder.s" 2
    ;---------sub rutina CONTADOR-----------------------------------------------
    main_contador:
 bsf STATUS, 5 ;banco 11
 bsf STATUS, 6
 clrf ANSEL ;pines digitales
 clrf ANSELH


 bsf STATUS, 5 ;banco
 bcf STATUS, 6
 clrf TRISB ;port B salida

 bcf STATUS, 5 ; banco 00
     bcf STATUS, 6
    contador:
 incf PORTB, 1
 call delay_small
 andlw 0x0f ;pasar bits superiores
 goto contador ;loop forever
