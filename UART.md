cat > ~/microbit-dev/test-project/registers.md << 'EOF'
# Register Usage - Member 1 (UART & Control Flow)

## General Rule
r0  = arguments going IN to a function
r0  = result coming OUT of a function
r1  = address register (WHERE to write)
r2  = address register (WHERE to write)
r3  = data register   (WHAT to write)
lr  = link register   (return address)
pc  = program counter (current instruction)

---

## init_uart Registers

| Register | Value | Purpose |
|----------|-------|---------|
| r0 | 0x4000250C | Address of TX pin register |
| r0 | 0x40002514 | Address of RX pin register |
| r0 | 0x40002524 | Address of baud rate register |
| r0 | 0x4000256C | Address of config register |
| r0 | 0x40002500 | Address of enable register |
| r1 | 6 | TX pin number |
| r1 | 8 | RX pin number |
| r1 | 0x01D7E000 | Baud rate value 115200 |
| r1 | 0 | Config value simple mode |
| r1 | 8 | Enable value UART ON |
| lr | return address | saved by PUSH restored by POP |

---

## uart_tx Registers

| Register | Value | Purpose |
|----------|-------|---------|
| r0 | byte to send | INPUT given by caller example 65 = A |
| r1 | address of tx_buf | where byte is stored in RAM |
| r2 | 0x40002544 | address of TXD PTR register |
| r2 | 0x40002548 | address of TXD MAXCNT register |
| r2 | 0x40002120 | address of ENDTX event register |
| r2 | 0x40002008 | address of STARTTX register |
| r3 | 1 | number of bytes to send |
| r3 | 0 | clear ENDTX flag |
| r3 | 1 | start TX value |
| r3 | read value | checked in wait loop |
| lr | return address | saved by PUSH restored by POP |

---

## uart_rx Registers

| Register | Value | Purpose |
|----------|-------|---------|
| r0 | received byte | OUTPUT returned to caller example L or C |
| r1 | address of rx_buf | where received byte is stored in RAM |
| r2 | 0x40002534 | address of RXD PTR register |
| r2 | 0x40002538 | address of RXD MAXCNT register |
| r2 | 0x40002110 | address of ENDRX event register |
| r2 | 0x40002000 | address of STARTRX register |
| r3 | 1 | number of bytes to receive |
| r3 | 0 | clear ENDRX flag |
| r3 | 1 | start RX value |
| r3 | read value | checked in wait loop |
| lr | return address | saved by PUSH restored by POP |

---

## main Registers

| Register | Value | Purpose |
|----------|-------|---------|
| r0 | received command | byte from uart_rx example L or C |
| r0 | 0x4C = 76 | compared with CMD_LWE = L |
| r0 | 0x43 = 67 | compared with CMD_CHACHA = C |
| lr | return address | saved by PUSH restored by POP |

---

## RAM Buffers

| Name | Size | Purpose | Owner |
|------|------|---------|-------|
| tx_buf | 1 byte | holds byte before sending | Member 1 |
| rx_buf | 1 byte | holds byte after receiving | Member 1 |

---

## UART Hardware Addresses

| Name | Address | Purpose |
|------|---------|---------|
| UARTE0_PSEL_TXD | 0x4000250C | TX pin selection |
| UARTE0_PSEL_RXD | 0x40002514 | RX pin selection |
| UARTE0_BAUDRATE | 0x40002524 | baud rate speed |
| UARTE0_CONFIG | 0x4000256C | parity and flow control |
| UARTE0_ENABLE | 0x40002500 | UART on or off |
| UARTE0_TXD_PTR | 0x40002544 | DMA TX buffer address |
| UARTE0_TXD_MAXCNT | 0x40002548 | DMA TX byte count |
| UARTE0_STARTTX | 0x40002008 | start sending |
| UARTE0_ENDTX | 0x40002120 | sending done event |
| UARTE0_RXD_PTR | 0x40002534 | DMA RX buffer address |
| UARTE0_RXD_MAXCNT | 0x40002538 | DMA RX byte count |
| UARTE0_STARTRX | 0x40002000 | start receiving |
| UARTE0_ENDRX | 0x40002110 | receiving done event |

---

## Commands

| Command | Hex | Decimal | Who handles it |
|---------|-----|---------|----------------|
| L | 0x4C | 76 | Member 3 LWE |
| C | 0x43 | 67 | Member 4 ChaCha |

---

## Pin Usage

| Pin | Name | Direction | Purpose |
|-----|------|-----------|---------|
| P6 | TX | OUT | sends data to laptop |
| P8 | RX | IN | receives data from laptop |

EOF