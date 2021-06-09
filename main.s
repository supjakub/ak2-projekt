section .data
    msg_input db "Podaj liczbe:", 0xa
    msg_prime db "Liczba jest pierwsza", 0xa
    msg_not_prime db "Liczba nie jest pierwsza", 0xa

section .bss
    ascii: resb 21

section .text
global _start

_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_input
    mov rdx, 14
    syscall

    mov rax, 0
    mov rdi, 1
    mov rsi, ascii
    mov rdx, 21
    syscall

    lea rsi, [ascii]
    mov rcx, 2
    call string_to_int
    call fermat

    cmp rax, 1
    je print_prime
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_not_prime
    mov rdx, 24
    syscall
    jmp exit
    print_prime:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_prime
    mov rdx, 21
    syscall
    
    exit:
    mov rax, 0x3c
    mov rdi, 0
    syscall

string_to_int:
    xor rbx, rbx
    next_digit:
    cmp byte [rsi], 10
    je end_loop
    movzx rax, byte [rsi]
    inc rsi
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

random: ;w r9 wylosowana liczba
    mov rax, r9
    xor rdx, rdx
    mov r10, 2862933555777941757
    mul r10
    mov r10, 3037000493
    add rax, r10
    jnc no_carry
    inc rdx
    no_carry:
    mov r10, 0xffffffffffffffff
    div r10
    mov r9, rdx
    ret

;a-r10, b-r11, n-r12, m-r13b
mod_power:
    ;Liczenie m
    mov r13b, 64
    mov rax, 1
    shl rax, 63
    check_if_set:
    push rax
    and rax, r11
    cmp rax, 0
    jne counted_m
    pop rax
    shr rax, 1
    dec r13b
    jmp check_if_set

    counted_m:
    pop rax
    mov rax, r10
    mov rdx, 0
    div r12
    mov r10, rdx
    mov r14, 1 ;result
    mov r15, r10 ;x

    mov rbx, 1 ;maska
    next_bit:
    push rbx
    and rbx, r11
    cmp rbx, 0
    je do_shift
    pop rbx
    shl rbx, 1
    mov rax, r14
    mul r15
    div r12
    mov r14, rdx
    no_set:
    mov rax, r15
    mul r15
    div r12
    mov r15, rdx
    dec r13b
    cmp r13b, 0
    jne next_bit
    mov rax, r14
    ret

    do_shift:
    pop rbx
    shl rbx, 1
    jmp no_set

fermat:
    mov r8, rax
    mov rax, 0xc9
    xor rdi, rdi
    syscall
    mov r9, rax

    mov rcx, 0
    next_rand_f:
    call random

    xor rdx, rdx
    mov r10, r8
    sub r10, 2
    div r10
    add rdx, 2
    mov r10, rdx

    mov r11, r8
    dec r11
    mov r12, r8
    call mod_power
    cmp rax, 1
    jne no_prime_f
    inc rcx
    cmp rcx, 5
    jng next_rand_f
    mov rax, 1
    ret
    no_prime_f:
    mov rax, 0
    ret
