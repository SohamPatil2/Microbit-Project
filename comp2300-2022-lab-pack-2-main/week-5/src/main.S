.syntax unified
.global main

.type main, %function
main:
  bl audio_init
  mov r5, #0
loop:
  add r5, #1 @ increment r5
  ror r5, 12
  mov r0, r5
  push {r5}
  bl audio_play_sample
  pop {r5}
  b loop
.size main, .-main



