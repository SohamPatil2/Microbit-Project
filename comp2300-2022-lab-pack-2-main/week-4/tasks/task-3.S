.syntax unified
.global main

.type main, %function
main:
  ldr r1, =storage
  @ your code starts here
  ldr r2, =1
  str r2, [r1, 12]




.data
storage:
  .word 2, 3, 0, 0 @ don't change this line
