.syntax unified
.global main

.type main, %function
main:
  @ b task_3

  @ Your code goes here
  mov r0,100
  
healing_loop:
  adds r0,50
  b healing_loop

@ a simple infinite loop
end_loop:
  nop
  b end_loop
.size main, .-main

@ a place for your to complete task 3. uncomment line 6 when you're ready to start working on it!
task_3:

