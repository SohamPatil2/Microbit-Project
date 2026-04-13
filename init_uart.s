.syntax unified
.cpu cortex-m4
.thumb

@ ─────────────────────────────────────────
@ UARTE0 Register Addresses (nRF52833)
@ ─────────────────────────────────────────
.equ UARTE0_PSEL_TXD,   0x4000250C
.equ UARTE0_PSEL_RXD,   0x40002514
.equ UARTE0_BAUDRATE,   0x40002524
.equ UARTE0_CONFIG,     0x4000256C
.equ UARTE0_ENABLE,     0x40002500

.equ BAUD_115200,       0x01D7E000
.equ UART_TX_PIN,       6
.equ UART_RX_PIN,       8
.equ UART_ENABLE_VAL,   8

@ ─────────────────────────────────────────
.section .text
.global init_uart

init_uart:
    PUSH    {lr}

    @ Step 1: Set TX pin
    LDR     r0, =UARTE0_PSEL_TXD
    MOV     r1, #UART_TX_PIN
    STR     r1, [r0]

    @ Step 2: Set RX pin
    LDR     r0, =UARTE0_PSEL_RXD
    MOV     r1, #UART_RX_PIN
    STR     r1, [r0]

    @ Step 3: Set baud rate
    LDR     r0, =UARTE0_BAUDRATE
    LDR     r1, =BAUD_115200
    STR     r1, [r0]

    @ Step 4: No parity, no flow control
    LDR     r0, =UARTE0_CONFIG
    MOV     r1, #0
    STR     r1, [r0]

    @ Step 5: Enable UARTE0
    LDR     r0, =UARTE0_ENABLE
    MOV     r1, #UART_ENABLE_VAL
    STR     r1, [r0]

    POP     {pc}

