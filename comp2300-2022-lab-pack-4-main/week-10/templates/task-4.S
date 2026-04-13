.syntax unified
.global main
.global GPIOTE_IRQHandler
.global SysTick_Handler
.global TIMER0_IRQHandler

@ SysTick vars
.set RVR_1MS,      64000
.set RVR_0_5MS,    32000
@ Timer vars
.set TIMER0_1MS,   1000
.set TIMER0_0_5MS, 500

.set MESSAGE_SIZE, 8


.type main, %function
main:
  @ GPIO 0: P0.02
  @ GPIO 1: P0.03
  @ GPIO 2: P0.04
  @ wire from 0 -> 2

  @@@@ Configure LEDS for some visual output
  bl init_leds

  @@@@ Configure interrupt priorities
  @ GPIO > Systick > Timer
  @@ GPIOTE to priority 0
  ldr r0, =ADR_NVIC
  ldr r1, =OFS_NVIC_IPR1
  add r0, r1
  mov r1, 0
  mov r2, 21
  mov r3, 3
  bl copy_bits

  @@ Systick to priority 1
  ldr r0, =ADR_SCB_SHPR3
  mov r1, 1
  mov r2, 29
  mov r3, 3
  bl copy_bits

  @ TIMER0 to priority 2
  ldr r0, =ADR_NVIC
  ldr r1, =OFS_NVIC_IPR2
  add r0, r1
  mov r1, 2
  mov r2, 5
  mov r3, 3
  bl copy_bits

  @@@@ Set GPIO Output Defaults
  @@ Set P0.02 to output mode
  ldr r0, =ADR_P0
  ldr r1, =OFS_GPIO_DIR
  mov r2, 2
  bl set_bit
  @ Set P0.02 to default high
  ldr r0, =ADR_P0
  ldr r1, =OFS_GPIO_OUT
  mov r2, 2
  bl set_bit

  @@@@ Set GPIO Input Defaults
  @ Enable GPIOTE Falling Edge Interrupt
  mov r0, 4 @ Pin 4
  mov r1, 0 @ Port 0
  mov r2, 2 @ HiToLo
  bl enable_GPIOTE

  @@@@ Init Timer0 (doesn't start it or set the count target)
  bl init_TIMER0

  @@@@ Set Systick Defaults
  @ Set reload value for 1ms interrupt
  ldr r0, =RVR_1MS
  bl set_SysTick
  @ Start SysTick interrupt
  bl start_SysTick

loop:
  nop
  b loop
.size main, .-main


@ Sender interrupt
.type SysTick_Handler, %function
SysTick_Handler:
  push {lr}
  nop
  pop {lr}
  bx lr
.size SysTick_Handler, .-SysTick_Handler


@ This interrupt exists to wakeup the receiver, it can also be used to finalize the 
@ received message if you wish.
.type GPIOTE_IRQHandler, %function
GPIOTE_IRQHandler:
  push {lr}
  @ Write your wakeup etc. code here \/\/\/


  @ Clear GPIOTE event
  ldr r0, =ADR_GPIOTE
  ldr r1, =OFS_GPIOTE_EVENTS_IN0
  mov r2, 0
  bl clear_bit
  bl sync
  pop {lr}
  bx lr
.size GPIOTE_IRQHandler, .-GPIOTE_IRQHandler


.type TIMER0_IRQHandler, %function
TIMER0_IRQHandler:
  push {lr}
  @ Write your timer receive code here \/\/\/

receive_done:
  @ Clear this event
  ldr r0, =ADR_TIMER0
  ldr r1, =OFS_TIMER_EVENTS_COMPARE0
  mov r2, 0
  bl clear_bit
  bl sync
  pop {lr}
  bx lr
.size TIMER0_IRQHandler, .-TIMER0_IRQHandler


@@@@ Helper functions @@@@
.type enable_GPIOTE, %function
@ Enables the GPIOTE (config 0) interrupt and clears any pending bits for it
@ --parameters--
@ r0: pin
@ r1: port
@ r2: interrupt type (0: None, 1: LoToHi, 2: HiToLo, 3: Toggle)
enable_GPIOTE:
  push {lr}
  push {r0 - r2}
  @ Clear events incase they were pending
  @ Clear GPIOTE event
  ldr r0, =ADR_GPIOTE
  ldr r1, =OFS_GPIOTE_EVENTS_IN0
  mov r2, 0
  bl clear_bit
  @ Clear NVIC
  ldr r0, =ADR_NVIC
  ldr r1, =OFS_NVIC_ICPR0
  mov r2, 6
  bl set_bit
  bl sync
  @ Set pull down resistor
  ldr r0, =ADR_P0
  ldr r1, =OFS_GPIO_PIN_CONF4
  add r0, r1
  mov r1, 1
  mov r2, 2
  mov r3, 2
  bl copy_bits
  @ Enable the interrupt
  pop {r0 - r2}
  lsl r0, 8
  lsl r1, 13
  lsl r2, 16
  orr r2, r0
  orr r2, r1
  orr r2, 1 @ Enable
  ldr r0, =ADR_GPIOTE
  ldr r1, =OFS_GPIOTE_CONFIG0
  str r2, [r0, r1]
  @ Enable GPIOTE Interrupt
  ldr r0, =ADR_GPIOTE
  ldr r1, =OFS_GPIOTE_INTENSET
  mov r2, 0b1
  str r2, [r0, r1]
  @ Enable GPIOTE (interrupt #6 = NVIC_GPIOTE_ID) in NVIC_ISER0
  @ NVIC_ISER0: B3.4.4 in ARMv7-M Reference Manual
  ldr r0, =ADR_NVIC
  ldr r1, =OFS_NVIC_ISER0
  mov r2, 6
  bl set_bit
  pop {lr}
  bx lr
.size enable_GPIOTE, .-enable_GPIOTE


.type disable_GPIOTE, %function
@ Disables the GPIOTE interrupt.
@ --parameters--
@ none
disable_GPIOTE:
  @ Disable this interrupt
  ldr r0, =ADR_GPIOTE
  ldr r1, =OFS_GPIOTE_INTENCLR
  mov r2, 0b1
  str r2, [r0, r1] @ write to disable
  bx lr
.size disable_GPIOTE, .-disable_GPIOTE


.type start_SysTick, %function
@ Starts SysTick with interrupts enabled.
@ --parameters--
@ none
start_SysTick:
  push {lr}
  @ Enable systick
  ldr r0, =ADR_SYST_CSR
  mov r1, 0b111
  mov r2, 0
  mov r3, 3
  bl copy_bits
  pop {lr}
  bx lr
.size start_SysTick, .-start_SysTick


.type stop_SysTick, %function
@ Stops SysTick.
@ --parameters--
@ none
stop_SysTick:
  push {lr}
  @ Disable systick
  ldr r0, =ADR_SYST_CSR
  mov r1, 0b100
  mov r2, 0
  mov r3, 3
  bl copy_bits
  pop {lr}
  bx lr
.size stop_SysTick, .-stop_SysTick


.type set_SysTick, %function
@ Sets the reload value for SysTick.
@ --parameters--
@ r0: SysTick reload value
set_SysTick:
  ldr r1, =ADR_SYST_RVR
  str r0, [r1]
  bx lr
.size set_SysTick, .-set_SysTick


.type reset_SysTick, %function
@ Resets the current count value for SysTick to 0.
@ --parameters--
@ none
reset_SysTick:
  @ Reset systick (any writes to CVR cause it to go to 0)
  ldr r0, =ADR_SYST_CVR
  mov r1, 1
  str r1, [r0]
  bx lr
.size reset_SysTick, .-reset_SysTick


.type start_TIMER0, %function
@ Starts the timer.
@ --parameters--
@ none
start_TIMER0:
  @ Start TIMER0
  ldr r0, =ADR_TIMER0
  ldr r1, =OFS_TIMER_TASKS_START
  mov r2, 1
  str r2, [r0, r1]
  bx lr
.size start_TIMER0, .-start_TIMER0


.type stop_TIMER0, %function
@ Stops the timer.
@ --parameters--
@ none
stop_TIMER0:
  @ Stop TIMER0
  ldr r0, =ADR_TIMER0
  ldr r1, =OFS_TIMER_TASKS_STOP
  mov r2, 1
  str r2, [r0, r1]
  bx lr
.size stop_TIMER0, .-stop_TIMER0


.type set_TIMER0, %function
@ Sets the new compare value for TIMER0.
@ Requires TIMER0 to be stopped.
@ --parameters--
@ r0: time in microseconds for interrupt rate
set_TIMER0:
  push {r0}
  @ Set prescaler to 4 to get a 1 microsecond interrupt granularity
  ldr r0, =ADR_TIMER0
  ldr r1, =OFS_TIMER_PRESCALER
  mov r2, 4
  str r2, [r0, r1]

  @ Set Compare value
  pop {r0}
  mov r2, r0
  ldr r0, =ADR_TIMER0
  ldr r1, =OFS_TIMER_CC0
  str r2, [r0, r1]
  bx lr
.size set_TIMER0, .-set_TIMER0


.type clear_TIMER0, %function
@ Clears the current count value of the timer.
@ --parameters--
@ none
clear_TIMER0:
  @ Clear the internal timer count register
  ldr r0, =ADR_TIMER0
  ldr r1, =OFS_TIMER_TASKS_CLEAR
  mov r2, 1
  str r2, [r0, r1]
  bx lr
.size clear_TIMER0, .-clear_TIMER0


.type init_TIMER0, %function
@ Inits the timer.
@ --parameters--
@ none
init_TIMER0:
@@@@ Set Timer Defaults
  @ Timers operate slightly differently to SysTick:
  @ - SysTick counts down from a reload value to 0
  @ - Timers count up from 0 and can have multiple trigger points
  @ - Timers do not necessarily reset when they hit trigger points, this is something that can be configured
  @ - To read ther current value of a timer we need to trigger a "value capture" event
  @ - SysTick counts at a rate of 64MHz when attached to the CPU clock
  @ - Timers count at a rate of 16MHz by default, and have further configuration with a prescaler (explained below)
  @ TIMERX counts at a rate of 16MHz (1/4 of the cpu speed, so it counts by 1 every 4 cpu clock cycles)
  @ TIMERX also has a prescaler which changes the *actual* count rate (how much it will count up in 1 second) by the formula:
  @ fTIMER = 16 MHz / (2^PRESCALER)
  @ A nice default for the PRESCALER is 4, this gives us a 1000000Hz count rate, or simply each counter increment = 1 microsecond
  push {lr}
  @@ Set to timer mode
  ldr r0, =ADR_TIMER0
  ldr r1, =OFS_TIMER_MODE
  mov r2, 0
  str r2, [r0, r1]

  @ Set TIMER count value to 32bit mode
  ldr r0, =ADR_TIMER0
  ldr r1, =OFS_TIMER_BITMODE
  mov r2, 3
  str r2, [r0, r1]

  @ Set prescaler to 4 to get a 1 microsecond interrupt granularity
  ldr r0, =ADR_TIMER0
  ldr r1, =OFS_TIMER_PRESCALER
  mov r2, 4
  str r2, [r0, r1]

  @ Clear the internal timer count register
  ldr r0, =ADR_TIMER0
  ldr r1, =OFS_TIMER_TASKS_CLEAR
  mov r2, 1
  str r2, [r0, r1]

  @ Set compare event0 to trigger a clear of the timer value 
  @ (this basically means when the timer counts up to the value in CC0 it resets the count to 0 automatically)
  ldr r0, =ADR_TIMER0
  ldr r1, =OFS_TIMER_SHORTS
  mov r2, 0
  bl set_bit

  @ Enable Interrupt on timer compare(0)
  ldr r0, =ADR_TIMER0
  ldr r1, =OFS_TIMER_ITENSET
  mov r2, (0b1 << 16)
  str r2, [r0, r1]

  @ Enable TIMER0 Interrupt (interrupt #8 = TIMER0_ID) in NVIC_ISER0
  @ NVIC_ISER0: B3.4.4 in ARMv7-M Reference Manual
  ldr r0, =ADR_NVIC
  ldr r1, =OFS_NVIC_ISER0
  mov r2, 8
  bl set_bit
  pop {lr}
  bx lr
.size init_TIMER0, .-init_TIMER0


.type sync, %function
@ Sometimes we just wanna wait a bit to make sure memory triggered operations 
@ run to completion before we continue.
sync:
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  bx lr
.size sync, .-sync


.data
@ Add your state for sender and receiver here
SENDER_DATA:
  .word 0

RECEIVER_DATA:
  .word 0