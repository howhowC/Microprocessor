	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	result: .word 0
	max_size: .word 0
.text
	.equ m, 156
	.equ n, 192
	.global GCD_init

GCD_init:
	ldr r0, =m
	ldr r1, =n
	ldr r3, =result
	ldr r5, =max_size
	mov r2, #1
	mov r4, #0

	bl GCD
	// if the program reach this point, the calculation is done.
	str r2, [r3]
	str r4, [r5]
	b InfiniteLoop
/*
	r0: a r1: b
	r2: return value
	r3: address of return
	r4: result of max_size
	r5: address of max_size
	r6: a%2
	r7: b%2
	r8: r6&r7
	r9:
*/


GCD:
add r4, r4, #3
push {r0,r1,lr}

	cmp r0, #0
	ble a_zero
	cmp r1, #0
	ble b_zero
	and r6, r0, #1
	and r7, r1, #1
	orr r8, r6, r7
	cmp r8, #0
	beq div2
	cmp r6, #0
	beq adiv2
	cmp r7, #0
	beq bdiv2
	cmp r0, r1
	ble aleb
	bgt agtb

	a_zero:
		mov r2, r1
		b end
	b_zero:
		mov r2, r0
		b end
	div2:
		lsr r0, r0, #1
		lsr r1, r1, #1
		bl GCD
		mov r2, r2, asl #1
		b end
	adiv2:
		lsr r0, r0, #1
		bl GCD
		b end
	bdiv2:
		lsr r1, r1, #1
		bl GCD
		b end
	aleb:
		sub r1, r1, r0
		bl GCD
		b end
	agtb:
		sub r0, r0, r1
		bl GCD
		b end
end:
	pop {r0,r1,pc}

InfiniteLoop:
	b InfiniteLoop
