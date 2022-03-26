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

	.equ GPIOB_MODER, 0x48000400
	.equ GPIOB_OTYPER, 0x48000404
	.equ GPIOB_OSPEEDR, 0x48000408
	.equ GPIOB_PUPDR, 0x4800040C
	.equ GPIOB_IDR, 0x48000410

	.equ GPIOC_MODER, 0x48000800
	.equ GPIOC_OTYPER, 0x48000804
	.equ GPIOC_OSPEEDR, 0x48000808
	.equ GPIOC_PUPDR, 0x4800080C
	.equ GPIOC_IDR, 0x48000810

	.equ X, 500
	.equ Y, 500
	.equ PWD, 0b1111


// LED on PA5
main:
	// Enable AHB2 clock
	movs	r0, #0x7
	ldr		r1, =RCC_AHB2ENR
	str		r0, [r1]

	// Set PA4567 as output mode
	movs	r0, #0x5500
	ldr		r1, =GPIOA_MODER
	ldr		r2, [r1]
	and		r2, #0xFFFF00FF // Mask MODER4567
	orrs	r2, r2, r0
	str		r2, [r1]

	// Default PA5 is Pull-up output, no need to set

	ldr		r3, =GPIOB_MODER
	ldr		r0, [r3]
	ldr		r2, =0xFFFFF00F // Mask MODER2345
	and		r0, r2
	str		r0, [r3]

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

	movs	r0, #0b11110000 // initial
	strh	r0, [r1]

	// Set data register address
	ldr		r8,	=GPIOB_IDR
	ldr		r2, =GPIOC_IDR
	mov		r4, #0			// T or F

	ldr		r10, =PWD
	eor		r10, 0b1111
	lsl		r10, #2
	mov		r11, #0
// Loop
Loop:
	ldr		r9, [r8]
	cmp		r9, r10
	beq F
	mov		r4, #0
continue:
	bl Detect_B
	cmp		r11, #0
	beq	again
	cmp		r4, #0
	beq	Blink_once
	bl LED_Blink
	bl LED_Blink
Blink_once:
	bl LED_Blink
	mov		r11, #0
again:
	B Loop
F:
	mov		r4, #1
	B continue


LED_Blink:
t0:
	movs	r0, #0b00000000
	strh	r0, [r1]
	push	{LR}
	bl Delay_1s
	POP		{LR}

t1:
	movs	r0, #0b11110000
	strh	r0, [r1]
	push	{LR}
	bl Delay_1s
	POP		{LR}

	BX		LR

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
	mov		r7, #(1<<13)
	mov		r12, #0
	mov		r5, #600
L3:
	mov		r6, #600
L4:
	ldr		r3, [r2]

	cmp		r3, #0
	beq Count
f1:
	ands	r7, r3
f2:
	subs	r6, #1
	bne		L4
	subs	r5, #1
	bne		L3

	cmp		r12, #50
	bgt		debounce
f3:
	BX		LR

Count:
	add		r12, #1
	B f1

debounce:
	mov		r11, #1
	b f3

