.syntax unified
.cpu cortex-m4
.thumb
.data
num: .byte 0, 0, 0, 0, 0, 0, 0, 0
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

	.global show_value
	.global MAX7219Send
	.global MAX7219SendHalf
	.global delay

delay:
	push {r4}
	ldr  r3, =#50
	L1:
		ldr  r4, =#500
		L2:
			subs  r4, #1
		bne  L2
		subs R3, #1
	bne  L1
	pop  {r4}
bx lr

MAX7219Send:
	//input parameter: r0 is ADDRESS , r1 is DATA
	// send r0 << 8 | r1
	push {r2-r5, lr}
	and  r1, r1, #0xFF// mask excessive bits in r1
	lsl  r0, r0, #8
	orr  r0, r0, r1
	mov  r2, #12
	ldr  r3, =GPIOA_BSRR
	ldr  r5, =GPIOA_BRR
	mov  r1, #0b10// CS negedge
	str  r1, [r5]
	for_loop1:
		mov  r1, #0b10000// clock negedge
		str  r1, [r5]
		sub  r2, r2, #1
		lsr  r4, r0, r2
		and  r1, r4, #1// take the last bit of r0
		cmp  r1, #0
		beq  reset
		// set:
			str  r1, [r3]// set PA0
			b end
		reset:
			mov  r1, #1
			str  r1, [r5]// reset PA0
		end:
		mov  r1, #0b10000// clock posedge
		str  r1, [r3]
		cmp  r2, #0
		bne  for_loop1

	mov  r1, #0b10// CS posedge
	str  r1, [r3]

	pop  {r2-r5, pc}


MAX7219SendHalf:
	// different from MAX7219Send, this function only
	// send 4 least significant bits
		//input parameter: r0 is ADDRESS , r1 is DATA
	// send r0 << 8 | r1
	push {r2-r5, lr}
	and  r1, r1, #0xF// mask excessive bits in r1
	lsl  r0, r0, #8
	orr  r0, r0, r1
	mov  r2, #12
	ldr  r3, =GPIOA_BSRR
	ldr  r5, =GPIOA_BRR
	mov  r1, #0b10// CS negedge
	str  r1, [r5]
	for_loop2:
		mov  r1, #0b10000// clock negedge
		str  r1, [r5]
		sub  r2, r2, #1
		lsr  r4, r0, r2
		and  r1, r4, #1// take the last bit of r0
		cmp  r1, #0
		beq  reset2
		// set2:
			str  r1, [r3]// set PA0
			b end2
		reset2:
			mov  r1, #1
			str  r1, [r5]// reset PA0
		end2:
		mov  r1, #0b10000// clock posedge
		str  r1, [r3]
		cmp  r2, #0
		bne  for_loop2

	mov  r1, #0b10// CS posedge
	str  r1, [r3]

	pop  {r2-r5, pc}


show_value:

	/*
	used registers:
	r5: address for the printed numbers
	r6: # of digits
	r7: 10
	*/

	push {r4-r7, lr}
	// ldr r4, =#123456// test
	// prints the value in r4
	mov  r4, r0// copy the first arguement to r4
	cmp  r4, #0
	blt  print_minus1
	ldr  r7, =#99999999
	cmp  r4, r7
	bgt  print_minus1
	ldr  r5, =num
	mov  r6, #0
	mov  r7, #10
	find_digits:
		udiv r0, r4, r7 // r0 = r4 / 10

		mul  r1, r0, r7
		subs r1, r4, r1 // r1= r4 % 10

		str  r1, [r5]
		adds r5, #1
		adds r6, #1

		mov  r4, r0
		cmp  r0, #0
		bne  find_digits

	mov  r0, #0xB// scan limit
	mov  r1, r6
	sub  r1, r1, #1
	sub  r5, #1
	bl MAX7219Send

	print_loop:

		mov  r0, r6// digit r6-1
		ldr  r1, [r5]
		bl MAX7219SendHalf
		sub  r5, #1
		subs r6, #1
		bne  print_loop

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
