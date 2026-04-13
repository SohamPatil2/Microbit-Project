.syntax unified
.global main

.type main, %function


main:
  @ ...
  ldr r4 , = 20000000
  bl set_bit_0x50000000_0x514_21
  bl set_bit_0x50000000_0x514_28
  bl set_bit_0x50000000_0x504_21_high
  b delay



set_bit_0x50000000_0x514_21:
  @ code to set bit 21 of word at offset 0x514 of 0x50000000
  ldr r1, =0x50000000
  ldr r2, [r1, 0x514]
  mov r3, 0b1
  lsl r3, r3, #21
  orr r2, r2, r3
  str r2, [r1, 0x514]
  bx lr
set_bit_0x50000000_0x514_28:
  ldr r1, =0x50000000 
  ldr r2, [r1, 0x514]
  mov r3, 0b1
  lsl r3, r3, #28
  orr r2, r2, r3
  str r2, [r1, 0x514]
  bx lr
set_bit_0x50000000_0x504_21_high:
  ldr r1, =0x50000000
  ldr r2, [r1, 0x504]
  mov r3, 0b1
  lsl r3, r3, #21
  orr r2, r2, r3
  str r2, [r1, 0x504]
  bx lr
  





delay:
  subs r4,1
  cmp r4,0
  beq clear_bit_0x50000000_0x514_28
  b delay

clear_bit_0x50000000_0x514_28:
  ldr r2, [r1, 0x514]
  ror r2, 28
  lsr r2, 1
  ror r2, 3
  str r2, [r1, 0x514]
  b main
