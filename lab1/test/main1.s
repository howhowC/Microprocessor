	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	result: .byte 0
.text
	.global main
  .equ X, 0x55AA
  .equ Y, 0xAA55


hamn:
  	//TODO
  	mov R3, #0
  	eors R4,R1,R0
L1:
	beq L3
	ands R5,R4,#1
	beq L2
	adds R3,R3,#1
L2:
	lsrs R4,R4,#1
	b L1
L3:
	str R3,[R2]
	bx lr
main:
	mov R0, #X
	mov R1, #Y
	ldr R2 , =result
	bl hamn
L: b L
