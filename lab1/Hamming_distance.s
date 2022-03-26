	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	result: .byte 0
.text
	.global main
	.equ X, 0x55AA
	.equ Y, 0xAA55
hamm:
	//TODO
	mov R3, #0
	EORs R4, R0, R1
F1:
	beq F2
	adds R3, R3, #1 // 計算1的數量
	lsrs R4, R4, #1 // bits右移
	b F1
F2:
	str R3, [R2]
	bx lr
main:
	mov R0, #X //This code will cause assemble error. Why? And how to fix.
	mov R1, #Y
	ldr R2, =result
	bl hamm
L: b L
