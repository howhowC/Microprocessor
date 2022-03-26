.syntax unified
.cpu cortex-m4
.thumb

.data
user_stack: .zero 128
expr_result:.word 0

.text
.global main
postfix_expr: .asciz "-100 10 20 + - 10 +"

main:
LDR R0, =postfix_expr
B atoi
//TODO: Setup stack pointer to end of user_stack and calculate the expression using PUSH, POP operators, and store the result into expr_result

program_end:
B program_end

atoi:
//TODO: implement a “convert string to integer” function BX LR
mov     r1, #0          // r1 asciz index
mov     r4, #0          // r4 sum
ldrb    r2, [r0, r1]    // load char to r2
cmp     r2, #45         // cmp with -
beq     Negative
b       Positive

Negative:
mov     r3, #1          // r3 np flag  1 if neg
b       atoi1

Positive:
mov     r3, #0

sub     r3, r3, #48
add     r4, r4, r3

atoi1:
b program_end
