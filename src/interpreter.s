%include "src/defs.inc"

global interpreter
extern exit

; input:
; r8 - first number
; r9 - second number
; r10 - binop type
;
; output:
; rax - result
calc:
	mov     rax, r8

	cmp     r10, BINOP_PLUS
	je      .add

	cmp     r10, BINOP_MINUS
	je      .subtract

	cmp     r10, BINOP_MULTIPLY
	je      .multiply

	cmp     r10, BINOP_DIVIDE
	je      .divide

	mov     rdi, 3
	call    exit
	ret

.add:
	add     rax, r9
	jmp     .end
.subtract:
	sub     rax, r9
	jmp     .end
.multiply:
	imul    rax, r9
	jmp     .end
.divide:
	cqo
	idiv    r9
	jmp     .end
.end:
	ret

; input:
; rdi - node
; output:
; rax - evaluated value
interpreter:
	cmp     byte [rdi], NODE_LITERAL
	je      .literal
	jmp     .binop

.literal:
	mov     rax, qword [rdi + 2]
	jmp     .end
.binop:
; evaluate left
	push    rdi
	mov     rdi, [rdi + 10]
	call    interpreter
	pop     rdi
	push    rax

; evaluate right
	push    rdi
	mov     rdi, [rdi + 18]
	call    interpreter
	pop     rdi
	push    rax

	pop     r9
	pop     r8
	movzx   r10, byte [rdi + 1]
	call    calc
.end:
	ret