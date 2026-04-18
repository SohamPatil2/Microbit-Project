all:
	arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -nostdlib -o program.elf main.s init_uart.s uart_tx.s uart_rx.s

clean:
	rm -f program.elf
