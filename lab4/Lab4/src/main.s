    .syntax unified
    .cpu cortex-m4
    .thumb


	.text
	.global main

main:
	BL Lab4_3
	mov r0, #1
L:
	B L
