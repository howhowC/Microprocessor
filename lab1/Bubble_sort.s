	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	arr1: .byte 0x19, 0x34, 0x14, 0x32, 0x52, 0x23, 0x61, 0x29
	arr2: .byte 0x18, 0x17, 0x33, 0x16, 0xFA, 0x20, 0x55, 0xAC
.text
	.global main
	.equ len, 7
do_sort: //TODO
	movs r1, #0		// i
F1:
	cmp r1, r8
	beq End
	movs r2, #0		// j
F2:
	subs r3, r8, r1	// n-i
	adds r7, r2, #1	// j+1
	ldrb r4, [r0, r2] // tmp x1
	ldrb r5, [r0, r7] // tmp x2
	cmp r4, r5		// 比較 tmp x1 x2
	bgt swap			// if > swap
	adds r2, r2, #1	// j++
	cmp r2, r3
	blt F2
	beq F3
F3:
	adds r1, r1, #1	// i++
	b F1
End:
	bx lr
swap:
	movs r6, r4		// r6 = tmp
	movs r4, r5
	movs r5, r6		// finish swap
	strb r4, [r0, r2]
	strb r5, [r0, r7] // storage
	adds r2, r2, #1
	cmp r2, r3
	blt F2
	beq F3

main:
	movs r8, #len
	ldr r0, =arr1
	bl do_sort
	ldr r0, =arr2
	bl do_sort
L: b L
