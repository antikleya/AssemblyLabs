STDIN     equ 0
STDOUT    equ 1

section .data
    EnterMsg db "Enter words separated by spaces:", 10
    lenEnter equ $- EnterMsg
    OutMsg db "Fitting words:", 10
    lenOutMsg equ $- OutMsg
    EndMsg db 0xa                  ; перевод на новую строку
    
    del db " "                   ; разделитель

section .bss
	OutBuf resb 8                          ; вывод элемента
	lenOut equ $-OutBuf
	Row resb 60                            ; вводимая строка
	InpStr equ $-Row
	ResArr times 15 resb 1
    Array times 40 resq 1

section .text
	%include "../lib64.asm"
	global _start
_start: 

    mov rax, STDOUT
	mov rdi, STDOUT
	mov rsi, EnterMsg
	mov rdx, lenEnter
	syscall

    mov rax, STDIN
	mov rdi, STDIN
	mov rsi, Row
	mov rdx, InpStr              
	syscall

    mov QWORD[Array], Row
    mov rsi, 1
    mov rbx, Row


.inp_cycle:

    mov al, [rbx]
    cmp al, 0
    je count

    cmp al, ' '
    jne .skip

.spaces:
    inc rbx
    mov al, [rbx]
    cmp al, ' '
    je .spaces

.copy:
    mov [Array + rsi*8], rbx
    inc rsi

.skip: 
    inc rbx
    jmp .inp_cycle


count:
    mov rcx, 0

.out_cycle:

    mov rbx, [Array + rcx*8]
    mov rax, 0
    mov rdi, 0

.in_cycle:
    mov dl, [rbx + rdi]

    cmp dl, ' '
    je .next_out

    cmp dl, 0
    je .next_out

    cmp dl, 'A'
    jne .skip

    inc rax

.skip:
    inc rdi
    jmp .in_cycle

.next_out:
    mov [ResArr + rcx], al

    inc rcx
    cmp rcx, rsi
    jl .out_cycle


    

output:

    mov rbx, 0
    push rsi

    mov rax, STDOUT
	mov rdi, STDOUT
	mov rsi, OutMsg 
	mov rdx, lenOutMsg
	syscall

.cycle:
    pop rsi
	cmp rbx, rsi
	je exit
    push rsi

    mov al, [ResArr + rbx]
    cmp al, 3
    jl .skip

    mov rax, [Array + 8*rbx]
    mov rcx, 1
.in_cycle:
    mov sil, [rax + rcx]

    cmp sil, ' '
    je .ex

    cmp sil, 0x10
    je .ex

    cmp sil, 0
    je .ex

    inc rcx
    jmp .in_cycle

.ex:
	mov rdi, STDOUT               ; вывод элементов получившейся матрицы
	mov rdx, rcx
	mov rsi, [Array + 8*rbx]
	mov rax, STDOUT
	syscall
	
	
	mov rax, STDOUT              ; разделитель
	mov rdi, STDOUT
	mov rsi, del
	mov rdx, 1
	syscall

.skip:
	
	inc rbx     
	jmp .cycle

exit:
    mov rax, STDOUT
	mov rdi, STDOUT
	mov rsi, EndMsg 
	mov rdx, 1
	syscall

	mov rax, 60
	xor rdi, rdi
	syscall