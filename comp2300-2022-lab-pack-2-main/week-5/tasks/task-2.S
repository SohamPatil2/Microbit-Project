.syntax unified
.global main

.type main, %function
initial:
  mov r5, 0

main:

  adds r5,r5,1
  mov r6,r5
  mov r7,r6
  mov r8,r6
  ldr r4 , = 20000000
  bl three_times
  bl five_times
  bl both
  cmp r5,100
  bgt initial
  b main




three_times:
  adds r6,3
  cmp r6,99
  beq left
  cmp r6,100
  bgt back
  b three_times

five_times:
  adds r7,5
  cmp r7,100
  beq right
  cmp r7,100
  bgt back
  b five_times
  

both:
  cmp r8,15
  beq both_on 
  cmp r8,30
  beq both_on
  cmp r8,45
  beq both_on
  cmp r8,60
  beq both_on
  cmp r8,75
  beq both_on
  cmp r8,90
  beq both_on
  bx lr
  
 

back:
  bx lr

left:
  @ code to set bit 21 of word at offset 0x514 of 0x50000000
  ldr r1, =0x50000000
  ldr r2, [r1, 0x514]
  mov r3, 0b1
  lsl r3, r3, #21
  orr r2, r2, r3
  str r2, [r1, 0x514]
 
  ldr r1, =0x50000000 
  ldr r2, [r1, 0x514]
  mov r3, 0b1
  lsl r3, r3, #28
  orr r2, r2, r3
  str r2, [r1, 0x514]


  ldr r1, =0x50000000
  ldr r2, [r1, 0x504]
  mov r3, 0b1
  lsl r3, r3, #21
  orr r2, r2, r3
  str r2, [r1, 0x504]

  b delay


right:
  ldr r1, =0x50000000 
  ldr r2, [r1, 0x514]
  mov r3, 0b1
  lsl r3, r3, #30
  orr r2, r2, r3
  str r2, [r1, 0x514]

  b delay_2

both_on:
  ldr r1, =0x50000000 
  ldr r2, [r1, 0x514]
  mov r3, 0b1
  lsl r3, r3, #28
  orr r2, r2, r3
  str r2, [r1, 0x514]

  ldr r2, [r1, 0x514]
  mov r3, 0b1
  lsl r3, r3, #30
  orr r2, r2, r3
  str r2, [r1, 0x514]
  b delay_3


delay:
  subs r4,1
  cmp r4,0
  beq clear_bit_0x50000000_0x514_28
  b delay


delay_2:
  subs r4,1
  cmp r4,0
  beq clear_bit_0x50000000_0x514_30
  b delay_2


delay_3:
  subs r4,1
  cmp r4,0
  beq clear_bit_both
  b delay_3



clear_bit_0x50000000_0x514_28:
  ldr r2, [r1, 0x514]
  ror r2, 28
  lsr r2, 1
  ror r2, 3
  str r2, [r1, 0x514]

  ldr r4 , = 20000000
  bx lr

clear_bit_0x50000000_0x514_30:
  ldr r2, [r1, 0x514]
  ror r2, 30
  lsr r2, 1
  ror r2, 1
  str r2, [r1, 0x514]

  ldr r4 , = 20000000
  bx lr

clear_bit_both:
  ldr r2, [r1, 0x514]
  ror r2, 28
  lsr r2, 1
  ror r2, 3
  str r2, [r1, 0x514]

  ldr r2, [r1, 0x514]
  ror r2, 30
  lsr r2, 1
  ror r2, 1
  str r2, [r1, 0x514]

  ldr r4 , = 20000000
  bx lr

  
