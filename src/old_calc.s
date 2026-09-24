section .bss
    num1_buffer resb 128
    sign_buffer resb 2
    num2_buffer resb 128
    output_buffer resb 128

section .data
    extern string_length

    enter_num1_string db "Enter first number: ", 0
    enter_sign_string db "Enter sign: ", 0
    enter_num2_string db "Enter second number: ", 0

    string1 db "Result: ", 0
    string2 db 10, 0


section .text
    global _start

_start:
.num1_input:
    mov rsi, enter_num1_string
    call print

    mov rsi, num1_buffer
    mov rdx, 128
    call read

    mov rsi, num1_buffer
    call parse_int

    mov r8, rax

.num2_input:
    mov rsi, enter_num2_string
    call print

    mov rsi, num2_buffer
    mov rdx, 128
    call read

    mov rsi, num2_buffer
    call parse_int

    mov r9, rax 

.sign_input:
    mov rsi, enter_sign_string
    call print

    mov rsi, sign_buffer
    mov rdx, 2
    call read

.calc:
    mov rsi, sign_buffer
    call calc


.print_output:
    mov rsi, output_buffer
    call number_to_string

    mov rsi, string1
    call print

    mov rsi, output_buffer
    call print

    mov rsi, string2
    call print
.exit:
    mov rax, 60         ; sys_exit
    xor rdi, rdi
    syscall

; input:
; r8 - first number
; r9 - second number
; rsi - sign string pointer
; 
; output:
; rax - result
calc:
    mov rax, r8

    cmp byte [rsi], 43 ; '+'
    je .add

    cmp byte [rsi], 45 ; '-'
    je .subtract

    cmp byte [rsi], 42 ; '*'
    je .multiply

    cmp byte [rsi], 47 ; '/'
    je .divide
    
    xor rax, rax
    ret

.add:
    add rax, r9
    jmp .end
.subtract:
    sub rax, r9
    jmp .end
.multiply:
    imul rax, r9
    jmp .end
.divide:
    xor rdx, rdx
    div r9
    jmp .end
.end:
    ret


; input
; rax - target number
; rsi - pointer to the output buffer 
number_to_string:
    mov rbx, 10 ; divider
    xor rcx, rcx
    xor rdx, rdx
.loop1:
    cmp rax, 0
    je .loop1_end

    div rbx ; divides rax by rbx (10), rax = quotient, rdx = remainder
    push rdx
    xor rdx, rdx

    inc rcx
    jmp .loop1

.loop1_end:
    mov rbx, rcx
    xor rcx, rcx
.loop2:
    cmp rcx, rbx
    je .loop2_end

    pop rax
    add rax, 48 ; 48 is '0'
    mov byte [rsi + rcx], al

    inc rcx
    jmp .loop2

.loop2_end:
    ret


; input:
; rsi - pointer to the string
; 
; output:
; rax - target number
parse_int:
    xor rax, rax
    xor rcx, rcx
.loop:
    cmp [rsi + rcx], 0
    je .end

    mov dl, byte [rsi + rcx]
    sub rdx, 48

    imul rax, 10
    add rax, rdx

    inc rcx
    jmp .loop
.end:
    ret


; input:
; rsi - pointer to the buffer
; rdx - max bytes
; 
; output:
; rbx - bytes read
read:
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, rsi        ; buffer
    mov rdx, rdx        ; max bytes
    syscall

    mov rbx, rax
    dec rbx

    mov byte [rsi + rbx], 0 ; remove '\n'

    ret

; input:
; rsi - pointer to the string
print:
    call string_length

    mov rdx, rax        ; string length
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, rsi
    syscall

    ret

