	.syntax unified
	.cpu cortex-m4
	.thumb
.text
	.global main
 .equ N,3

fib:
 	//TODO
 	movs R1, #0 //a
 	movs R2, #1 //b
 	movs R3, #1 //i
L1:
	cmp  R0,#100
	bgt  L2
	movs R5,R2
	adds R2,R2,R1
	bvs L3
	movs R1,R5
	adds R3,#1
	cmp  R3,R0
	ble  L1
 	movs R4,R2
 	bx lr
L2:
	movs R4,#-1
	bx lr
L3:
	movs R4,#-2
	bx lr
main:
	movs R0, #N
	subs R0,R0,#1
	bl fib
L: b L
