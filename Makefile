all:
	arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -nostdlib -o program.elf init_uart.s

clean:
	rm -f program.elf
