.syntax unified
.cpu cortex-m4
.thumb
.data
num: .int 0, 0, 0, 0, 0, 0, 0, 0
.text
	.equ RCC_AHB2ENR,   0x4002104C

	.equ GPIOA_MODER,   0x48000000
	.equ GPIOA_OTYPER,  0x48000004
	.equ GPIOA_OSPEEDR, 0x48000008
	.equ GPIOA_PUPDR,   0x4800000C
	.equ GPIOA_ODR,     0x48000014
	.equ GPIOA_BSRR,    0x48000018
	.equ GPIOA_BRR,     0x48000028

	.equ GPIOC_MODER,   0x48000800
	.equ GPIOC_IDR,     0x48000810

	.global MAX7219Send
	.global MAX7219SendHalf
	.global show_value
	.global delay
	.global read_input_start


MAX7219Send:
	//input parameter: r0 is ADDRESS , r1 is DATA
	// send r0 << 8 | r1
	// use this only if you don't care about other GPIOA output!
	push {r2, r3, r4, lr}
	and  r1, r1, #0xFF// mask excessive bits in r1
	lsl  r0, r0, #8
	orr  r0, r0, r1
	mov  r2, #12
	ldr  r3, =GPIOA_ODR
	for_loop1:
		subs r2, r2, #1
		lsr  r4, r0, r2
		and  r1, r4, #1// take the last bit of r0
		str  r1, [r3]
		mov  r1, #0b10000// clock posedge
		str  r1, [r3]
		bne  for_loop1

	mov r1, #0b10// CS posedge
	str r1, [r3]

	pop {r2, r3, r4, pc}


MAX7219SendHalf:
	// different from MAX7219Send, this function only
	// send 4 least significant bits
	// use this only if you don't care about other GPIOA output!
	//input parameter: r0 is ADDRESS , r1 is DATA
	// send r0 << 8 | r1
	push {r2, r3, r4, lr}
	and  r1, r1, #0xF// mask excessive bits in r1
	lsl  r0, r0, #8
	orr  r0, r0, r1
	mov  r2, #12
	ldr  r3, =GPIOA_ODR
	for_loop2:
		subs r2, r2, #1
		lsr  r4, r0, r2
		and  r1, r4, #1// take the last bit of r0
		str  r1, [r3]
		mov  r1, #0b10000// clock posedge
		str  r1, [r3]
		bne  for_loop2

	mov r1, #0b10// CS posedge
	str r1, [r3]

	pop {r2, r3, r4, pc}




show_value:

	/*
	used registers:
	r4: num to print (copied from r0)
	r5: address for the printed numbers
	r6: # of digits
	r7: 10
	*/

	push {r4-r7, lr}

	mov  r4, r0
	//ldr r4, =#123456// test
	cmp  r4, #0
	blt  print_minus1
	ldr  r5, =num
	adds r5, #28// set the address to the end of arr

	mov  r6, #0
	mov  r7, #10
	find_digits:
		udiv r0, r4, r7 // r0 = r4 / 10

		mul  r1, r0, r7
		subs r1, r4, r1 // r1= r4 % 10

		str  r1, [r5]
		subs r5, #4
		adds r6, #1

		mov  r4, r0
		cmp  r0, #0
		bne  find_digits

	ldr  r5, =num
	adds r5, #28// set the address to the end of arr
	cmp  r6, #3
	bge  GE3
		// LE3
		mov r6, #3
	GE3:
	mov  r0, #0xB// scan limit
	mov  r1, r6
	sub  r1, r1, #1
	bl MAX7219Send
	mov  r7, #1// r7 is now the digit to send

	print_loop:

		mov  r0, r7// digit r7-1
		ldr  r1, [r5]
		cmp  r7, #3
		bne  no_dot
		// dot
			orr  r1, #0x80
		no_dot:
		bl MAX7219Send
		sub  r5, #4
		cmp  r7, r6
		add  r7, #1
		ble  print_loop

	b end1
	print_minus1:

		mov  r0, #0xB// scan limit
		mov  r1, #0x1
		bl MAX7219Send

		mov  r0, #0x1// digit 0
		mov  r1, #0x1
		bl MAX7219Send

		mov  r0, #0x2// digit 1
		mov  r1, #0xA
		bl MAX7219Send

	end1:
	pop  {r4-r7, pc}

delay:
	ldr  r3, =#50
	L1:
		ldr  r4, =#500
		L2:
			subs r4, #1
		bne L2
		subs R3, #1
	bne L1
bx lr

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

