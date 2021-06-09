section .data
    msg_input db "Podaj liczbe:", 0xa
    msg_choice db "Wybierz opcje: 1-algorytm naiwny, 2-algorytm Fermata, 3-algorytm Millera-Rabina", 0xa
    msg_prime db "Liczba jest pierwsza", 0xa
    msg_not_prime db "Liczba nie jest pierwsza", 0xa

section .bss
    ascii: resb 21
    choice: resb 1

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
    push rax

    mov rax, 1
    mov rdi, 1
    mov rsi, msg_choice
    mov rdx, 80
    syscall

    mov rax, 0
    mov rdi, 1
    mov rsi, choice
    mov rdx, 1
    syscall
    pop rax

    cmp byte [choice], 49
    je choose_naive
    cmp byte [choice], 50
    je choose_fermat
    cmp byte [choice], 51
    je choose_miller_rabin

    choose_naive:
    call naive
    jmp end
    choose_fermat:
    call fermat
    jmp end
    choose_miller_rabin:
    call miller_rabin
    jmp end

    end:
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
    cmp rax, 0
    je not_prime
    cmp rax, 1
    je not_prime
    cmp rax, 2
    je prime
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
    cmp rax, 0
    je no_prime_f
    cmp rax, 1
    je no_prime_f
    cmp rax, 2
    jne no_two
    mov rax, 1
    ret
    no_two:
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

miller_rabin:
    cmp rax, 0
    je no_prime_mr
    cmp rax, 1
    je no_prime_mr
    mov r8, rax
    cmp r8, 2
    je prime_mr
    mov rdx, 0
    mov rbx, 2
    div rbx
    cmp rdx, 0
    je no_prime_mr

    mov rax, 0xc9
    mov rdi, 0
    syscall
    mov r9, rax

    mov r10, 1
    shl r10, 63
    next_shift:
    mov rax, r8
    dec rax
    mov rdx, 0
    div r10
    cmp rdx, 0
    je found_s
    shr r10, 1
    jmp next_shift

    found_s:
    mov rax, r8
    mov rdx, 0
    div r10
    mov r13, rax ;d
    mov r15, r10 ;2^s
    shr r15, 1 ;2^s-1
    mov r14, r8
    dec r14 ;n-1

    mov cl, 0
    next_rand_mr:
    inc cl
    cmp cl, 2
    jg prime_mr
    call random

    xor rdx, rdx
    mov r10, r8
    sub r10, 2
    div r10
    add rdx, 2
    mov r10, rdx

    mov r11, r13
    mov r12, r8
    push r13
    push r14
    push r15
    call mod_power
    pop r15
    pop r14
    pop r13
    cmp rax, 1
    je next_rand_mr

    mov rbx, 1
    next_r:
    push rbx
    push r13
    push r14
    push r15
    call mod_power
    pop r15
    pop r14
    pop r13
    pop rbx
    cmp rax, r14
    je next_rand_mr
    shl rbx, 1
    cmp rbx, r15
    jg no_prime_mr
    mov rax, r13
    mul rbx
    mov r11, rax
    jmp next_r

    prime_mr:
    mov rax, 1
    ret

    no_prime_mr:
    mov rax, 0
    ret
