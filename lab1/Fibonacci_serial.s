	.syntax unified
	.cpu cortex-m4
	.thumb
.text
	.global main
	.equ N, 70
fib: //TODO 1 1 2 3 5 8 13 21 34 55...
	movs R1, #0		// F1
 	movs R2, #1		// F2
 	movs R3, #1		// index
L1:
	cmp  R0, #100	// 檢測範圍
	bgt  L2
	movs R5, R2		// tmp
	adds R2, R2, R1
	bvs L3			// 檢測overflow
	movs R1, R5
	adds R3, #1
	cmp  R3, R0
	ble  L1
 	movs R4, R5		// ans
 	bx lr
L2:
	movs R4, #-1
	bx lr
L3:
	movs R4, #-2
	bx lr
main:
	movs R0, #N
	bl fib
L: b L
