.syntax unified
.cpu cortex-m4
.thumb

@ ─────────────────────────────────────────
@ Command bytes from laptop
@ ─────────────────────────────────────────
.equ CMD_LWE,    'L'    @ 0x4C = LWE command
.equ CMD_CHACHA, 'C'    @ 0x43 = ChaCha command

@ ─────────────────────────────────────────
.section .text
.global _start
.global main

@ ─────────────────────────────────────────
@ _start
@ Entry point of the program
@ ─────────────────────────────────────────
_start:
    B main                  @ jump to main

@ ─────────────────────────────────────────
@ main
@ Input:  nothing
@ Output: never returns (infinite loop)
@ ─────────────────────────────────────────
main:
    PUSH {lr}               @ save return address

    @ ── Step 1: Initialize UART ──
    BL init_uart            @ setup UART first

    @ ── Step 2: Main loop forever ──
main_loop:

    @ ── Step 3: Wait for command from laptop ──
    BL uart_rx              @ wait and receive 1 byte
                            @ r0 = received command byte

    @ ── Step 4: Check if command is 'L' ──
    CMP r0, #CMD_LWE        @ is it 'L'?
    BEQ do_lwe              @ YES → go to LWE

    @ ── Step 5: Check if command is 'C' ──
    CMP r0, #CMD_CHACHA     @ is it 'C'?
    BEQ do_chacha           @ YES → go to ChaCha

    @ ── Unknown command → ignore and loop ──
    B main_loop             @ go back and wait again

@ ─────────────────────────────────────────
@ do_lwe
@ Called when laptop sends 'L'
@ ─────────────────────────────────────────
do_lwe:
    @ TODO: BL lwe_generate_keypair  @ Member 3 adds this
    B main_loop             @ go back to main loop

@ ─────────────────────────────────────────
@ do_chacha
@ Called when laptop sends 'C'
@ ─────────────────────────────────────────
do_chacha:
    @ TODO: BL chacha_stream_xor     @ Member 4 adds this
    B main_loop             @ go back to main loop
