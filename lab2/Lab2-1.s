    .syntax unified
    .cpu cortex-m4
    .thumb

.data
    user_stack: .zero 128
    expr_result:.word 0

.text
    .global main
    postfix_expr: .asciz "-30 -85 -"

.align 4

main:
    LDR R0, =postfix_expr
	mov     r1, #0          // r1 asciz index
    mov		r8, #0			// r8 result
    B atoi

//TODO: Setup stack pointer to end of user_stack and calculate the expression using PUSH, POP operators, and store the result into expr_result
Store:
	push	{r4}
	b		atoi

runPop:
	pop		{r9, r10}
	add		r8, r9, r10
	add		r1, r1, #1
	push	{r8}
	b		atoi
runNop:
	pop		{r9, r10}
	sub		r8, r10, r9
	add		r1, r1, #1
	push	{r8}
	b		atoi

program_end:
    B program_end

atoi:
//TODO: implement a ��convert string to integer�� function BX LR
    mov		r6, #0			// r6 every number index
    mov     r4, #0          // r4 num from a char

Num_or_op:
    ldrb    r2, [r0, r1]    // load char to r2
    mov		r5, r2			// r5 char value
    cmp		r2, #0			// cmp exit with 0
    beq		program_end
    cmp		r2, #32			// cmp with space
    beq		Space

//OP
    cmp		r2, #43			// cmp with +
    beq		runPop
    cmp		r2, #45			// cmp with -
	beq		handle

//NUM
f2:
    cmp     r2, #45         // cmp with -
    beq     Negative
    cmp		r6, #0
    bne		Number
    b       Positive

Negative:
    mov     r3, #-1          // r3 np flag  1 if neg
    b       Indexpp

Positive:
    mov     r3, #1
    b       Number

Number:
    sub     r5, r5, #48
    add     r4, r4, r5
    mov		r7, #10
    mul		r4, r4, r7

Indexpp:
    add		r1, r1, #1
	add		r6, r6, #1

atoi1:
	b Num_or_op
    b program_end

Space:
	mov		r7, #10
	sdiv	r4, r4, r7
	mul		r4, r4, r3
	sub		r1, r1, #1
	ldrb    r7, [r0, r1]    // r7 r2 in front of space is num or op???
	add		r1, r1, #1
	add		r1, r1, #1		// index++
	cmp		r7, #43
	beq		atoi
	cmp		r7, #45
	beq		atoi
    cmp     r7, #32
    beq     atoi
	b Store

handle:
	add		r1, r1, #1
	ldrb    r7, [r0, r1]
	sub		r1, r1, #1
	cmp		r7, #32
	beq		runNop
	cmp		r7, #0
	beq		runNop
	b		f2
