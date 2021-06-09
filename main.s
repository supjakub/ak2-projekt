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
    call miller_rabin

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
    mov rax, rdx
    xor rdx, rdx
    mov r10, r8
    sub r10, 2
    div r10
    add rdx, 2
    mov r9, rdx
    ret

;a-r9, b-r10, n-r11, wynik-rax, m-r12b, flag-r13, x-rbx
mod_power:
    mov r12b, 64
    mov r13, 0x8000000000000000
    loop_mp:
    push r13
    and r13, r10
    cmp r13, 0
    jne is_set
    pop r13
    shr r13, 1
    dec r12b
    jmp loop_mp
    is_set:
    pop r13

    mov rax, r9
    div r11
    mov r9, rdx
    mov r14, 1
    mov rbx, r9
    mov r13, 1
    push rcx
    mov cl, 0
    next_bit:
    push r13
    and r13, r10
    cmp r13, 0
    je is_zero
    mov rax, r14
    mul rbx
    div r11
    mov r14, rdx
    is_zero:
    mov rax, rbx
    mul rbx
    div r11
    mov rbx, rdx
    pop r13
    shl r13, 1
    inc cl
    cmp cl, r12b
    jng next_bit
    mov rax, r14
    pop rcx
    ret

fermat:
    mov r8, rax
    mov rax, 0xc9
    xor rdi, rdi
    syscall
    mov r9, rax

    mov rcx, 0
    next_rand_f:
    call random
    mov r10, r8
    dec r10
    mov r11, r8
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
    mov r8, rax
    cmp r8, 2
    je prime_mr
    xor rdx, rdx
    mov rbx, 2
    div rbx
    cmp rdx, 0
    je no_prime_mr

    mov rax, 0xc9
    xor rdi, rdi
    syscall
    mov r9, rax

    mov r10, 1
    shl r10, 63
    next_shift:
    mov rax, r8
    dec rax
    xor rdx, rdx
    div r10
    cmp rdx, 0
    je found_s
    shr r10, 1
    jmp next_shift

    found_s:
    mov rax, r8
    xor rdx, rdx
    div r10
    mov r15, r10 ;2^s
    shr r15, 1 ;2^s-1
    mov r10, rax
    mov r11, r8
    mov r14, r8
    dec r14 ;n-1

    mov cl, 0
    next_rand_mr:
    inc cl
    cmp cl, 2
    jg prime_mr
    push r10
    call random
    pop r10
    push r9
    call mod_power
    pop r9
    cmp rax, 1
    je next_rand_mr

    mov ebx, 1
    next_r:
    push r9
    push rbx
    call mod_power
    pop rbx
    pop r9
    cmp rax, r14
    jne next_rand_mr
    shl rbx, 1
    cmp rbx, r15
    jg no_prime_mr
    mov rax, r9
    mul rbx
    mov r9, rax
    jmp next_r

    prime_mr:
    mov rax, 1
    ret

    no_prime_mr:
    mov rax, 0
    ret
