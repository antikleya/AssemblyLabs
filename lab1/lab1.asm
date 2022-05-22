   section .data
A 	dw   	-30
B 	dw   	21
val1    db      255
chart   dw      256
lue3    dw      -128
v5      db      10h
        db      100101B
beta    db      23, 23h, 0ch
sdk     db      "Hello",10
min     dw      -32767
ar      dd      12345678h
valar   times 5 db 8
numb1   db      25
numb2   dw      -35
name    db      "Egor Егор", 10
exp1 	dw	25h, 37, 00100101B
exp2	dw	2500h, 9472, 0010010100000000B
F1	dw	65535
F2	dw	65535
ExitMsg db "Press Enter to Exit",10
lenExit equ $-ExitMsg
   section .bss
alu 	resw 	10
f1 	resb 	5
X	resd 	1
InBuf   resb    10
lenIn   equ     $-InBuf
   section .text
        global  _start
_start: add 	DWORD[F1], 1
	add 	DWORD[F2], 1
	mov 	EAX, [A] ; загрузить число A в регистр EAX
	add 	EAX, 5	 ; сложить EAX и 5, результат в EAX
	sub 	EAX, [B] ; вычесть число B, результат в EAX
	mov 	[X], EAX ; сохранить результат в памяти
        ; write
        mov     rax, 1
        mov     rdi, 1
        mov     rsi, ExitMsg
        mov     rdx, lenExit
        syscall
        ; read
        mov     rax, 0
        mov     rdi, 0
        mov     rsi, InBuf
        mov     rdx, lenIn
        syscall
        ; exit
        mov     rax, 60
        xor     rdi, rdi
        syscall
