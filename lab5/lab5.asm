STDIN     equ 0
STDOUT    equ 1

section .data
    Symb db "No fitting pairs", 10, 0

section .bss
    ResString times 500 resb 1
    Array times 255 resq 1
    StrLen resw 1
    ArrayLen resb 1
    len resb 1
    FirstLen resb 1
    ErrorCount resb 1


section .text
	%include "../lib64.asm"
	global Solve

Solve:
    push rbp
    mov rbx, rdi
    dec rdi
    mov [Array], rdi
    mov rsi, 1

.cycle:
    mov al, [rbx]
    cmp al, ' '
    jne .after
    mov [Array + 8*rsi], rbx
    inc rsi

.after:
    inc rbx;

    cmp al, 0x0
    jne .cycle
    dec rbx
    mov [Array + rsi * 8], rbx
    inc rsi
    cmp rsi, 2
    je exit
    mov [ArrayLen], sil

    mov rdi, 0

.main_out:
    mov rsi, rdi
    inc rsi

    mov rbx, [Array + 8*rdi]
    inc rbx

    mov rcx, [Array + 8*rdi + 8]    
    sub rcx, rbx

    push rdi
    mov [FirstLen], cl
    

.main_in:

    mov cl, [FirstLen]
    mov rax, [Array + 8*rsi]
    inc rax

    mov rdx, [Array + 8*rsi + 8]
    sub rdx, rax
    
    push rsi
    push rdx
    push rcx

    sub rcx, rdx
    cmp rcx, -1
    jl no

    cmp rcx, 1
    jg no

    cmp rcx, 0
    je .equal

    pop rcx
    pop rdx

    mov BYTE[ErrorCount], 0
    cmp rcx, rdx
    jg .later
    mov [len], cl
    jmp .push

.later:
    mov [len], dl
    jmp .push

.push:
    push rdx
    push rcx
    jmp test1

.equal:
    pop rcx
    mov [len], cl
    mov BYTE[ErrorCount], 1
    push rcx
    jmp test1



test1:
    mov rcx, 0
    mov rsi, 0

.cycle:
    mov dl, [rbx + rcx]
    cmp dl, [rax + rcx]
    je .skip
    inc rsi

.skip:
    inc rcx
    cmp cl, BYTE[len]
    jl .cycle

    cmp sil, [ErrorCount]
    jng copy

test2:
    pop rcx
    pop rdx

    push rdx
    push rcx

    push rbx
    push rax

    add rbx, rcx
    add rax, rdx
    
    sub bl, [len]
    sub al, [len]

    mov rcx, 0
    mov rsi, 0

.cycle:
    mov dl, [rbx + rcx]
    cmp dl, [rax + rcx]
    je .skip
    inc rsi

.skip:
    inc rcx
    cmp cl, BYTE[len]
    jl .cycle

    pop rax
    pop rbx

    cmp sil, [ErrorCount]
    jg no

copy:
    pop rcx
    push rax
    mov rdx, 0
    movzx rax, WORD[StrLen]

.body1:
    mov sil, [rbx + rdx]
    mov [ResString + rax], sil

    inc rdx
    inc rax
    loop .body1

    mov sil, '-'
    mov [ResString + rax], sil
    inc rax 
    

    mov rdx, rbx
    pop rbx
    pop rcx
    push rdx
    mov rdx, 0

.body2:
    mov sil, [rbx + rdx]
    mov [ResString + rax], sil

    inc rdx
    inc rax
    loop .body2
    mov sil, 10
    mov [ResString + rax], sil
    inc rax
    mov [StrLen], ax
    pop rbx
    jmp next_in

no:
    pop rcx
    pop rdx
    jmp next_in


next_in:
    pop rsi
    inc rsi
    
    cmp sil, [ArrayLen]
    je next_out
    jmp Solve.main_in

next_out:
    pop rdi
    inc rdi

    mov cl, [ArrayLen]
    dec cl
    cmp dil, cl
    je exit
    jmp Solve.main_out




exit:
    mov bx, [StrLen]
    cmp bx, 0
    je .empty
    mov rax, ResString
    pop rbp 
    ret

.empty:
    mov rax, Symb
    pop rbp
    ret

  