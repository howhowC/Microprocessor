    .syntax unified
    .cpu cortex-m4
    .thumb

	.data
	//TODO: put 0 to F 7-Seg LED pattern here
	student_id: .byte 0xF, 0xE, 0xD, 0xC, 0xB, 0xA, 0xF

	.text
	.global Lab4_2


	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOA_MODER, 0x48000000
	.equ GPIOA_OTYPER, 0x48000004
	.equ GPIOA_OSPEEDR, 0x48000008
	.equ GPIOA_PUPDR, 0x4800000C
	.equ GPIOA_ODR, 0x48000014
	.equ GPIOA_BSRR,0x48000018
	.equ GPIOA_BRR,0x48000028

// max7219_init
	.equ DECODE_MODE,	0x09
	.equ INTENSITY, 	0x0A // 亮度
	.equ SCAN_LIMIT,	0x0B // 顯示位數
	.equ SHUTDOWN,		0x0C
	.equ DISPLAY_TEST,	0x0F

	.equ BSRR,	0x18
	.equ BRR,	0x28
	.equ DATA,	0x20	// PA5
	.equ LOAD,	0x40	// PA6
	.equ CLOCK,	0x80	// PA7

	.equ X, 900
	.equ Y, 900

Lab4_2:
	push {LR}

	BL GPIO_init
	BL max7219_init

	ldr r9, =student_id
	ldr r10, =#0

DisplayID:
	//TODO: Display 0 to F at first digit on 7-SEG LED. Display one
	//per second.
	ldr r9,=student_id
	mov r0, #0x7
	ldrb r1, [r9, r10]
	BL MAX7219Send
	add r10, r10, #1

	ldr r9,=student_id
	mov r0, #0x6
	ldrb r1, [r9, r10]
	BL MAX7219Send
	add r10, r10, #1

	ldr r9,=student_id
	mov r0, #0x5
	ldrb r1, [r9, r10]
	BL MAX7219Send
	add r10, r10, #1

	ldr r9,=student_id
	mov r0, #0x4
	ldrb r1, [r9, r10]
	BL MAX7219Send
	add r10, r10, #1

	ldr r9,=student_id
	mov r0, #0x3
	ldrb r1, [r9, r10]
	BL MAX7219Send
	add r10, r10, #1

	ldr r9,=student_id
	mov r0, #0x2
	ldrb r1, [r9, r10]
	BL MAX7219Send
	add r10, r10, #1

	ldr r9,=student_id
	mov r0, #0x1
	ldrb r1, [r9, r10]
	BL MAX7219Send
	b L
L:
	B L

max7219_init:
	push {LR}

	ldr r0, =#DECODE_MODE
	ldr r1, =#0xFF
	BL MAX7219Send
	ldr r0, =#DISPLAY_TEST
	ldr r1, =#0x0
	BL MAX7219Send
	ldr r0, =#SCAN_LIMIT
	ldr r1, =0x6
	BL MAX7219Send
	ldr r0, =#INTENSITY
	ldr r1, =#0xA
	BL MAX7219Send
	ldr r0, =#SHUTDOWN
	ldr r1, =#0x1
	BL MAX7219Send

	POP	{LR}
	BX LR

MAX7219Send:
	push {LR}
	// input parameter: r0 is ADDRESS , r1 is DATA
	// TODO: Use this function to send a message to max7219
	lsl r0, r0, #8
	add r0, r0, r1
	ldr r1, =#GPIOA_MODER
	ldr r2, =#LOAD
	ldr r3, =#DATA
	ldr r4, =#CLOCK
	ldr r5, =#BSRR
	ldr r6, =#BRR
	mov r7, #16 //r7 = i
max7219send_loop:
	mov r8, #1
	sub r9, r7, #1
	lsl r8, r8, r9 	// r8 = mask
	str r4, [r1,r6]	// HAL_GPIO_WritePin(GPIOA, CLOCK, 0);
	tst r0, r8
	beq bit_not_set	// bit not set
	str r3, [r1,r5]
	b if_done
bit_not_set:
	str r3, [r1,r6]
if_done:
	str r4, [r1,r5]
	subs r7, r7, #1
	bgt max7219send_loop
	str r2, [r1,r6]
	str r2, [r1,r5]

	POP	{LR}
	BX LR

GPIO_init:
	push {LR}

	// Enable AHB2 clock
	movs	r0, #0x1
	ldr		r1, =RCC_AHB2ENR
	str		r0, [r1]

	// Set PA567 as output mode
	movs	r0, #0b0101010000000000
	ldr		r1, =GPIOA_MODER
	ldr		r2, [r1]
	and		r2, #0xFFFF03FF // Mask MODER_567
	orrs	r2, r2, r0
	str		r2, [r1]

	// Default PA5 is Pull-up output, no need to set

	// Set PA_567 as high speed mode
	movs	r0, #0xA800
	ldr		r1 ,=GPIOA_OSPEEDR
	strh	r0, [r1]

	ldr		r1, =GPIOA_ODR

	POP	{LR}
	BX LR
