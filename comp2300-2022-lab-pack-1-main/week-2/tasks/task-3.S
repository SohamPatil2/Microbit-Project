.syntax unified
.global main
.type main, %function

main:
  .hword 0xf04f
  .hword 0x0103//these two instructions show mov r1,3
  .hword 0x3901//this shows subs r1,1
  b main
.size main, .-main