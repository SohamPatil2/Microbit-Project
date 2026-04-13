.syntax unified
.global main
.type main, %function

main:
  nop
  .hword 0xdead
  @ put a single "real" assembly insruction here from your 2+2 program
  .word 0x0202f04f// mov r2,2 and mov r3,2

 
  .hword 0xbeef
  b main
.size main, .-main