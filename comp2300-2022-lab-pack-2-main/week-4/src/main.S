.syntax unified
.global main

.type main, %function
main:


@ load r1 with the base address of P0
  ldr r1, =0x50000000

@ load r2 with the value of P0 DIR
@ (note the 0x514 offset from the P0 base address)
  ldr r2, [r1, 0x514]

@ set bit 21 of this register by doing a logical or with 0b1 left-shifted by 21
@ think: why does this work?
  mov r3, 0b1
  lsl r3, r3, #21
  orr r2, r2, r3

@ store the modified result back into P0 DIR
  str r2, [r1, 0x514]


  ldr r2, [r1, 0x514]//output
  mov r3, 0b1
  lsl r3, r3, #28
  orr r2, r2, r3
  str r2, [r1, 0x514]


  ldr r2, [r1, 0x504]//high
  mov r3, 0b1
  lsl r3, r3, #21
  orr r2, r2, r3
  str r2, [r1, 0x504]
  

  ldr r4 , = 20000000
  b delay


delay:
  subs r4,1
  cmp r4,0
  beq turn_off
  b delay

turn_off:
  ldr r2, [r1, 0x514]
  ror r2, 28
  lsr r2, 1
  ror r2, 3
  str r2, [r1, 0x514]
  b main


  

  




