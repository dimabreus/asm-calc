%include "src/defs.inc"

global parser
global is_at_end

extern vec_tokens
extern print
extern exit
extern calloc
extern format_token_type

section .data
incorrect_type_string db      "Expected: %s, got %s", 10, 0
expected_eof_string db      "Expected: EOF, got: %s", 10, 0

section .text
; input:
; rcx - current index
; output:
; rax - token
peek:
	mov     rax, qword [rel vec_tokens]
	mov     rax, qword [rax + 8 * rcx]
	ret

; input:
; rcx - current index
; output:
; rax - 1 if true, 0 otherwise
is_at_end:
	call    peek
	cmp     byte [rax], TOKEN_EOF
	setz    al
	movzx   rax, al
	ret

; input:
; rcx - current index
; output:
; rax - token
previous:
	mov     rax, qword [rel vec_tokens]
	mov     rax, qword [rax + 8 * rcx - 8]
	ret

; input:
; rdi - target type
; rcx - current index
; output:
; rax - 1 if the type matches, 0 otherwise
check:
	call    is_at_end
	cmp     rax, 1
	je      .false

	call    peek
	cmp     byte [rax], dil
	setz    al
	movzx   rax, al
	ret
.false:
	xor     rax, rax
	ret

; input:
; rcx - current index
; output:
; rax - token
advance:
	inc     rcx
	call    previous
	ret

; input:
; rdi - target type
; rcx - current index
; output:
; rax - consumed token
consume:
	call    check
	cmp     rax, 1
	je      .success

	call    format_token_type
	mov     rsi, rax

	call    peek
	movzx   rdi, byte [rax]
	call    format_token_type
	mov     rdx, rax

	mov     rdi, incorrect_type_string
	call    print

	mov     rdi, 1
	call    exit
.success:
	call    advance
	ret

; input
; rdi - target type
; rcx - current index
; output:
; rax - 1 if matches, 0 otherwise
match:
	call    check

	cmp     rax, 0
	je      .end

	inc     rcx									; alternative to advance so it doesn't change rax

.end:
	ret

; output:
; rax - address of the node
create_node:
	push    rcx
	mov     rdi, 1
	mov     rsi, 26
	call    calloc
	pop     rcx
	ret

; input
; rcx - current index
; output:
; rax - node
factor:
	mov     rdi, TOKEN_LEFT_BRACKET
	call    match

	cmp     rax, 1
	je      .expr

	mov     rdi, TOKEN_NUMBER
	call    consume
	push    qword [rax + 1]

	call    create_node							; rax = node
	pop     rdi

	mov     byte [rax], NODE_LITERAL
	mov     qword [rax + 2], rdi

	ret

.expr:
	call    expression
	push    rax
	mov     rdi, TOKEN_RIGHT_BRACKET
	call    consume
	pop     rax
	ret

; input
; rcx - current index
; output:
; rax - node
term:
	call    factor
	push    rax
.loop:
	mov     rdi, TOKEN_STAR
	call    match
	cmp     rax, 1
	je      .do

	mov     rdi, TOKEN_SLASH
	call    match
	cmp     rax, 1
	je      .do

	jmp     .loop_end

.do:
	call    previous
	movzx   rax, byte [rax]
	push    rax									; rax = type

	call    factor
	push    rax									; rax = right

	call    create_node							; rax = node
	mov     byte [rax], NODE_BINOP

	pop     rdi
	mov     qword [rax + 18], rdi

	pop     rdi
	mov     byte [rax + 1], dil

	pop     rdi
	mov     qword [rax + 10], rdi

	push    rax

	jmp     .loop

.loop_end:
	pop     rax
	ret


; input
; rcx - current index
; output:
; rax - node
expression:
	call    term
	push    rax
.loop:
	mov     rdi, TOKEN_PLUS
	call    match
	cmp     rax, 1
	je      .do

	mov     rdi, TOKEN_MINUS
	call    match
	cmp     rax, 1
	je      .do

	jmp     .loop_end

.do:
	call    previous
	movzx   rax, byte [rax]
	push    rax									; rax = type

	call    term
	push    rax									; rax = right

	call    create_node							; rax = node
	mov     byte [rax], NODE_BINOP

	pop     rdi
	mov     qword [rax + 18], rdi

	pop     rdi
	mov     byte [rax + 1], dil

	pop     rdi
	mov     qword [rax + 10], rdi

	push    rax

	jmp     .loop

.loop_end:
	pop     rax
	ret

parser:
	call    expression
	push    rax

	call    is_at_end
	cmp     rax, 1
	je      .end

	call    peek
	movzx   rdi, byte [rax]
	call    format_token_type
	mov     rsi, rax

	mov     rdi, expected_eof_string
	call    print

.end:
	pop     rax
	ret