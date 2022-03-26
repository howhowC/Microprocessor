	.syntax unified
	.cpu cortex-m4
	.thumb
.data

.text
	.global main

main:
	b GCD_init
	L: b L
