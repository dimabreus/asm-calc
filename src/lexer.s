%include "src/defs.inc"

global lexer
global add_token
extern vec_tokens
extern vec_add
extern lexer_current
extern input_buffer
extern malloc
extern print

section .data
unknown_char_text db      "Unknown char: %c", 10, 0

section .text
; input:
; dil - type
; rsi - literal
add_token:
	push    rdi
	push    rsi

	mov     rdi, 9
	call    malloc

	pop     rsi
	pop     rdi

	mov     [rax], dil
	mov     [rax + 1], rsi

	mov     rdi, vec_tokens
	mov     rsi, rax
	call    vec_add

	ret

%macro m_add 2
	mov     dil, %1
	mov     rsi, %2
	call    add_token
%endmacro

%macro m_cmp 3
	cmp     rax, %1
	jne     %%skip
    push rcx
	m_add   %2, %3
    pop rcx
    jmp .loop_end
%%skip:
%endmacro

lexer:
	xor     rcx, rcx

.loop:
	xor     rax, rax
	mov     al, [input_buffer + rcx]

	cmp     rax, 0
	je      .null_terminator

	cmp     rax, ' '
	je      .loop_end

	m_cmp   '+', TOKEN_PLUS, 0
	m_cmp   '-', TOKEN_MINUS, 0
	m_cmp   '*', TOKEN_STAR, 0
	m_cmp   '/', TOKEN_SLASH, 0
	m_cmp   '(', TOKEN_LEFT_BRACKET, 0
	m_cmp   ')', TOKEN_RIGHT_BRACKET, 0

	cmp     rax, '0'
	jl      .unknown_char

	cmp     rax, '9'
	jg      .unknown_char

    ; if we're here then rax >= '0' && rax <= '9'
	xor     rdx, rdx
.parse_digit:
	cmp     rax, '0'
	jl      .add_number

	cmp     rax, '9'
	jg      .add_number

	imul    rdx, 10
	sub     rax, 48
	add     rdx, rax

	inc     rcx
	xor     rax, rax
	mov     al, [input_buffer + rcx]

	jmp     .parse_digit
.add_number:
	push    rcx
	m_add   TOKEN_NUMBER, rdx
	pop     rcx
	jmp     .loop

.null_terminator:
	m_add   TOKEN_EOF, 0
	jmp     .end

.unknown_char:
	push    rcx
	mov     rdi, unknown_char_text
	mov     rsi, rax
	call    print
	pop     rcx
.loop_end:
	inc     rcx
	jmp     .loop

.end:
	ret