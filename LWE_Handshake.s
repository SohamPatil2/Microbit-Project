.syntax unified
.cpu cortex-m4
.thumb

// Initialising the constants
.equ MATRIX_SIZE, 16
.equ MATRIX_DIMENSION, 4
.equ VECTOR_SIZE, 4

// We save our answers here, uninitialised ram.
.section .bss
.align 2
public_b: .space VECTOR_SIZE
hint_u: .space VECTOR_SIZE
final_v: .space 1
chacha20_key: .space 32

// We store our generated keys here, initialised ram. We are using dummy values currently but we will overwrite them later using RNG function calls.
.section .data
.align 2
matrix_A: .byte 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
secret_s: .byte 1, 0, 1, 1
error_e: .byte 1, -1, 0, 1

// Executable code here.
.section .text
.global lwe_generate_keypair
.global lwe_send_public_key
.global lwe_build_chacha_key
.align 2    

lwe_generate_keypair:
    @ --- Block 1: Setup and Protection ---
    PUSH {r4-r11, lr}       @ Save non-volatile registers and return address to the stack

    LDR r0, =matrix_A       @ r0 = Pointer to public matrix A
    LDR r1, =secret_s       @ r1 = Pointer to secret vector s
    LDR r2, =error_e        @ r2 = Pointer to error vector e
    LDR r3, =public_b       @ r3 = Pointer to destination public key b

    @ --- Block 2: The Row Loop (Outer) ---
    MOV r4, #0              @ r4 = Row counter (starts at 0)
        
    row_loop:
        CMP r4, #4              @ Are we done with all 4 rows?
        BEQ end_row_loop        @ If yes, exit the outer loop

        MOV r5, #0              @ r5 = Accumulator for the dot product (reset to 0 for each row)
        MOV r6, #0              @ r6 = Column counter (starts at 0)
        MOV r7, r1              @ r7 = Temp pointer to 's'. We MUST reset this to the top of 's' for every row!

            @ --- Block 3: The Column Loop (Inner / Dot Product) ---
        col_loop:
            CMP r6, #4              @ Are we done with all 4 columns?
            BEQ end_col_loop        @ If yes, exit the inner loop

            LDRB r8, [r0], #1       @ Load 1 byte of A into r8, then advance A pointer by 1
            LDRB r9, [r7], #1       @ Load 1 byte of s into r9, then advance temp s pointer by 1
            
            MLA r5, r8, r9, r5      @ Math Engine: r5 = (r8 * r9) + r5

            ADD r6, r6, #1          @ Increment column counter
            B col_loop              @ Loop back for the next column

            @ --- Block 4: Error Addition and Modulo ---
        end_col_loop:
            LDRB r10, [r2], #1      @ Load 1 byte of error e into r10, then advance e pointer by 1
            ADD r5, r5, r10         @ Add the error to our dot product total (b = As + e)

            AND r5, r5, #0xFF       @ Bitwise AND with 255. This instantly applies Modulo 256!

            STRB r5, [r3], #1       @ Store the final calculated byte into public_b RAM, advance b pointer

            ADD r4, r4, #1          @ Increment row counter
            B row_loop              @ Loop back to calculate the next row

        @ --- Block 5: Cleanup and Return ---
    end_row_loop:
        POP {r4-r11, pc}        @ Restore all saved registers and jump back to main.s

@ ─────────────────────────────────────────
@ Function: lwe_send_public_key
@ Goal: Transmits the 4 bytes of public_b over UART
@ ─────────────────────────────────────────
lwe_send_public_key:
    @ --- Setup and Protection ---
    PUSH {r4, r5, lr}       @ Save registers and the return address to main.s

    LDR r5, =public_b       @ r5 = Pointer to the public_b memory address
    MOV r4, #0              @ r4 = Loop counter (starts at 0)

    send_loop:
        CMP r4, #4              @ Have we sent all 4 bytes?
        BEQ end_send_loop       @ If equal to 4, branch out of the loop

        @ --- The Payload Handoff ---
        LDRB r0, [r5], #1       @ Load 1 byte from RAM into r0, and advance the r5 pointer by 1
        BL uart_tx              @ Call the UART function. It will transmit whatever is inside r0!

        ADD r4, r4, #1          @ Increment our loop counter
        B send_loop             @ Jump back up to send the next byte

    end_send_loop:
        @ --- Cleanup and Return ---
        POP {r4, r5, pc}        @ Restore registers and teleport back to main.s

@ ─────────────────────────────────────────
@ Function: lwe_build_chacha_key
@ Goal: Receive 256 bits, decrypt them, and pack them into the 32-byte ChaCha20 key.
@ ─────────────────────────────────────────
lwe_build_chacha_key:
    PUSH {r4-r11, lr}       @ Protect all registers used by main.s

    @ --- Block 1: The Outer Byte Loop (32 bytes) ---
    MOV r4, #0              @ r4 = Byte Counter (0 to 31)

    byte_loop:
        CMP r4, #32             @ Are we done with all 32 bytes?
        BEQ end_byte_loop       @ If yes, the whole key is finished!
        
        MOV r5, #0              @ r5 = Bit Counter (0 to 7)
        MOV r6, #0              @ r6 = The single 8-bit byte we are building

        @ --- Block 2: The Inner Bit Loop (8 bits) ---
    bit_loop:
        CMP r5, #8              @ Are we done with all 8 bits for this byte?
        BEQ end_bit_loop

        @ -- Step 2A: Receive 'u' (4 bytes) --
        LDR r7, =hint_u
        MOV r8, #0              @ Loop counter for receiving u
    recv_u:
        CMP r8, #4
        BEQ recv_v
        BL uart_rx              @ Wait for laptop to send 1 byte of u
        STRB r0, [r7], #1       @ Store in RAM, advance pointer
        ADD r8, r8, #1
        B recv_u

    recv_v:
        @ -- Step 2B: Receive 'v' (1 byte) --
        BL uart_rx
        MOV r8, r0              @ r8 now holds the payload 'v' 

        @ -- Step 2C: Calculate Dot Product (s * u) --
        LDR r7, =hint_u         @ r7 points to the u we just received
        LDR r9, =secret_s       @ r9 points to our secret key
        MOV r10, #0             @ r10 = Accumulator for dot product
        MOV r11, #0             @ r11 = loop counter

    dot_loop:
        CMP r11, #4
        BEQ math_finish
        LDRB r0, [r7], #1       @ Load 1 byte of u
        LDRB r1, [r9], #1       @ Load 1 byte of s
        MLA r10, r0, r1, r10    @ r10 = (u * s) + r10
        ADD r11, r11, #1
        B dot_loop

    math_finish:
        @ --- Block 3: Decapsulate and Strip Noise ---
        SUB r8, r8, r10         @ r8 = v - (s * u)
        AND r8, r8, #0xFF       @ Bitwise AND applies Modulo 256 instantly

        @ --- Block 4: The Threshold Check (Is it 0 or 1?) ---
        MOV r9, #0              @ r9 = Our extracted bit (Default to 0)
        
        CMP r8, #64             @ Compare the answer to 64
        BLT shift_bit           @ If Less Than 64, it's close to 0. (Bit = 0)
        
        CMP r8, #192            @ Compare the answer to 192
        BGE shift_bit           @ If Greater Than/Equal to 192, it's close to 0. (Bit = 0)
        
        MOV r9, #1              @ If it didn't jump, it's safely between 64 and 191. It's close to 128! (Bit = 1)

    shift_bit:
        @ --- Block 5: Shift and Store ---
        LSL r6, r6, #1          @ Logical Shift Left: Shift our byte left by 1 to make room
        ORR r6, r6, r9          @ Bitwise OR: Insert our extracted bit (r9) into the empty slot

        ADD r5, r5, #1          @ Increment bit counter
        B bit_loop              @ Go receive the next bit!

    end_bit_loop:
        @ --- We finished 8 bits! Store the completed byte ---
        LDR r7, =chacha20_key   @ r7 = Base address of our 32-byte key buffer
        STRB r6, [r7, r4]       @ Store the completed byte (r6) into the buffer at offset (r4)

        ADD r4, r4, #1          @ Increment byte counter
        B byte_loop             @ Go build the next byte!

    end_byte_loop:
        @ --- Master Loop Complete ---
        POP {r4-r11, pc}        @ Restore registers and return to main.s