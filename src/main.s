%include "src/defs.inc"


global _start
global lexer_current
global vec_tokens
global input_buffer
extern exit
extern input
extern add_token
extern print
extern lexer

section .bss
vec_tokens      resb    24
input_buffer    resb    256

section .data
lexer_current:  dq      0
input_string:   db      "> ", 0
tokens_string:  db      "Tokens:", 10, 0
token_string:   db      "%d. TYPE: %d, literal: %ld", 10, 0

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
	;mov     rsi, rcx
	;mov     rcx, rsi
	xor     rdx, rdx
	mov     dl, dil
	mov     rdi, token_string
	call    print

	pop     rcx

	inc     rcx
	jmp     .loop
.end:
	ret

_start:
	mov     rdi, input_string
	call    print

	mov     rdi, input_buffer
	mov     rsi, 256
	call    input

	call    lexer

	call    print_tokens

	
	mov     rdi, 0
	call    exit