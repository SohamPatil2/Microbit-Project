.syntax unified
.cpu cortex-m4
.thumb

@ UARTE0 RX Register Addresses (nRF52833)
.equ UARTE0_RXD_PTR,    0x40002534
.equ UARTE0_RXD_MAXCNT, 0x40002538
.equ UARTE0_STARTRX,    0x40002000
.equ UARTE0_ENDRX,      0x40002110

@ RX Buffer in RAM
.section .data
rx_buf: .byte 0x00

.section .text
.global uart_rx

uart_rx:
    PUSH {lr}

    @ Step 1: Tell DMA where to put data
    LDR  r1, =rx_buf
    LDR  r2, =UARTE0_RXD_PTR
    STR  r1, [r2]

    @ Step 2: Tell DMA to receive 1 byte
    LDR  r2, =UARTE0_RXD_MAXCNT
    MOV  r3, #1
    STR  r3, [r2]

    @ Step 3: Clear ENDRX event
    LDR  r2, =UARTE0_ENDRX
    MOV  r3, #0
    STR  r3, [r2]

    @ Step 4: Start receiving
    LDR  r2, =UARTE0_STARTRX
    MOV  r3, #1
    STR  r3, [r2]

    @ Step 5: Wait until byte arrives
uart_rx_wait:
    LDR  r2, =UARTE0_ENDRX
    LDR  r3, [r2]
    CMP  r3, #1
    BNE  uart_rx_wait

    @ Step 6: Read received byte into r0
    LDR  r1, =rx_buf
    LDRB r0, [r1]

    POP  {pc}
