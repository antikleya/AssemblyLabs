STDIN     equ 0
STDOUT    equ 1

section .data
    WelMsg1 db "Enter A: "
    lenWelMsg1 equ $- WelMsg1
    WelMsg2 db "Enter C: "
    lenWelMsg2 equ $- WelMsg2
    ResMsg db "Result = "
    lenResMsg equ $- ResMsg
    EndMsg db 0xa                  ; перевод на новую строку

section .bss
	A resw 1
    Row resb 25                            ; вводимая строки
	InpRow equ $-Row
    C resw 1 
    Res resd 1
    OutBuf resb 8                          ; вывод элемента
	lenOut equ $-OutBuf

section .text
	%include "../lib64.asm"
	global _start

_start: 	

input:    	
	mov rax, STDOUT
	mov rdi, STDOUT
	mov rsi, WelMsg1
	mov rdx, lenWelMsg1
	syscall
	
	mov rax, STDIN
	mov rdi, STDIN
	mov rsi, Row
	mov rdx, InpRow               
	syscall


    mov rsi, Row
	call StrToInt64
	cmp rbx, 0
	jne StrToInt64.Error
	
	mov [A], ax


    mov rax, STDOUT
	mov rdi, STDOUT
	mov rsi, WelMsg2
	mov rdx, lenWelMsg2
	syscall
	
	mov rax, STDIN
	mov rdi, STDIN
	mov rsi, Row
	mov rdx, InpRow               
	syscall


    mov rsi, Row
	call StrToInt64
	cmp rbx, 0
	jne StrToInt64.Error
	
	mov [C], ax

main:
	xor rax, rax
    mov ax, [A]
    cwd
    idiv WORD[C]
    cmp ax, 2
    jg rbranch

lbranch:
    mov ax, [C]
	mov bx, 2
	imul bx
	mov ebx, edx
	shl ebx, 16
	mov bx, ax

	xor eax, eax
	mov ax, WORD[A]
	cwde

	add ebx, eax
	mov [Res], ebx
    jmp output

	shl edx, 16
	mov dx, ax

rbranch:
	mov ax, [A]
	sub ax, [C]
	imul ax
	
	add ax, [C]
	adc dx, 0
	mov bx, dx
	shl ebx, 16
	mov bx, ax
	mov [Res], ebx
    jmp output


output:
    mov rax, STDOUT
	mov rdi, STDOUT
	mov rsi, ResMsg 
	mov rdx, lenResMsg
	syscall

    mov esi, OutBuf                ; преобразование чисел в строку
	mov eax, [Res]
	call IntToStr64
	
	mov rdi, STDOUT               ; вывод элементов
	mov rdx, OutBuf
	mov rdx, rax
	mov rax, STDOUT
	syscall

    mov rax, STDOUT
	mov rdi, STDOUT
	mov rsi, EndMsg 
	mov rdx, 1
	syscall

exit:
	mov rax, 60
	xor rdi, rdi
	syscall

  
