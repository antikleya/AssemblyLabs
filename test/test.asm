STDIN     equ 0
STDOUT    equ 1

section .data
    EnterMsg db "Enter matrix(4x6) in rows: "
    lenEnter equ $- EnterMsg
    OutMsg db "Result matrix: "
    lenOutMsg equ $- OutMsg
    NoMtrxMsg db "In all columns amount is even!"
    lenNoMsg equ $- NoMtrxMsg
    ResMes db "Result array: ", 10
    lenResMes equ $- ResMes
    EndMsg db 0xa                  ; перевод на новую строку
    rows dw 4
    cols dw 8                    ; количество элементов в строке
    del db " "                   ; разделитель
    divi dw 2                    ; для определения четности суммы столбца
    flag dw 1                    ; флаг для запрещенных столбцов
    out_divider dw 6             ; делитель для определения элементов из запрещенного столбца

section .bss
	count resw 1                           ; количество выводимых элементов
    	sum resw 1                             ; сумма столбца
	OutBuf resb 8                          ; вывод элемента
	lenOut equ $-OutBuf
	Row resb 25                            ; вводимая строки
	InpRow equ $-Row
	matrix times 32 resw 1                 ; матрица 4х6
	ResArr times 8 resq 1
	Temp resq 1
	symb times 8 resb 1                  ; временная переменная для перевода числа из строки в число
	forbidden times 6 resw 1                ; запрещенные столбцы

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
	
	mov word [sum], 0
	jmp main

	
main:
    xor rcx, rcx
    xor rdx, rdx
    mov cx, 8
    mov rbx, 0
    
.out_cycle:
    push rcx
    xor eax, eax
    xor rdx, rdx
    mov esi, ebx
    mov cx, 4
    mov QWORD[Temp], 1
    
.in_cycle:
    mov rax, [Temp]
    mul WORD[matrix + 2 * esi]
    mov [Temp], ax
    mov [Temp + 2], dx
    add si, [cols]
    
    loop .in_cycle
    
    mov rdx, [Temp]
    mov [ResArr + 8 * ebx], rdx
    inc ebx
    pop rcx
    
    loop .out_cycle
	
	
arr_output:

; Array output

    mov         rax, 1                      
    mov         rdi, 1                      
    mov         rsi, ResMes               
    mov         rdx, lenResMes              
    syscall                                 ; вызов системной функции

    xor rcx, rcx
    xor rbx, rbx
    mov cx, 8
    mov ebx, 0

.cycle:
    push rcx
    mov esi, OutBuf                ; преобразование чисел в строку
	mov rax, [ResArr + 8* ebx]
	call IntToStr64
	
	mov rdi, STDOUT               ; вывод элементов
	mov rdx, OutBuf
	mov rdx, rax
	mov rax, STDOUT
	syscall
	
	mov rax, STDOUT              ; разделитель
	mov rdi, STDOUT
	mov rsi, del
	mov rdx, 1
	syscall
	
	pop rcx
	inc ebx
	loop .cycle
	
	mov rax, STDOUT
	mov rdi, STDOUT
	mov rsi, EndMsg 
	mov rdx, 1
	syscall
	
	
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
	
	mov word [count], 0              ; количество выведенных элементов
	mov rbx, 0                       ; номер выводимого элемента                    
	jmp output

output:
	cmp rbx, 32
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

  
