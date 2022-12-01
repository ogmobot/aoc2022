; nasm -f elf64 day01.s -o day01.o
; ld -lc day01.o -o day01

global main, _start

section .text

main:
_start:
    mov rax, 0
    mov [current_num], rax
    mov [best_elf], rax

    mov rax, 2      ; "open" syscall
    mov rdi, input_path
    mov rsi, 0      ; read-only
    syscall

    push rax        ; store file descriptor
    sub rsp, 1      ; reserve 1 byte

new_elf:
    mov rax, 0
    mov [current_elf], rax
read_into_buffer:
    mov rax, 0      ; "read" syscall
    mov rdi, [rsp+1]; file descriptor
    mov rsi, rsp    ; buffer address
    mov rdx, 1      ; buffer size
    syscall

    test rax, rax
    jz finally      ; jump if zero (end of file)

    mov rax, [rsp]
    test rax, 0xA    ; check for newline
    jz found_newline

found_digit:
    mov rax, [rsp]
    mov r8, 1
    mov [seen_digit], r8
    sub rax, '0'
    mov r8, [current_num]
    imul r8, 10
    add r8, rax
    mov [current_num], r8
    jmp read_into_buffer

found_newline:
    mov r8, 0
    mov rax, [seen_digit]
    mov [seen_digit], r8
    test rax, 0
    jz end_elf
    ; add this number to elf's total
    mov rax, [current_elf]
    mov rbx, [current_num]
    add rax, rbx
    mov [current_elf], rax
    jmp read_into_buffer

end_elf:
    mov rax, [current_elf]
    mov rbx, [best_elf]
    cmp rbx, rax
    ja new_elf ; jump if above
    mov [best_elf], rax
    jmp new_elf

finally:
    ;mov rdi, printf_string
    ;mov rsi, [best_elf]
    ;mov al, 0
    ;extern printf
    ;call printf
    mov r9, [best_elf]

    mov rax, 60     ; "exit" syscall
    mov rdi, 0      ; exit code
    syscall

section .data

current_num: dq 0
current_elf: dq 0
best_elf: dq 0
seen_digit: dq 0
input_path: db "input01.txt", 0
printf_string: db "%d\n", 0
