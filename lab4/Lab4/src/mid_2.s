	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	data: .byte 0x1F, 0x15 // b, n

.text
.global mid_2
	.equ RCC_AHB2ENR, 	0x4002104C
	.equ GPIOA_MODER, 	0x48000000
	.equ GPIOA_OTYPER, 	0x48000004
	.equ GPIOA_OSPEEDR, 0x48000008
	.equ GPIOA_PUPDR, 	0x4800000C
	.equ GPIOA_ODR, 	0x48000014
	.equ GPIOA_BSRR,	0x48000018
	.equ GPIOA_BRR,		0x48000028

	.equ GPIOC_MODER, 	0x48000800 //port C
	.equ GPIOC_IDR, 	0x48000810
	.equ GPIOC_PUPDR, 	0x4800080C


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

	// r9 r10 r11 globle variable
mid_2:
	BL GPIO_init
	BL max7219_init
	mov		r11, #0		// r11 count of data
	ldr 	r0, =#DECODE_MODE
	ldr 	r1, =#0xFF
	BL MAX7219Send		// decode mode
	ldr 	r0, =#1
	ldr 	r1, =#0xF
	BL MAX7219Send		// send blank
	ldr 	r0, =#2
	ldr 	r1, =#0xF
	BL MAX7219Send		// send blank
loop:
	B Button_detect

GPIO_init:
	//TODO: Initialize three GPIO pins as output for max7219 DIN, CS
	//and CLK
	movs r1,#0x5
	ldr r2, =RCC_AHB2ENR
	str r1,[r2]

	movs 	r0,	#0x5400  //PA5~7
	ldr 	r2, =GPIOA_MODER
	ldr 	r1, [r2]
	ands 	r1, r1, #0xFFFF03FF
	orrs 	r1, r1, r0
	str  	r1, [r2]

	movs 	r0, #0xA800
	ldr  	r1, =GPIOA_OSPEEDR
	strh 	r0, [r1]

	ldr 	r9,	=GPIOC_MODER
	ldr 	r0,	[r9]
	ldr 	r2,	=#0xF3FFFFFF
	and 	r0,	r2
	str 	r0,	[r9]
	ldr 	r0, [r9]
	ldr 	r9,	=GPIOC_PUPDR
	ldr 	r2, [r9]
	ldr  	r5, =#0x4000000
	orrs 	r2, r5
	str  	r2, [r9]
	ldr 	r2,	=GPIOC_IDR
	movs 	r7, #0x2000
	str  	r7, [r2]

	//ldr r11,=GPIOA_ODR

	BX LR

max7219_init:
	//TODO: Initialize max7219 registers
	push {lr}
	ldr r0, =#DECODE_MODE
	ldr r1, =#0xFF
	BL MAX7219Send
	ldr r0, =#DISPLAY_TEST
	ldr r1, =#0x0
	BL MAX7219Send
	ldr r0, =#SCAN_LIMIT
	ldr r1, =0x1
	BL MAX7219Send
	ldr r0, =#INTENSITY
	ldr r1, =#0xA
	BL MAX7219Send
	ldr r0, =#SHUTDOWN
	ldr r1, =#0x1
	BL MAX7219Send
	pop {pc}

MAX7219Send:
	//input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	lsl r0, r0, #8
	add r0, r0, r1
	ldr r2, =#LOAD
	ldr r3, =#DATA
	ldr r4, =#CLOCK
	//ldr r5, =#BSRR
	//ldr r6, =#BRR
	mov r7, #16//r7 = i
max7219send_loop:
	mov r8, #1
	sub r5, r7, #1
	lsl r8, r8, r5 // r8 = mask
	ldr r5, =GPIOA_BRR
	str r4, [r5]//HAL_GPIO_WritePin(GPIOA, CLOCK, 0);
	tst r0, r8
	beq bit_not_set//bit not set
	ldr r5, =GPIOA_BSRR
	str r3, [r5]
	b if_done
bit_not_set:
	ldr r5,=GPIOA_BRR
	str r3, [r5]
if_done:
	ldr r5,=GPIOA_BSRR
	str r4, [r5]
	subs r7, r7, #1
	bgt max7219send_loop
	ldr r5,=GPIOA_BRR
	str r2, [r5]
	ldr r5,=GPIOA_BSRR
	str r2, [r5]
	BX LR

button_delay:

	movs R7, #350
L3:
	movs R8,	#400
L4:
	SUBS R8,	#1

	BNE L4
	SUBS R7,	#1
	BNE L3
	BX LR

Button_detect:
	ldr 	r2,	=GPIOC_IDR
	ldr 	r3,	[r2]		// r3 == 8192 no press ; 0 press
	movs 	r4,	#1
	movs 	r5, #0
	lsl 	r4,	#13
	ands 	r3, r3, r4
	beq 	debounce		// r3 == 8192 no press ; 0 press
	b		Button_detect
debounce:
	ldr 	r4, [r2]
	cmp 	r4, r3
	beq double_check
	b Button_detect
double_check:

	bl button_delay		// wait
	ldr 	r3,[r2]		// state2(r3) == state1(r4)
	cmp 	r3,r4		// check if state2(r3) == state1(r4)
	beq still_pressed	// if r3 == 0 == r4 == 0 ==> the button is still pressed
	cmp 	r5, #2
	blt short_press		// r5 < 2 ==> short_press
	bge long_press		// r5 >= 2 ==> long_press
	b Button_detect
still_pressed:
	adds 	r5, #1
	b double_check
short_press:
	mov 	r10, #1		// r10 == 1 ==> n
	B Display
long_press:
	mov 	r10, #0		// r10 == 0 ==> b
	B Display

Display:
	//TODO: Display 0 to F at first digit on 7-SEG LED. Display one
	//per second.
	adds	r11, #1		// count++

	ldr 	r0, =#DECODE_MODE
	ldr 	r1, =#0x0
	BL MAX7219Send		// no decode mode

	cmp		r11, #1
	beq one_bits
	cmp		r11, #2
	bge two_bits
two_bits:				// r10 now, r8 previous
	mov 	r0, #0x1	// digit 0
	ldr		r9, =data
	ldrb 	r1, [r9, r10]
	BL MAX7219Send
	pop		{r8}		// pop previous bit to r8 to shift
	push	{r10}		// record now bit
	mov 	r0, #0x2	// digit 1
	ldr		r9, =data
	ldrb 	r1, [r9, r8]
	BL MAX7219Send		// shift from d0 to d1
	b Button_detect

one_bits:
	push	{r10}		// record now bit
	mov 	r0, #0x1	// digit 0
	ldr		r9, =data
	ldrb 	r1, [r9, r10]
	BL MAX7219Send
	mov 	r0, #0x2
	mov		r1, #0
	BL MAX7219Send		// digit 1 blank
	b Button_detect
