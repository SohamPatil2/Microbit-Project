.syntax unified
.global main

.type main, %function
main:
 ldr r9, = 77777//all code below comes from my assignment 1
 
  b initial

initial:
  subs r9, 1
  cmp r9, 1
  bge house
  cmp r9, 0
  beq main
  b initial


house:
  bl setting_2// row 1, column 1,2,4,5 on
  bl row2_on
  bl column_3
  bl duration
 

  bl row3_on
  bl column_2
  bl column_4
  bl duration_2
  bl column_3off

  bl row4_on
  bl duration_3

  bl row5_on
  bl column_3
  bl duration_4
  bl column_2off
  bl column_3off
  bl column_4off
  b initial


 setting_2:
 // swt the time counter and other values comparing with each other to turn off the row in function "finish_smile"
  ldr r4, = 100
  ldr r5, = 80
  ldr r6, = 60
  ldr r7, = 40
  ldr r8, = 20
  bx lr

row2_on:
  ldr r1, =0x50000000
  ldr r2, [r1, 0x514]//output
  mov r3, 0b1
  lsl r3, r3, #22 // row 2
  orr r2, r2, r3
  str r2, [r1, 0x514]

  ldr r1, =0x50000000
  ldr r2, [r1, 0x504]//high
  mov r3, 0b1
  lsl r3, r3, #22
  orr r2, r2, r3
  str r2, [r1, 0x504]
  bx lr

row3_on:
  ldr r1, =0x50000000
  ldr r2, [r1, 0x514]//output
  mov r3, 0b1
  lsl r3, r3, #15 // row 3
  orr r2, r2, r3
  str r2, [r1, 0x514]

  ldr r1, =0x50000000
  ldr r2, [r1, 0x504]//high
  mov r3, 0b1
  lsl r3, r3, #15
  orr r2, r2, r3
  str r2, [r1, 0x504]
  bx lr

row4_on:
  ldr r1, =0x50000000
  ldr r2, [r1, 0x514]//output
  mov r3, 0b1
  lsl r3, r3, #24 // row 4
  orr r2, r2, r3
  str r2, [r1, 0x514]

  ldr r1, =0x50000000
  ldr r2, [r1, 0x504]//high
  mov r3, 0b1
  lsl r3, r3, #24
  orr r2, r2, r3
  str r2, [r1, 0x504]
  bx lr

row5_on:
  ldr r1, =0x50000000
  ldr r2, [r1, 0x514]//output
  mov r3, 0b1
  lsl r3, r3, #19 // row 5
  orr r2, r2, r3
  str r2, [r1, 0x514]

  ldr r1, =0x50000000
  ldr r2, [r1, 0x504]//high
  mov r3, 0b1
  lsl r3, r3, #19
  orr r2, r2, r3
  str r2, [r1, 0x504]
  bx lr


column_4:
  ldr r1,= 0x50000300// column 4 is in port 1
  ldr r2, [r1, 0x514]//output
  ldr r3,= 0b1
  lsl r3, r3, #5
  orr r2, r2, r3
  str r2, [r1, 0x514]
  bx lr

column_3:
  ldr r1, =0x50000000//column 3 is in port 0
  ldr r2, [r1, 0x514]//output
  ldr r3,= 0b1
  lsl r3, r3, 31
  orr r2, r2, r3
  str r2, [r1, 0x514]
  bx lr

column_2:
  ldr r1, =0x50000000//column 2 is in port 0
  ldr r2, [r1, 0x514]//output
  ldr r3,= 0b1
  lsl r3, r3, 11
  orr r2, r2, r3
  str r2, [r1, 0x514]
  bx lr

column_4off:
  ldr r1, =0x50000300//turn off column 4
  ldr r2, [r1,0x514]
  ror r2, #5
  lsr r2, 1
  ror r2,26
  str r2, [r1, 0x514]
  bx lr

column_3off:
  ldr r1, =0x50000000//turn off column 3
  ldr r2, [r1,0x514]
  ror r2, 31
  lsr r2, 1
  str r2, [r1, 0x514]
  bx lr

column_2off:
  ldr r1, =0x50000000//turn off column 2
  ldr r2, [r1,0x514]
  ror r2, 11
  lsr r2, 1
  ror r2, 20
  str r2, [r1, 0x514]
  bx lr


duration:
//loop for control when to turn off each row
  subs r4,1
  cmp r4,r5
  beq turn_off_row2

  b duration

duration_2:
//loop for control when to turn off each row
  subs r5,1
  cmp r5,r6
  beq turn_off_row3

  b duration_2

duration_3:
//loop for control when to turn off each row
  subs r6,1
  cmp r6,r7
  beq turn_off_row4

  b duration_3

duration_4:
//loop for control when to turn off each row
  subs r7,1
  cmp r7,r8
  beq turn_off_row5

  b duration_4


turn_off_row2:
  ldr r1, =0x50000000
  ldr r2, [r1,0x514]
  ror r2, #22
  lsr r2, 1
  ror r2, 9
  str r2, [r1, 0x514]
  bx lr

turn_off_row3:
  ldr r1, =0x50000000
  ldr r2, [r1,0x514]
  ror r2, #15
  lsr r2, 1
  ror r2, 16
  str r2, [r1, 0x514]
  bx lr

turn_off_row4:
  ldr r1, =0x50000000
  ldr r2, [r1,0x514]
  ror r2, #24
  lsr r2, 1
  ror r2, 7
  str r2, [r1, 0x514]
  bx lr

turn_off_row5:
  ldr r1, =0x50000000
  ldr r2, [r1,0x514]
  ror r2, #19
  lsr r2, 1
  ror r2, 12
  str r2, [r1, 0x514]
  bx lr