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

	.equ GPIOC_MODER, 0x48000800
	.equ GPIOC_OTYPER, 0x48000804
	.equ GPIOC_OSPEEDR, 0x48000808
	.equ GPIOC_PUPDR, 0x4800080C
	.equ GPIOC_IDR, 0x48000810

	.equ X, 100
	.equ Y, 100


// LED on PA5
main:
	// Enable AHB2 clock
	movs	r0, #0x5
	ldr		r1, =RCC_AHB2ENR
	str		r0, [r1]

	// Set PA4567 as output mode
	movs	r0, #0x5500
	ldr		r1, =GPIOA_MODER
	ldr		r2, [r1]
	and		r2, #0xFFFF00FF // Mask MODER45
	orrs	r2, r2, r0
	str		r2, [r1]

	// Default PA5 is Pull-up output, no need to set

	// Set PC13 as input mode
	ldr		r1, =GPIOC_MODER
	ldr		r0, [r1]
	ldr		r2, =#0xF3FFFFFF
	and		r0, r2
	str		r0, [r1]

	// Set PA5 as high speed mode
	movs	r0, #0x0
	ldr		r1 ,=GPIOA_OSPEEDR
	strh	r0, [r1]

	ldr		r1, =GPIOA_ODR
	// Set data register address
	ldr		r2, =GPIOC_IDR
	mov		r4, #1

LED:
t0:
	movs	r0, #0b11100000
	strh	r0, [r1]
	bl Detect_B
	cmp		r4, #0
	beq	t0
	bl Delay_1s
t1:
	movs	r0, #0b11000000
	strh	r0, [r1]
	bl Detect_B
	cmp		r4, #0
	beq	t1
	bl Delay_1s
t2:
	movs	r0, #0b10010000
	strh	r0, [r1]
	bl Detect_B
	cmp		r4, #0
	beq	t2
	bl Delay_1s
t3:
	movs	r0, #0b00110000
	strh	r0, [r1]
	bl Detect_B
	cmp		r4, #0
	beq	t3
	bl Delay_1s
t4:
	movs	r0, #0b01110000
	strh	r0, [r1]
	bl Detect_B
	cmp		r4, #0
	beq	t4
	bl Delay_1s
t5:
	movs	r0, #0b00110000
	strh	r0, [r1]
	bl Detect_B
	cmp		r4, #0
	beq	t5
	bl Delay_1s
t6:
	movs	r0, #0b10010000
	strh	r0, [r1]
	bl Detect_B
	cmp		r4, #0
	beq	t6
	bl Delay_1s
t7:
	movs	r0, #0b11000000
	strh	r0, [r1]
	bl Detect_B
	cmp		r4, #0
	beq	t7
	bl Delay_1s

	B LED

Delay_1s:
	ldr		r5, =X
L1:
	ldr		r6, =Y
L2:
	subs	r6, #1
	bne		L2
	subs	r5, #1
	bne		L1
	BX		LR

Detect_B:
	mov		r8, #0
	mov		r7, #(1<<13)
	mov		r5, #600
L3:
	mov		r6, #600
L4:
	ldr		r3, [r2]
	cmp		r3, #0
	beq		Count
f1:
	ands	r7, r3
	subs	r6, #1
	bne		L4
	subs	r5, #1
	bne		L3

	cmp		r8, #200
	bgt	Change
go:
	BX		LR
Count: //debounce
	add		r8, #1
	B f1
Change:
	eor		r4, r4, #1
	B go

