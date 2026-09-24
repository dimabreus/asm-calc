%include "src/defs.inc"

global format_token_type
global format_binop_type
global format_ast
extern sprint
extern malloc
extern exit

section .data
binop_plus_str  db      "+", 0
binop_minus_str db      "-", 0
binop_multiply_str db      "*", 0
binop_divide_str db      "/", 0
token_plus_str  db      "+", 0
token_minus_str db      "-", 0
token_star_str  db      "*", 0
token_slash_str db      "/", 0
token_left_bracket_str db      "(", 0
token_right_bracket_str db      ")", 0
token_number_str db      "NUMBER", 0
token_eof_str   db      "EOF", 0
literal_fmt     db      "%ld", 0
binop_fmt       db      "(%s %s %s)", 0

section .text

; input:
; rdi - token type
; output:
; rax - formatted string
format_token_type:
%macro m_token 2
	cmp     rdi, %1
	jne     %%skip
	mov     rax, %2
	ret
%%skip:
%endmacro

	m_token TOKEN_PLUS, token_plus_str
	m_token TOKEN_MINUS, token_minus_str
	m_token TOKEN_STAR, token_star_str
	m_token TOKEN_SLASH, token_slash_str
	m_token TOKEN_LEFT_BRACKET, token_left_bracket_str
	m_token TOKEN_RIGHT_BRACKET, token_right_bracket_str
	m_token TOKEN_NUMBER, token_number_str
	m_token TOKEN_EOF, token_eof_str

	mov     rdi, 3
	call    exit
	ret

; input:
; rdi - binop type
; output:
; rax - formatted string
format_binop_type:
%macro m_binop 2
	cmp     rdi, %1
	jne     %%skip
	mov     rax, %2
	ret
%%skip:
%endmacro

	m_binop BINOP_PLUS, binop_plus_str
	m_binop BINOP_MINUS, binop_minus_str
	m_binop BINOP_MULTIPLY, binop_multiply_str
	m_binop BINOP_DIVIDE, binop_divide_str

	mov     rdi, 3
	call    exit
	ret

; input:
; rdi - node
; output:
; rax - formatted string
format_ast:
	push    rdi
	mov     rdi, 256
	call    malloc
	pop     rdi

	cmp     byte [rdi], NODE_LITERAL
	je      .literal
	jmp     .binop

.literal:
	mov     rdx, qword [rdi + 2]

	push    rax
	mov     rdi, rax
	mov     rsi, literal_fmt
	call    sprint
	pop     rax
	jmp     .end
.binop:
	push    rax
	push    rax
; format binop type
	push    rdi
	mov     rdi, [rdi + 1]
	call    format_binop_type
	pop     rdi
	push    rax

; format left
	push    rdi
	mov     rdi, [rdi + 10]
	call    format_ast
	pop     rdi
	push    rax

; format right
	push    rdi
	mov     rdi, [rdi + 18]
	call    format_ast
	pop     rdi
	push    rax

	mov     rsi, binop_fmt
	pop     r8
	pop     rdx
	pop     rcx
	pop     rdi
	call    sprint
	pop     rax
.end:
	ret