.syntax unified
.cpu cortex-m4
.thumb
.data
num: .byte 0, 0, 0, 0, 0, 0, 0, 0
.text
	.equ RCC_AHB2ENR,   0x4002104C

	.equ GPIOC_MODER,   0x48000800
	.equ GPIOC_IDR,     0x48000810

	.global read_input_start
	.global delay


read_input_start:
	push {lr}
	mov  r2, #0
read_input:
	/*
	r0: input of PC13
	r1: address of GPIOC IDR
	r2: how many times has 1 been read
	*/
	ldr  r1, =GPIOC_IDR
	ldr  r0, [r1]
	lsr  r0, #13// read the input of PC13
	cmp  r0, #0
	beq  read0
	// read1
	ldr  r3, =#3000
	cmp  r2, r3// press
	bgt  press
	mov  r2, #0
	b    end

	read0:
	add  r2, r2, #1

	end:

b read_input

press:

pop  {pc}

delay:
	ldr  r3, =#300
	L1:
		ldr  r4, =#1000
		L2:
			subs r4, #1
		bne L2
		subs R3, #1
	bne L1
	bx lr


