global string_length
global print
global sprint
global input
extern printf
extern sprintf
extern fgets
extern stdin

section .data
you_entered     db      "You entered: %s", 10, 0

section .text
; input:
; rsi - pointer to the string
;
; output:
; rax - string length
string_length:
	xor     rax, rax
.loop:
	cmp     byte [rsi + rax], 0
	je      .end
	inc     rax
	jmp     .loop
.end:
	ret


; input:
; rdi - pointer to the string
; (optional) rsi, rdx, rcx, r8, r9
print:
	xor     eax, eax
	call    printf
	ret

; input:
; rdi - pointer to destination buffer
; rsi - pointer to format string
; (optional) rdx, rcx, r8, r9
sprint:
    xor     eax, eax
    call    sprintf
    ret

; input:
; rdi - pointer to the buffer
; rsi - buffer size
input:
	push    rdi

	mov     rdx, [rel stdin]
	call    fgets

	pop     rdi

    ; remove \n
	mov     rsi, rdi
	call    string_length
	cmp     [rsi + rax - 1], 10
	je      .remove
	jmp     .end
.remove:
	mov     [rsi + rax - 1], 0
.end:
	ret
