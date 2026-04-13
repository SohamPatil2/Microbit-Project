.syntax unified
.global main

.type main, %function
main:
  @ set up the arguments
  mov r0, 66 @ ass1 mark
  mov r1, 73 @ ass2 mark
  mov r2, 71 @ final exam mark

  @ call the function
  bl calculate_total_mark

  @ go to the end loop
  b end

end:
  b end

calculate_total_mark:
  @ do stuff with the arguments
  @ ...
  mov r3,2
  mov r4,4
  udiv r0, r0, r4
  udiv r1, r1, r4
  udiv r2, r2,r3
  adds r3, r0, r1
  adds r4, r3, r2

  @ put the result in r0
  mov r0, r4

  @ go back to where the function was called from
  bx lr