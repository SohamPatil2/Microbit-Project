.syntax unified
.global main

.type main, %function
main:
  mov r1,100 @ enemy pokemon 100hp
  mov r0,100 @our pokemon 100 hp
  mov r2,10 @ the strength of our enemy
  mov r3,10 @ the strength of our pokemon
  mov r6,0
  mov r7,70
  b hit

hit:
  subs r1,r3 @enemy pokemon's lose is hp-strength
  subs r0,r2 @our pokemon's lose is hp-strength
 
  cmp r1,r6
  ble   pokemon_wins
  cmp r1, r7 @ if  enemy's hp is smaller than 70, our pokemon give a frenzy attack
  IT LE
  blle frenzy
  
  cmp r0,r6
  ble enemy_wins
  cmp r0,r7  @ if our pokemon's hp is smaller than 70, enemy will give us a magic poison attack
  IT LE
  blle magic_poison
  b hit

frenzy:
  subs r1,30
  adds r2,10
  bx lr
 
  
 

magic_poison:
  mov r4, r3
  mov r5,2
  mul r4,r4,r5
  subs r0,r4
  bx lr
  
  











pokemon_wins:
  nop
  b pokemon_wins

enemy_wins:
  nop
  b enemy_wins
 
  @ b task_3

  @ Your code goes here
  
  
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

@ set the negative flag
@ ... your instruction(s) go here ...
mov r1,1
mov r2,2
subs r1,r1,r2


@ set the zero flag

@ ... your instruction(s) go here ...
mov r1,1
mov r2,1
subs r1,r1,r2




@ set the carry flag

@ ... your instruction(s) go here ...

@ set the overflow flag

@ ... your instruction(s) go here ...
mov r1, 0x7FFFFFFF
mov r2,10086
adds r1,r1,r2