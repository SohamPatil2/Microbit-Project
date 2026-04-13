.syntax unified
.cpu cortex-m4
.thumb

.global _start
_start:
    MOV r0, #5
    MOV r1, #10
    ADD r2, r0, r1
    B .
