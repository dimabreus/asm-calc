global _start
global lexer_current
extern exit
extern input

section .bss
vec_tokens      resb    24
input_buffer    resb    256

section .data
lexer_current:  dq      0

section .text
_start:
	mov     rdi, input_buffer
	mov     rsi, 256
	call    input

	mov     rdi, 0
	call    exit