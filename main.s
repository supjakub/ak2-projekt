section .data
    msg db "Podaj liczbe:", 0xa
    msg_len equ $ - msg
    msg_prime db "Liczba jest pierwsza", 0xa
    msg_prime_len equ $ - msg_prime
    msg_not_prime db "Liczba nie jest pierwsza", 0xa
    msg_not_prime_len equ $ - msg_not_prime

section .bss
    ascii: rest 1

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
    mov rdx, 10
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
     loop:
     mov rax, rbx
     xor rdx, rdx
     div rcx
     cmp rdx, 0
     je not_prime
     inc rcx
     cmp rbx, rcx
     je prime
     jmp loop
     prime:
     mov rax, 1
     ret
     not_prime:
     mov rax, 0
     ret
