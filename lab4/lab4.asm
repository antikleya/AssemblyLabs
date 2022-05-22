STDIN     equ 0
STDOUT    equ 1

section .data
    EnterMsg db "Enter matrix(5x6) in rows: "
    lenEnter equ $- EnterMsg
	EnterMsg2 db "Enter index of a row to be sorted: "
	lenEnter2 equ $- EnterMsg2
	ErrorMsg db "Incorrect index", 10
	lenError equ $- ErrorMsg
    OutMsg db "Result matrix: "
    lenOutMsg equ $- OutMsg
    EndMsg db 0xa                  ; перевод на новую строку
    rows dw 5
    cols dw 6                    ; количество элементов в строке
    del db " "                   ; разделитель

section .bss
	OutBuf resb 8                          ; вывод элемента
	lenOut equ $-OutBuf
	Row resb 25                            ; вводимая строки
	InpRow equ $-Row
	matrix times 30 resw 1                 ; матрица 4х6
	symb times 8 resb 1                  ; временная переменная для перевода числа из строки в число
	RowInd resw 1

section .text
	%include "../lib64.asm"
	global _start
_start: 	
	mov rbx, 0                       ; номер элемента
	push rbx	
	
	mov rax, STDOUT
	mov rdi, STDOUT
	mov rsi, EnterMsg
	mov rdx, lenEnter
	syscall
	
	mov rax, STDOUT
	mov rdi, STDOUT
	mov rsi, EndMsg 
	mov rdx, 1
	syscall
	
	jmp input_str
	
input_str:	
		
	mov rax, STDIN
	mov rdi, STDIN
	mov rsi, Row
	mov rdx, InpRow               ; ввод построчно
	syscall

	mov rax, 0
	mov rdi, Row
	jmp str_to_nums
	
str_to_nums:                         ; разбираем вводимую строку по символам
	movzx rsi, byte [rdi]
	
	cmp rsi, ' '                  ; если пробел - записываем число в массив
	je numb_to_matrix
	
	cmp rsi, 0xa                 ; если конец строки
	je row_end
			
	mov [symb + rax], si          ; записываем число во временную переменную
	inc rdi
	inc rax
	jmp str_to_nums

numb_to_matrix:                        ; преобразует строку(число) в число
	mov [symb + rax], byte 0xa
	
	mov esi, symb
	call StrToInt64
	cmp rbx, 0
	jne StrToInt64.Error
	
	pop rbx
	mov [matrix + 2 * rbx], eax
	inc rbx
	push rbx
	mov rax, 0
	inc rdi
	jmp str_to_nums

row_end:                               ; конец очередной строки
	mov [symb + rax], byte 0xa
	
	mov esi, symb
	call StrToInt64
	cmp ebx, 0
	jne StrToInt64.Error
	
	pop rbx
	mov [matrix + 2 * rbx], ax
	inc rbx
	push rbx
	mov rax, 0
	inc rdi
	jmp cycle

cycle:
	dec byte [rows]
	cmp [rows], byte 0          ; уменьшение счетчика
	jne input_str
	
	jmp indenter

indenter:
	mov rax, STDOUT
	mov rdi, STDOUT
	mov rsi, EndMsg 			; вывод пустой строки
	mov rdx, 1
	syscall

	mov rax, STDOUT
	mov rdi, STDOUT
	mov rsi, EnterMsg2			; вывод приглашения к вводу
	mov rdx, lenEnter2
	syscall

	mov rax, STDIN
	mov rdi, STDIN
	mov rsi, Row
	mov rdx, InpRow               ; ввод индекса
	syscall	

	mov esi, Row
	call StrToInt64
	cmp ebx, 0
	jne StrToInt64.Error

	dec ax

	cmp ax, 5
	jg .error

	cmp ax, 0
	jl .error

	jmp .cont
.error:
	mov rax, STDOUT
	mov rdi, STDOUT
	mov rsi, ErrorMsg 			
	mov rdx, lenError
	syscall

	jmp indenter

.cont:
	mov [RowInd], ax

	mov rax, STDOUT
	mov rdi, STDOUT
	mov rsi, EndMsg 			; вывод пустой строки 
	mov rdx, 1
	syscall

main:
	xor rcx, rcx
	xor rax, rax

	movzx rcx, WORD[cols]
	dec rcx
	mov ax, [cols]
	mul WORD[RowInd]
	shl ax, 1
	mov bx, ax


.cycle:

	lea rax, [matrix +  rbx]
	push rcx

	movzx rdx, WORD[cols]
	sub rdx, rcx

	movzx rcx, WORD[cols]
	sub rcx, rdx

	mov rdx, 1


.innercycle:
	mov si, WORD[matrix + rbx + 2 * rdx]
	cmp si, WORD[rax]
	jnl .after

	lea rax, [matrix + rbx + 2 * rdx]

.after:

	inc rdx

	loop .innercycle

	mov si, WORD[matrix + rbx]
	xchg si, WORD[rax]
	mov [matrix + rbx], si

	pop rcx
	add rbx, 2

	loop .cycle


out:
	mov rax, STDOUT
	mov rdi, STDOUT
	mov rsi, OutMsg 
	mov rdx, lenOutMsg
	syscall
	
	mov rax, STDOUT
	mov rdi, STDOUT
	mov rsi, EndMsg 
	mov rdx, 1
	syscall
	
	mov rbx, 0                       ; номер выводимого элемента                    
	jmp output

output:
	cmp rbx, 30
	je exit
	
	mov esi, OutBuf                ; преобразование чисел в строку
	mov ax, [matrix + 2 * rbx]
	cwde
	call IntToStr64
	
	mov rdi, STDOUT               ; вывод элементов получившейся матрицы
	mov rdx, OutBuf
	mov rdx, rax
	mov rax, STDOUT
	syscall
	
	mov rax, rbx                    ; enter между строками выводимой матрицы
	inc rax
	cwd
	idiv word[cols] 
	mov rax, 0
	cmp rdx, rax
	je enter
	
	mov rax, STDOUT              ; разделитель
	mov rdi, STDOUT
	mov rsi, del
	mov rdx, 1
	syscall
	
	inc rbx
	jmp output

enter:
	mov rax, STDOUT
	mov rdi, STDOUT
	mov rsi, EndMsg 
	mov rdx, 1
	syscall
	
	inc rbx     ;следующий столбец
	jmp output

exit:
	mov rax, 60
	xor rdi, rdi
	syscall

  