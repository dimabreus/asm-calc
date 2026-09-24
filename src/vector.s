section .text
    global vec_add
    extern realloc

; input:
; rdi - address of the vector
; rsi - value
vec_add:
	mov     rcx, qword [rdi]					; rcx = vector.data
	mov     rax, qword [rdi + 8]				; rax = vector.size
	cmp     rax, qword [rdi + 16]				; compare vector.size and vector.cap
	jae     .grow
	jmp     .set_value
.grow:
	cmp     qword [rdi + 16], 0
	je      .set_cap
	jmp     .double_cap
.set_cap:
	mov     qword [rdi + 16], 2
	jmp     .realloc
.double_cap:
	shl     qword [rdi + 16], 1
.realloc:
	push    rdi
	push    rsi
	push    rax

	mov     rsi, qword [rdi + 16]				; 2nd argument = vector.cap
	shl     rsi, 3								; 2nd argument *= 8
	mov     rdi, rcx							; 1st argument = vector.data
	call    realloc

	mov     rcx, rax							; rax = output of realloc

	pop     rax
	pop     rsi
	pop     rdi

	mov     qword [rdi], rcx
.set_value:
	mov     qword [rcx + 8 * rax], rsi
	inc     qword [rdi + 8]
	ret


