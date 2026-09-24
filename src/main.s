%include "src/defs.inc"

global _start
global vec_tokens
global input_buffer
extern exit
extern input
extern print
extern lexer
extern parser
extern interpreter
extern format_ast
extern vec_clear

section .bss
vec_tokens      resb    24
input_buffer    resb    256

section .data
input_string    db      "> ", 0
tokens_string   db      "Tokens:", 10, 0
token_string    db      "%d. TYPE: %d, literal: %ld", 10, 0
ast_string      db      "AST: %s", 10, 0
result_string   db      "%ld", 10, 0

section .text
print_tokens:
	mov     rdi, tokens_string
	call    print
	xor     rcx, rcx
.loop:
	cmp     rcx, [rel vec_tokens + 8]
	jge     .end

	mov     rax, [rel vec_tokens]
	mov     rbx, [rax + rcx * 8]

	mov     dil, [rbx]
	mov     rsi, [rbx + 1]

	push    rcx

	push    rsi
	push    rcx
	pop     rsi
	pop     rcx
	movzx   rdx, dil
	mov     rdi, token_string
	call    print

	pop     rcx

	inc     rcx
	jmp     .loop
.end:
	ret

input_expr:
	mov     rdi, input_string
	call    print

	mov     rdi, input_buffer
	mov     rsi, 256
	call    input

	ret

reset:
	mov     rdi, vec_tokens
	call    vec_clear
	ret

_start:
.loop:
	call reset

	call    input_expr

	cmp     [rel input_buffer], 'q'
	jne     .do

	cmp     [rel input_buffer + 1], 0
	jne     .do

	jmp     .end

.do:
	call    lexer

	; call    print_tokens

	mov     rcx, 0
	call    parser

	; push    rax

	; mov     rdi, rax
	; call    format_ast

	; mov     rdi, ast_string
	; mov     rsi, rax
	; call    print

	; pop     rax

	mov     rdi, rax
	call    interpreter

	mov     rdi, result_string
	mov     rsi, rax
	call    print

	jmp     .loop
.end:
	mov     rdi, 0
	call    exit