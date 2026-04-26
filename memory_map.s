.syntax unified
.cpu cortex-m4
.thumb

@ ═══════════════════════════════════════════════════════════
@ FILE: memory_map.s
@ MEMBER: 2 — Entropy & Memory Manager
@
@ PURPOSE:
@   This is the SINGLE SOURCE OF TRUTH for every RAM buffer
@   in the project.  No other member should define .data or
@   .bss buffers without cross-checking this file first.
@
@   nRF52833 RAM layout:
@     0x20000000 – 0x20010000   (64 KB total SRAM)
@
@   Segment assignment (all addresses are byte-aligned):
@     [Member 1 – UART]     tx_buf, rx_buf  (from uart_tx/rx.s)
@     [Member 2 – RNG/State] rng_seed_accum
@     [Member 3 – LWE]      lwe_s, lwe_e, lwe_b, lwe_A,
@                            lwe_ciphertext_u, lwe_ciphertext_v,
@                            lwe_shared_secret
@     [Member 4 – ChaCha20] chacha_state, chacha_keystream,
@                            chacha_output_buf
@
@ ═══════════════════════════════════════════════════════════

@ ───────────────────────────────────────────────────────────
@ LWE Parameters  (scalar / 1-D version as per project spec)
@   n   = dimension of vectors
@   q   = modulus (must fit in 16 bits for easy modular arith)
@ ───────────────────────────────────────────────────────────
.equ LWE_N,         16          @ vector length (16 elements)
.equ LWE_Q,         257         @ prime modulus  (fits in 9 bits)
.equ LWE_ELEM_SIZE, 4           @ each element stored as 32-bit word
.equ LWE_VEC_BYTES, 64         @ LWE_N * LWE_ELEM_SIZE  = 64 bytes

@ ───────────────────────────────────────────────────────────
@ ChaCha20 Parameters  (standard 256-bit key, 96-bit nonce)
@ ───────────────────────────────────────────────────────────
.equ CHACHA_STATE_WORDS,    16  @ 16 x 32-bit words = 512-bit block
.equ CHACHA_STATE_BYTES,    64
.equ CHACHA_KEYSTREAM_BYTES,64  @ one full 64-byte keystream block
.equ CHACHA_OUTBUF_BYTES,   64  @ output buffer (same size)

@ ───────────────────────────────────────────────────────────
@ .data  — zero-initialised named buffers  (placed by linker)
@
@   Members 3 and 4 should reference these labels as
@   extern symbols; DO NOT redefine them in other files.
@ ───────────────────────────────────────────────────────────
.section .bss

@ ── Member 2 ────────────────────────────────────────────────
.global rng_seed_accum
.align  2
rng_seed_accum:
    .space  4                   @ 32-bit running XOR accumulator
                                @ updated each call to get_random_byte

@ ── Member 3 – LWE ─────────────────────────────────────────
@ Secret vector s  (n × 32-bit words)
.global lwe_s
.align  2
lwe_s:
    .space  LWE_VEC_BYTES       @ 64 bytes   [ s[0] .. s[15] ]

@ Error vector e  (n × 32-bit words)
.global lwe_e
.align  2
lwe_e:
    .space  LWE_VEC_BYTES       @ 64 bytes   [ e[0] .. e[15] ]

@ Public key b = A·s + e  (n × 32-bit words)
.global lwe_b
.align  2
lwe_b:
    .space  LWE_VEC_BYTES       @ 64 bytes   [ b[0] .. b[15] ]

@ Public matrix A  (n × n × 32-bit words) — held in RAM
@ because n=16: 16*16*4 = 1024 bytes (1 KB).
.global lwe_A
.align  2
lwe_A:
    .space  1024                @ 1024 bytes  A[0..15][0..15]

@ Received ciphertext component u  (n × 32-bit words)
.global lwe_ciphertext_u
.align  2
lwe_ciphertext_u:
    .space  LWE_VEC_BYTES       @ 64 bytes

@ Received ciphertext component v  (1 × 32-bit word)
.global lwe_ciphertext_v
.align  2
lwe_ciphertext_v:
    .space  LWE_ELEM_SIZE       @ 4 bytes

@ Decapsulated shared secret  (1 byte — the agreed bit/byte)
.global lwe_shared_secret
.align  2
lwe_shared_secret:
    .space  4                   @ 32-bit word (low byte is the key)

@ ── Member 4 – ChaCha20 ────────────────────────────────────
@ 512-bit ChaCha20 state matrix  (16 × 32-bit words)
.global chacha_state
.align  2
chacha_state:
    .space  CHACHA_STATE_BYTES  @ 64 bytes

@ Generated keystream block  (64 bytes)
.global chacha_keystream
.align  2
chacha_keystream:
    .space  CHACHA_KEYSTREAM_BYTES

@ Ciphertext output buffer  (64 bytes)
.global chacha_output_buf
.align  2
chacha_output_buf:
    .space  CHACHA_OUTBUF_BYTES

@ ───────────────────────────────────────────────────────────
@ Quick reference — buffer start addresses at link time
@
@   Use  LDR rx, =<label>  to get the address of any buffer.
@
@   Example (Member 3):
@       LDR  r0, =lwe_s        @ r0 = &s[0]
@       LDR  r1, =LWE_N        @ r1 = 16
@       ... MLA loop over lwe_A and lwe_s ...
@
@   Example (Member 4):
@       LDR  r0, =chacha_state @ r0 = &state[0]
@ ───────────────────────────────────────────────────────────
