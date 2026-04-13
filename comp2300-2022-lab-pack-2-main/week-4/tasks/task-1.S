.syntax unified
.global main

.type main, %function
main:  
  ldr r0, =0xcafe0000
  ldr r1, =0xffff

  @ your code goes here
  asr r3,r0,16
  ror r3,16


  lsr r4,r0,16

  
  
  rrx r5,r4  
  ror r5,15


  ror r6,r4,8
  lsr r6,4
  ror r6,4

@ when it's all done, spin in an infinite loop
loop:
  nop
  b loop

.size main, .-main

.data
hello:
.word 0x424242