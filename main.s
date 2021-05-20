section .data
    msg db "Podaj liczbe:", 0xa
    msg_len equ $ - msg
    msg_prime db "Liczba jest pierwsza", 0xa
    msg_prime_len equ $ - msg_prime
    msg_not_prime db "Liczba nie jest pierwsza", 0xa
    msg_not_prime_len equ $ - msg_not_prime

section .bss
    ascii: rest 2
    time: resq 1

section .text
global _start

_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, msg_len
    syscall

    mov rax, 0
    mov rdi, 1
    mov rsi, ascii
    mov rdx, 20
    syscall

    lea rsi, [ascii]
    mov rcx, 2
    call string_to_int
    call naive

    cmp rax, 1
    je print_prime
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_not_prime
    mov rdx, msg_not_prime_len
    syscall
    jmp exit
    print_prime:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_prime
    mov rdx, msg_prime_len
    syscall
    
    exit:
    mov rax, 0x3c
    mov rdi, 0
    syscall

string_to_int:
    xor rbx, rbx
    next_digit:
    movzx rax, byte [rsi]
    inc rsi
    cmp al, 10
    je end_loop
    sub al,'0'
    imul rbx, 10
    add rbx, rax
    jmp next_digit
    end_loop:
    mov rax, rbx
    ret

naive:
    mov rbx, rax
    mov rcx, 2
    xor rdx, rdx
    div rcx
    mov r8, rax
    loop:
    mov rax, rbx
    xor rdx, rdx
    div rcx
    cmp rdx, 0
    je not_prime
    inc rcx
    cmp rcx, r8
    jg prime
    jmp loop
    prime:
    mov rax, 1
    ret
    not_prime:
    mov rax, 0
    ret

rand:
    mov rax, r8
    mov r10, 1103515245
    mul r10
    add rax, 12345
    mov r8, rax
    mov r10, 65536
    xor rdx, rdx
    div r10
    xor rdx, rdx
    mov r10, 2048
    div r10
    mov r9, rdx
    mov r10, 1103515245
    mov rax, r8
    mul r10
    add rax, 12345
    mov r8, rax
    sal r9, 10
    mov r10, 65536
    xor rdx, rdx
    div r10
    xor rdx, rdx
    mov r10, 1024
    div r10
    xor r9, rdx
    mov r10, 1103515245
    mov rax, r8
    mul r10
    add rax, 12345
    mov r8, rax
    sal r9, 10
    mov r10, 65536
    xor rdx, rdx
    div r10
    xor rdx, rdx
    mov r10, 1024
    div r10
    xor r9, rdx
    xor rdx, rdx
    ret

fermat:
    mov r11, rax
    mov rax, 201
    mov rdi, time
    syscall
    mov r8, [time]
    xor cl, cl
    f_loop:
    call rand
    mov rax, r9
    div r11
    inc cl
    cmp cl, 5
    jl f_loop
    ret
