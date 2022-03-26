    .syntax unified
    .cpu cortex-m4
    .thumb


	.text
	.global main
	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOA_MODER, 0x48000000
	.equ GPIOA_OTYPER, 0x48000004
	.equ GPIOA_OSPEEDR, 0x48000008
	.equ GPIOA_PUPDR, 0x4800000C
	.equ GPIOA_ODR, 0x48000014
	.equ X, 900
	.equ Y, 900


// LED on PA5
main:
	// Enable AHB2 clock
	movs	r0, #0x1
	ldr		r1, =RCC_AHB2ENR
	str		r0, [r1]

	// Set PA5 as output mode
	movs	r0, #0x5500
	ldr		r1, =GPIOA_MODER
	ldr		r2, [r1]
	and		r2, #0xFFFF00FF // Mask MODER5
	orrs	r2, r2, r0
	str		r2, [r1]

	// Default PA5 is Pull-up output, no need to set

	// Set PA5 as high speed mode
	movs	r0, #0x0
	ldr		r1 ,=GPIOA_OSPEEDR
	strh	r0, [r1]

	ldr		r1, =GPIOA_ODR

LED:
// t0
	movs	r0, #0b11100000
	strh	r0, [r1]
	bl Delay
// t1
	movs	r0, #0b11000000
	strh	r0, [r1]
	bl Delay
// t2
	movs	r0, #0b10010000
	strh	r0, [r1]
	bl Delay
// t3
	movs	r0, #0b00110000
	strh	r0, [r1]
	bl Delay
// t4
	movs	r0, #0b01110000
	strh	r0, [r1]
	bl Delay
// t5
	movs	r0, #0b00110000
	strh	r0, [r1]
	bl Delay
// t6
	movs	r0, #0b10010000
	strh	r0, [r1]
	bl Delay
// t7
	movs	r0, #0b11000000
	strh	r0, [r1]
	bl Delay


	B LED

Delay:
	ldr		r3, =X
L1:
	ldr		r4, =Y
L2:
	subs	r4, #1
	bne		L2
	subs	r3, #1
	bne		L1
	BX		LR
