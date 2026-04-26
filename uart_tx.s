.syntax unified
.cpu cortex-m4
.thumb

@ ─────────────────────────────────────────
@ UARTE0 TX Register Addresses (nRF52833)
@ ─────────────────────────────────────────
.equ UARTE0_TXD_PTR,    0x40002544  @ address of TX buffer
.equ UARTE0_TXD_MAXCNT, 0x40002548  @ how many bytes to send
.equ UARTE0_STARTTX,    0x40002008  @ start sending
.equ UARTE0_ENDTX,      0x40002120  @ sending done event

@ ─────────────────────────────────────────
@ TX Buffer in RAM
@ ─────────────────────────────────────────
.section .data
tx_buf: .byte 0x00      @ 1 byte box to hold data

@ ─────────────────────────────────────────
.section .text
.global uart_tx

@ ─────────────────────────────────────────
@ uart_tx
@ Input:  r0 = byte to send (example: 65 = 'A')
@ Output: nothing
@ Clobbers: r1, r2, r3
@ ─────────────────────────────────────────
uart_tx:
    PUSH {r0, lr}               @ save r0 and return address

    @ ── Step 1: Put byte into tx_buf ──
    LDR  r1, =tx_buf            @ r1 = address of tx_buf
    STRB r0, [r1]               @ write byte into tx_buf

    @ ── Step 2: Tell DMA where the data is ──
    LDR  r2, =UARTE0_TXD_PTR   @ r2 = address of PTR register
    STR  r1, [r2]               @ write tx_buf address into PTR

    @ ── Step 3: Tell DMA to send 1 byte ──
    LDR  r2, =UARTE0_TXD_MAXCNT @ r2 = address of MAXCNT register
    MOV  r3, #1                  @ r3 = 1 byte
    STR  r3, [r2]                @ write 1 into MAXCNT

    @ ── Step 4: Clear ENDTX event ──
    LDR  r2, =UARTE0_ENDTX      @ r2 = address of ENDTX
    MOV  r3, #0                  @ r3 = 0 = clear it
    STR  r3, [r2]                @ clear the event

    @ ── Step 5: Start sending ──
    LDR  r2, =UARTE0_STARTTX    @ r2 = address of STARTTX
    MOV  r3, #1                  @ r3 = 1 = GO!
    STR  r3, [r2]                @ start TX

    @ ── Step 6: Wait until sending is done ──
uart_tx_wait:
    LDR  r2, =UARTE0_ENDTX      @ r2 = address of ENDTX event
    LDR  r3, [r2]               @ r3 = read what is inside
    CMP  r3, #1                 @ is it 1? (done?)
    BNE  uart_tx_wait           @ NO  → keep waiting
                                @ YES → fall through

    POP  {r0, pc}               @ restore r0 and return
