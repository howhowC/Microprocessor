	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	num: .byte 0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8, 0x9

.text
.global Lab4_3
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

Lab4_3:
	BL GPIO_init
	BL max7219_init
	ldr 	r11, =#0
	movs 	r12, #0
	movs 	r6, #0
	movs 	r10, #1
	movs 	R7, #0 //a
 	movs 	R8, #1 //b
 	push 	{r7, r8}
 	ldr 	r9, =num
	movs 	r0, #0x1
	ldrb 	r1, [r9, r11]
	BL MAX7219Send
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
DisplayID:
	//TODO: Display 0 to F at first digit on 7-SEG LED. Display one
	//per second.
	//push {lr}
	//cmp r12,#0x5F5E100
	cmp 	r6, #8
	beq over
	ldr 	r9, =num
	movs 	r0, #0x1
	adds 	r0, r0, r6
	cmp 	r12, #10
	bge  S
	bl   table
	ldrb 	r1, [r9,r11]
	BL MAX7219Send
	//b Button_detect
	movs 	r6, #0
	b Button_detect
S:
	movs 	r3,#10
	//push {r4}
	udiv 	r1, r12, r3	// 抓
	mul  	r5, r1, r3	// 餘
	sub  	r12, r12, r5 // 數
	bl   table			// r11 第幾位
	movs 	r12,r1

	ldrb r1,[r9,r11]
	BL MAX7219Send

	adds r6,#1
	ldr r0, =#SCAN_LIMIT
	ldr r1, =0x0
	adds r1,r1,r6
	BL MAX7219Send
	b DisplayID
table:
	cmp r12,#1
	beq I1
	cmp r12,#2
	beq I2
	cmp r12,#3
	beq I3
	cmp r12,#4
	beq I4
	cmp r12,#5
	beq I5
	cmp r12,#6
	beq I6
	cmp r12,#7
	beq I7
	cmp r12,#8
	beq I8
	cmp r12,#9
	beq I9
	cmp r12,#0
	beq I0
I0:
	movs r11,#0
	bx lr
I1:
	movs r11,#1
	bx lr
I2:
	movs r11,#2
	bx lr
I3:
	movs r11,#3
	bx lr
I4:
	movs r11,#4
	bx lr
I5:
	movs r11,#5
	bx lr
I6:
	movs r11,#6
	bx lr
I7:
	movs r11,#7
	bx lr
I8:
	movs r11,#8
	bx lr
I9:
	movs r11,#9
	bx lr
over:
	ldr r0, =#SCAN_LIMIT
	ldr r1, =0x1
	BL MAX7219Send
	ldr r9,=num
	movs r0,#0x1
	movs r11,#1
	ldrb r1,[r9,r11]
	BL MAX7219Send
	ldr r9,=num
	movs r0,#0x2
	movs r11,#10
	ldrb r1,[r9,r11]
	BL MAX7219Send
	b Button_detect
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
	ldr r5,=GPIOA_BRR
	str r4, [r5]//HAL_GPIO_WritePin(GPIOA, CLOCK, 0);
	tst r0, r8
	beq bit_not_set//bit not set
	ldr r5,=GPIOA_BSRR
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
	ldr r1, =0x0
	BL MAX7219Send
	ldr r0, =#INTENSITY
	ldr r1, =#0xA
	BL MAX7219Send
	ldr r0, =#SHUTDOWN
	ldr r1, =#0x1
	BL MAX7219Send
	pop {pc}


fib:
	pop {r7,r8}
	movs R5,R8
	adds R8,R8,R7
	movs R7,R5
	//adds R9,#1
	///b  L1
	//cmp  R9,R10
	//ble  fib
 	movs R12,R8
 	push {r7,r8}
 	b	DisplayID
 	//b Button_detect

button_delay:

	movs R7, #350
	L3: movs R8,	#400

	L4: SUBS R8,	#1

	BNE L4
	SUBS R7,	#1
	BNE L3
	BX LR

Button_detect:
		ldr r2,	=GPIOC_IDR
		ldr r3,	[r2]
		movs r4,	#1
		movs r5,#0
		lsl r4,	#13
		ands r3,r3,	r4
		beq do_pushed
		b	Button_detect
do_pushed:

	ldr r4,[r2]
	cmp r4,r3
	beq double_check
	b Button_detect
double_check:

	bl button_delay
	ldr r3,[r2]	//state2 == state1
	cmp r3,r4
	beq A
	cmp r5,#2
	blt fib
	//cmp r5,#1000
	bge RE
	b Button_detect
A:
	adds r5,#1
	b double_check
RE:
	movs r10,#0
	ldr r11,=#0
	movs r12,#0
	movs r6,#0
	movs r10,#1
	movs R7, #0 //a
 	movs R8, #1 //b
 	push {r7,r8}
 	ldr r0, =#SCAN_LIMIT
	ldr r1, =0x0
	BL MAX7219Send
	ldr r9,=num
	movs r0,#0x1
	ldrb r1,[r9,r11]
	BL MAX7219Send
 	b Button_detect
